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

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        try {
            if (event == null) return

            val pkgName = event.packageName?.toString() ?: return
            val isShopee = pkgName.contains("shopee", ignoreCase = true)

            if (isShopee) {
                // 1. Specific Click Detection: "Bayar QRIS" or ShopeePay button
                if (event.eventType == AccessibilityEvent.TYPE_VIEW_CLICKED) {
                    if (isQrisOrPayClick(event)) {
                        val now = System.currentTimeMillis()
                        if (now - lastTriggerTime > COOLDOWN_QRIS_MS) {
                            lastTriggerTime = now
                            hasShownInSession = true
                            triggerNudge(isFromQris = true)
                        }
                        return
                    }
                }

                // 2. Window State Change: Opening Shopee / Entering flow
                if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
                    if (!hasShownInSession) {
                        val now = System.currentTimeMillis()
                        if (now - lastTriggerTime > COOLDOWN_GENERAL_MS) {
                            lastTriggerTime = now
                            hasShownInSession = true
                            // 1.2s delayed retry to bypass initial splash screen & promo popups
                            handler.postDelayed({
                                try {
                                    triggerNudge(isFromQris = false)
                                } catch (_: Throwable) {}
                            }, 1200)
                        }
                    }
                }
            } else {
                // User left Shopee -> Reset session state so it's ready for the next visit
                if (hasShownInSession) {
                    hasShownInSession = false
                }
            }
        } catch (t: Throwable) {
            t.printStackTrace()
        }
    }

    override fun onInterrupt() {
        // Nothing needed
    }

    private fun isQrisOrPayClick(event: AccessibilityEvent): Boolean {
        val text = event.text?.joinToString(" ") ?: ""
        val contentDesc = event.contentDescription?.toString() ?: ""

        val keywords = listOf("qris", "bayar", "shopeepay", "saldo", "pay")
        for (kw in keywords) {
            if (text.contains(kw, ignoreCase = true) || contentDesc.contains(kw, ignoreCase = true)) {
                return true
            }
        }

        try {
            val source = event.source
            if (source != null) {
                val sText = source.text?.toString() ?: ""
                val sDesc = source.contentDescription?.toString() ?: ""
                for (kw in keywords) {
                    if (sText.contains(kw, ignoreCase = true) || sDesc.contains(kw, ignoreCase = true)) {
                        return true
                    }
                }
            }
        } catch (_: Exception) {}

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

        // 1. Show High-Priority Heads-Up Notification (meluncur dari atas status bar)
        showHeadsUpNotification(this, formattedBalance, formattedDaily, isFromQris)

        // 2. Also show Floating Chip if overlay permission is granted
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)) {
            handler.post {
                displayFloatingChip(this, remaining)
            }
        }
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

            val intent = Intent(context, MainActivity::class.java).apply {
                action = JajanWidgetProvider.ACTION_QUICK_LOG
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            val pendingIntent = PendingIntent.getActivity(context, 1002, intent, flags)

            val title = if (isFromQris) {
                "⚡ Mau Bayar QRIS? Sisa Jajan: $formattedBalance"
            } else {
                "🛍️ Ingat Sisa Uang Jajan: $formattedBalance"
            }

            val subtitle = "Aman jajan ~$formattedDaily / hari lagi sebelum gajian. Tap buat catat!"

            val builder = NotificationCompat.Builder(context, CHANNEL_ID)
                .setSmallIcon(R.drawable.ic_quick_tile)
                .setContentTitle(title)
                .setContentText(subtitle)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setDefaults(NotificationCompat.DEFAULT_ALL)
                .setAutoCancel(true)
                .setContentIntent(pendingIntent)
                .setTimeoutAfter(7000) // Disappear after 7 seconds

            try {
                notificationManager.notify(NOTIFICATION_ID, builder.build())
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        @SuppressLint("InflateParams")
        fun displayFloatingChip(context: Context, balance: Long) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(context)) {
                return
            }

            val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as? WindowManager ?: return

            val layoutFlag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_PHONE
            }

            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                layoutFlag,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                        WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                        WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
                PixelFormat.TRANSLUCENT
            ).apply {
                gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
                y = 120
            }

            val inflater = LayoutInflater.from(context)
            val view: View
            try {
                view = inflater.inflate(R.layout.floating_shopee_nudge, null)
            } catch (e: Exception) {
                return
            }

            val formatter = NumberFormat.getCurrencyInstance(Locale("id", "ID")).apply {
                maximumFractionDigits = 0
            }
            view.findViewById<TextView>(R.id.tv_nudge_balance)?.text = formatter.format(balance)

            var isDismissed = false
            fun dismiss() {
                if (!isDismissed) {
                    isDismissed = true
                    try {
                        windowManager.removeView(view)
                    } catch (_: Exception) {}
                }
            }

            view.findViewById<View>(R.id.btn_nudge_close)?.setOnClickListener {
                dismiss()
            }

            view.findViewById<View>(R.id.btn_nudge_click)?.setOnClickListener {
                dismiss()
                val intent = Intent(context, MainActivity::class.java).apply {
                    action = JajanWidgetProvider.ACTION_QUICK_LOG
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                context.startActivity(intent)
            }

            try {
                windowManager.addView(view, params)
                Handler(Looper.getMainLooper()).postDelayed({
                    dismiss()
                }, 6000)
            } catch (_: Exception) {}
        }
    }
}
