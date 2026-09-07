package com.hellorayy.jajan_tracker

import android.accessibilityservice.AccessibilityService
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import androidx.core.app.NotificationCompat
import java.text.NumberFormat
import java.util.Locale

class ShopeeAccessibilityService : AccessibilityService() {

    private val handler = Handler(Looper.getMainLooper())
    private var hasShownGeneralInSession: Boolean = false
    private var lastGeneralTriggerTime: Long = 0
    private var lastQrisTriggerTime: Long = 0
    private var lastShopeeActivityTime: Long = 0

    private val generalNudgeRunnable = Runnable {
        try {
            val now = System.currentTimeMillis()
            // Only fire general nudge if QRIS was not triggered recently
            if (now - lastQrisTriggerTime > COOLDOWN_QRIS_MS) {
                triggerNudge(isFromQris = false)
            }
        } catch (_: Throwable) {}
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        try {
            if (event == null) return

            val pkgName = event.packageName?.toString() ?: return
            val isShopee = pkgName.contains("shopee", ignoreCase = true)

            if (!isShopee) {
                // User navigated away from Shopee -> Reset session state
                hasShownGeneralInSession = false
                handler.removeCallbacks(generalNudgeRunnable)
                return
            }

            val now = System.currentTimeMillis()

            // Auto-reset general session if user was idle/away from Shopee for > 20 seconds
            if (now - lastShopeeActivityTime > 20000) {
                hasShownGeneralInSession = false
            }
            lastShopeeActivityTime = now

            // =========================================================================
            // 1. QRIS BUTTON CLICK DETECTION (typeViewClicked)
            // =========================================================================
            if (event.eventType == AccessibilityEvent.TYPE_VIEW_CLICKED) {
                if (isQrisClick(event)) {
                    if (now - lastQrisTriggerTime > COOLDOWN_QRIS_MS) {
                        lastQrisTriggerTime = now
                        handler.removeCallbacks(generalNudgeRunnable)
                        triggerNudge(isFromQris = true)
                    }
                    return
                }
            }

            // =========================================================================
            // 2. WINDOW STATE CHANGED (Screen navigation: Scanner Screen or App Open)
            // =========================================================================
            if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
                // Priority Check: Did user enter the QRIS Scanner Screen?
                if (isQrScannerScreen(event)) {
                    if (now - lastQrisTriggerTime > COOLDOWN_QRIS_MS) {
                        lastQrisTriggerTime = now
                        handler.removeCallbacks(generalNudgeRunnable)
                        triggerNudge(isFromQris = true)
                    }
                    return
                }

                // General Shopee Open Nudge (e.g. user just opened Shopee app)
                if (!hasShownGeneralInSession && (now - lastGeneralTriggerTime > COOLDOWN_GENERAL_MS)) {
                    if (now - lastQrisTriggerTime > COOLDOWN_QRIS_MS) {
                        hasShownGeneralInSession = true
                        lastGeneralTriggerTime = now
                        handler.removeCallbacks(generalNudgeRunnable)
                        handler.postDelayed(generalNudgeRunnable, 500)
                    }
                }
            }
        } catch (t: Throwable) {
            t.printStackTrace()
        }
    }

    override fun onInterrupt() {
        handler.removeCallbacks(generalNudgeRunnable)
    }

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacks(generalNudgeRunnable)
    }

    /**
     * Detects if the clicked view is a QRIS / Scan / ShopeePay payment button.
     * Checks event payload, source viewId, contentDescription, text, and direct children.
     */
    private fun isQrisClick(event: AccessibilityEvent): Boolean {
        // Fast-path 1: Direct event payload (0 IPC cost)
        val text = event.text?.joinToString(" ") ?: ""
        val contentDesc = event.contentDescription?.toString() ?: ""
        val combined = "$text $contentDesc".lowercase()

        val keywords = listOf(
            "qris", "scan", "pindai", "kode qr", "qr code", "scanner", "bayar qris", "shopeepay"
        )
        for (kw in keywords) {
            if (combined.contains(kw)) return true
        }

        // Fast-path 2: Check event source node properties if available
        try {
            val source = event.source ?: return false
            val viewId = source.viewIdResourceName?.lowercase() ?: ""
            if (viewId.contains("qris") || viewId.contains("scan") || viewId.contains("qr")) {
                return true
            }

            val nodeDesc = source.contentDescription?.toString()?.lowercase() ?: ""
            for (kw in keywords) {
                if (nodeDesc.contains(kw)) return true
            }

            val nodeText = source.text?.toString()?.lowercase() ?: ""
            for (kw in keywords) {
                if (nodeText.contains(kw)) return true
            }

            // Check immediate children (shallow check, max 6 children)
            val childCount = source.childCount.coerceAtMost(6)
            for (i in 0 until childCount) {
                val child = source.getChild(i) ?: continue
                val cDesc = child.contentDescription?.toString()?.lowercase() ?: ""
                val cText = child.text?.toString()?.lowercase() ?: ""
                val cId = child.viewIdResourceName?.lowercase() ?: ""
                for (kw in keywords) {
                    if (cDesc.contains(kw) || cText.contains(kw) || cId.contains(kw)) {
                        return true
                    }
                }
            }
        } catch (_: Throwable) {}

        return false
    }

    /**
     * Detects if the current screen is Shopee's QRIS Scanner screen.
     * Matches Image 2: "Scan QRIS", "Sentuh untuk menerangi", "Kode QR", "Bayar QRIS".
     */
    private fun isQrScannerScreen(event: AccessibilityEvent): Boolean {
        // 1. Check Activity/Window class name
        val className = event.className?.toString()?.lowercase() ?: ""
        if (className.contains("scan") ||
            className.contains("qris") ||
            className.contains("qrcode") ||
            className.contains("camera") ||
            className.contains("capture")) {
            return true
        }

        // 2. Direct event payload text / content description
        val text = event.text?.joinToString(" ") ?: ""
        val desc = event.contentDescription?.toString() ?: ""
        val combined = "$text $desc".lowercase()

        val screenKeywords = listOf(
            "scan qris",
            "sentuh untuk menerangi",
            "kode qr",
            "bayar qris",
            "pindai kode",
            "pindai qr"
        )
        for (kw in screenKeywords) {
            if (combined.contains(kw)) return true
        }

        if (combined.contains("qris") || (combined.contains("scan") && combined.contains("qr"))) {
            return true
        }

        // 3. Search window text for distinctive scanner UI elements (only on window change)
        try {
            val root = rootInActiveWindow
            if (root != null) {
                val targets = listOf("Scan QRIS", "Sentuh untuk menerangi", "Kode QR", "Bayar QRIS")
                for (target in targets) {
                    val nodes = root.findAccessibilityNodeInfosByText(target)
                    if (!nodes.isNullOrEmpty()) {
                        return true
                    }
                }
            }
        } catch (_: Throwable) {}

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
        private const val COOLDOWN_QRIS_MS: Long = 3500 // 3.5 seconds for QRIS button click / scanner screen
        private const val COOLDOWN_GENERAL_MS: Long = 15000 // 15 seconds for general Shopee open
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
