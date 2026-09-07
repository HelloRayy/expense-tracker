package com.hellorayy.jajan_tracker

import android.accessibilityservice.AccessibilityService
import android.annotation.SuppressLint
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.view.accessibility.AccessibilityEvent
import android.widget.TextView
import androidx.core.app.NotificationCompat
import java.text.NumberFormat
import java.util.Locale

class ShopeeAccessibilityService : AccessibilityService() {

    private val handler = Handler(Looper.getMainLooper())
    private var hasShownInSession: Boolean = false
    private var lastTriggerTime: Long = 0
    private var lastEventTime: Long = 0

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        try {
            if (event == null) return

            val now = System.currentTimeMillis()
            // 1. ULTRA FAST-PATH: If within cooldown, discard instantly without any allocations (0 CPU)
            if (now - lastTriggerTime < COOLDOWN_QRIS_MS) {
                return
            }

            val pkgName = event.packageName?.toString() ?: return
            val isShopee = pkgName.contains("shopee", ignoreCase = true)

            if (isShopee) {
                // Auto-reset session if user was away from Shopee for > 25 seconds
                if (now - lastEventTime > 25000) {
                    hasShownInSession = false
                }
                lastEventTime = now

                // 2. Specific Click Detection: "Bayar QRIS" or ShopeePay button
                if (event.eventType == AccessibilityEvent.TYPE_VIEW_CLICKED) {
                    if (isQrisOrPayClick(event)) {
                        lastTriggerTime = now
                        hasShownInSession = true
                        triggerNudge(isFromQris = true)
                        return
                    }
                }

                // 3. Window State Change: Opening Shopee / Entering flow
                if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
                    if (!hasShownInSession && (now - lastTriggerTime > COOLDOWN_GENERAL_MS)) {
                        lastTriggerTime = now
                        hasShownInSession = true
                        handler.postDelayed({
                            try {
                                triggerNudge(isFromQris = false)
                            } catch (_: Throwable) {}
                        }, 800)
                    }
                }
            } else {
                // User left Shopee -> Reset session state so it's ready for the next visit
                hasShownInSession = false
            }
        } catch (t: Throwable) {
            t.printStackTrace()
        }
    }

    override fun onInterrupt() {
        // Nothing needed
    }

    private fun isQrisOrPayClick(event: AccessibilityEvent): Boolean {
        // Purely inspect event payload - zero Binder IPC view tree overhead
        val text = event.text?.joinToString(" ") ?: ""
        val contentDesc = event.contentDescription?.toString() ?: ""

        val keywords = listOf("qris", "bayar", "shopeepay", "saldo", "pay")
        for (kw in keywords) {
            if (text.contains(kw, ignoreCase = true) || contentDesc.contains(kw, ignoreCase = true)) {
                return true
            }
        }

        return false
    }

    private fun triggerNudge(isFromQris: Boolean) {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val allEntries = prefs.all

        var remaining = 1500000L
        val rawRemaining = allEntries["flutter.remaining_balance"] ?: allEntries["remaining_balance"]
        if (rawRemaining is Number) {
            remaining = rawRemaining.toLong()
        }

        var dailySafe = 50000L
        val rawDaily = allEntries["flutter.daily_safe"] ?: allEntries["daily_safe"]
        if (rawDaily is Number) {
            dailySafe = rawDaily.toLong()
        }

        val formatter = NumberFormat.getCurrencyInstance(Locale("id", "ID")).apply {
            maximumFractionDigits = 0
        }
        val formattedBalance = formatter.format(remaining)
        val formattedDaily = formatter.format(dailySafe)

        // Show High-Priority Heads-Up Notification by system only (100% native system notification, zero UI overlay)
        showHeadsUpNotification(this, formattedBalance, formattedDaily, isFromQris)
    }

    companion object {
        private const val COOLDOWN_QRIS_MS: Long = 6000 // 6 seconds for QRIS click
        private const val COOLDOWN_GENERAL_MS: Long = 12000 // 12 seconds for general open
        const val CHANNEL_ID = "jajan_nudge_channel"
        const val NOTIFICATION_ID = 3001

        fun showHeadsUpNotification(
            context: Context,
            formattedBalance: String,
            formattedDaily: String,
            isFromQris: Boolean
        ) {
            val notificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager ?: return

            // Create notification channel for Android 8+
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    "Pengingat Sisa Uang Jajan",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Notifikasi sisa uang jajan saat membuka Shopee atau scan QRIS"
                    enableVibration(true)
                }
                notificationManager.createNotificationChannel(channel)
            }

            val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && Settings.canDrawOverlays(context)) {
                Intent(context, QuickTileTrampolineActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
            } else {
                Intent(context, MainActivity::class.java).apply {
                    action = JajanWidgetProvider.ACTION_QUICK_LOG
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
            }

            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            val pendingIntent = PendingIntent.getActivity(context, 1002, intent, flags)

            val title = if (isFromQris) {
                "⚡ QRIS • Sisa $formattedBalance"
            } else {
                "🛍️ Sisa Jajan: $formattedBalance"
            }

            val subtitle = "Aman: $formattedDaily / hari"

            val builder = NotificationCompat.Builder(context, CHANNEL_ID)
                .setSmallIcon(R.drawable.ic_quick_tile)
                .setContentTitle(title)
                .setContentText(subtitle)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setDefaults(NotificationCompat.DEFAULT_ALL)
                .setAutoCancel(true)
                .setContentIntent(pendingIntent)
                .setTimeoutAfter(8000) // Disappear after 8 seconds
                .addAction(
                    R.drawable.ic_quick_tile,
                    "⚡ Catat Jajan",
                    pendingIntent
                )

            try {
                notificationManager.notify(NOTIFICATION_ID, builder.build())
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}
