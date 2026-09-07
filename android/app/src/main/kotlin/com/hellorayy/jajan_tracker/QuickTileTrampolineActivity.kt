package com.hellorayy.jajan_tracker

import android.app.Activity
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.provider.Settings

class QuickTileTrampolineActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Check if overlay permission is granted
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)) {
            // Instantly pop up the floating calculator directly on the current screen!
            FloatingBubbleService.startWithCalculator(this)
        } else {
            // Fallback to full app Quick-Log if overlay permission not granted
            val appIntent = Intent(this, MainActivity::class.java).apply {
                action = JajanWidgetProvider.ACTION_QUICK_LOG
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            startActivity(appIntent)
        }

        // Finish immediately with no transition animation
        finish()
        overridePendingTransition(0, 0)
    }
}
