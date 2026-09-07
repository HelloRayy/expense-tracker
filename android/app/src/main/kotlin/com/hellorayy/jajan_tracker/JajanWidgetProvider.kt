package com.hellorayy.jajan_tracker

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews
import java.text.NumberFormat
import java.util.Locale

class JajanWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        updateWidgets(context, appWidgetManager, appWidgetIds)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_UPDATE_WIDGET) {
            updateAllWidgets(context)
        }
    }

    companion object {
        const val ACTION_UPDATE_WIDGET = "com.hellorayy.jajan_tracker.UPDATE_WIDGET"
        const val ACTION_QUICK_LOG = "ACTION_QUICK_LOG"

        fun updateAllWidgets(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val componentName = ComponentName(context, JajanWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
            if (appWidgetIds != null && appWidgetIds.isNotEmpty()) {
                updateWidgets(context, appWidgetManager, appWidgetIds)
            }
        }

        private fun updateWidgets(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

            // Keys in Flutter SharedPreferences are stored with "flutter." prefix
            val remaining = if (prefs.contains("flutter.remaining_balance")) {
                prefs.getLong("flutter.remaining_balance", 0L)
            } else {
                prefs.getInt("remaining_balance", 0).toLong()
            }

            val dailySafe = if (prefs.contains("flutter.daily_safe")) {
                prefs.getLong("flutter.daily_safe", 0L)
            } else {
                prefs.getInt("daily_safe", 0).toLong()
            }

            val formatter = NumberFormat.getCurrencyInstance(Locale("id", "ID")).apply {
                maximumFractionDigits = 0
            }
            val balanceStr = formatter.format(remaining)
            val dailyStr = if (remaining > 0) {
                "Aman jajan ~${formatter.format(dailySafe)} / hari"
            } else {
                "⚠️ Saldo jajan sudah habis!"
            }

            // PendingIntent to launch MainActivity directly to Quick-Log
            val intent = Intent(context, MainActivity::class.java).apply {
                action = ACTION_QUICK_LOG
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            val pendingIntent = PendingIntent.getActivity(context, 1001, intent, flags)

            for (widgetId in appWidgetIds) {
                val views = RemoteViews(context.packageName, R.layout.widget_jajan)
                views.setTextViewText(R.id.widget_balance, balanceStr)
                views.setTextViewText(R.id.widget_subtext, dailyStr)

                // Tapping button or widget container triggers Quick-Log
                views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)
                views.setOnClickPendingIntent(R.id.widget_btn_quick_log, pendingIntent)

                appWidgetManager.updateAppWidget(widgetId, views)
            }
        }
    }
}
