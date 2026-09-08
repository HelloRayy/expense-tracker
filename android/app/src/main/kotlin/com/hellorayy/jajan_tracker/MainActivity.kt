package com.hellorayy.jajan_tracker

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val WIDGET_CHANNEL = "com.hellorayy.jajan_tracker/widget"
    private val SHOPEE_CHANNEL = "com.hellorayy.jajan_tracker/shopee_watcher"

    private var initialAction: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        initialAction = intent?.action

        // Widget channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidget" -> {
                    JajanWidgetProvider.updateAllWidgets(applicationContext)
                    JajanWidget4x2Provider.updateAllWidgets(applicationContext)
                    JajanQuickTileService.requestTileUpdate(applicationContext)
                    result.success(true)
                }
                "getInitialAction" -> {
                    val action = initialAction
                    initialAction = null // reset after reading once
                    result.success(action)
                }
                else -> result.notImplemented()
            }
        }

        // Shopee watcher channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SHOPEE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkOverlayPermission" -> {
                    val granted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        Settings.canDrawOverlays(this)
                    } else {
                        true
                    }
                    result.success(granted)
                }
                "openOverlaySettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName")
                        )
                        startActivity(intent)
                    }
                    result.success(true)
                }
                "checkAccessibilityPermission" -> {
                    val enabled = isAccessibilityServiceEnabled(this, ShopeeAccessibilityService::class.java)
                    result.success(enabled)
                }
                "openAccessibilitySettings" -> {
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                    startActivity(intent)
                    result.success(true)
                }
                "showFloatingReminder" -> {
                    val balance = (call.argument<Number>("balance"))?.toLong() ?: 0L
                    val formatter = java.text.NumberFormat.getCurrencyInstance(java.util.Locale("id", "ID")).apply {
                        maximumFractionDigits = 0
                    }
                    val balanceStr = formatter.format(balance)
                    ShopeeAccessibilityService.isMutedForSession = false
                    ShopeeAccessibilityService.showHeadsUpNotification(this, balanceStr, "Rp 50.000", isFromQris = true)
                    result.success(true)
                }
                "toggleFloatingBubble" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    if (enabled) {
                        FloatingBubbleService.start(this)
                    } else {
                        FloatingBubbleService.stop(this)
                    }
                    result.success(true)
                }
                "isFloatingBubbleRunning" -> {
                    result.success(FloatingBubbleService.isRunning)
                }
                "checkNotificationListenerPermission" -> {
                    result.success(isNotificationListenerEnabled(this))
                }
                "openNotificationListenerSettings" -> {
                    val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
                        Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                    } else {
                        Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS")
                    }
                    startActivity(intent)
                    result.success(true)
                }
                "simulatePaymentNotification" -> {
                    val amount = (call.argument<Number>("amount"))?.toLong() ?: 35000L
                    val note = call.argument<String>("note") ?: "ShopeePay"
                    JajanNotificationListenerService.showActionableTransactionNotification(this, amount, note)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun isNotificationListenerEnabled(context: Context): Boolean {
        val pkgName = context.packageName
        val flat = Settings.Secure.getString(context.contentResolver, "enabled_notification_listeners")
        return flat != null && flat.contains(pkgName)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        if (intent.action == JajanWidgetProvider.ACTION_QUICK_LOG) {
            // Can notify Flutter if needed
        }
    }

    private fun isAccessibilityServiceEnabled(context: Context, serviceClass: Class<*>): Boolean {
        val expectedComponentName = "${context.packageName}/${serviceClass.name}"
        val enabledServices = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false

        val colonSplitter = enabledServices.split(":")
        for (componentName in colonSplitter) {
            if (componentName.equals(expectedComponentName, ignoreCase = true) ||
                componentName.equals("${context.packageName}/.${serviceClass.simpleName}", ignoreCase = true)) {
                return true
            }
        }
        return false
    }
}
