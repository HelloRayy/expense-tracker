package com.hellorayy.jajan_tracker

import android.accessibilityservice.AccessibilityService
import android.annotation.SuppressLint
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
import java.text.NumberFormat
import java.util.Locale

class ShopeeAccessibilityService : AccessibilityService() {

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val pkgName = event.packageName?.toString() ?: return
            if (pkgName.contains("shopee", ignoreCase = true)) {
                checkAndShowNudge()
            }
        }
    }

    override fun onInterrupt() {
        // Nothing needed
    }

    private fun checkAndShowNudge() {
        val now = System.currentTimeMillis()
        if (now - lastShownTime < COOLDOWN_MS) {
            return // Cooldown active, don't spam
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
            return // No overlay permission
        }

        lastShownTime = now
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val remaining = if (prefs.contains("flutter.remaining_balance")) {
            prefs.getLong("flutter.remaining_balance", 0L)
        } else {
            prefs.getInt("remaining_balance", 0).toLong()
        }

        Handler(Looper.getMainLooper()).post {
            displayFloatingChip(this, remaining)
        }
    }

    companion object {
        private var lastShownTime: Long = 0
        private const val COOLDOWN_MS: Long = 15000 // 15 seconds cooldown

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
                y = 120 // 120px below top notch/status bar
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

            // Close button
            view.findViewById<View>(R.id.btn_nudge_close)?.setOnClickListener {
                dismiss()
            }

            // Tapping body opens Quick-Log in the app
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
                // Auto dismiss after 6 seconds
                Handler(Looper.getMainLooper()).postDelayed({
                    dismiss()
                }, 6000)
            } catch (_: Exception) {}
        }
    }
}
