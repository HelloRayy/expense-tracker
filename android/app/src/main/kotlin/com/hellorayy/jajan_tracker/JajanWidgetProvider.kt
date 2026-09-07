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
        try {
            updateWidgets(context, appWidgetManager, appWidgetIds)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        try {
            super.onReceive(context, intent)
            if (intent.action == ACTION_UPDATE_WIDGET) {
                updateAllWidgets(context)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    companion object {
        const val ACTION_UPDATE_WIDGET = "com.hellorayy.jajan_tracker.UPDATE_WIDGET"
        const val ACTION_QUICK_LOG = "ACTION_QUICK_LOG"

        fun updateAllWidgets(context: Context) {
            try {
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val componentName = ComponentName(context, JajanWidgetProvider::class.java)
                val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
                if (appWidgetIds != null && appWidgetIds.isNotEmpty()) {
                    updateWidgets(context, appWidgetManager, appWidgetIds)
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        private fun updateWidgets(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
            var remaining = 1500000L
            var dailySafe = 50000L

            try {
                val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                val allEntries = prefs.all

                // Safely read remaining_balance regardless of whether Flutter wrote it as Long or Int
                val rawRemaining = allEntries["flutter.remaining_balance"] ?: allEntries["remaining_balance"]
                if (rawRemaining is Number) {
                    remaining = rawRemaining.toLong()
                }

                // Safely read daily_safe
                val rawDaily = allEntries["flutter.daily_safe"] ?: allEntries["daily_safe"]
                if (rawDaily is Number) {
                    dailySafe = rawDaily.toLong()
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }

            val formatter = NumberFormat.getCurrencyInstance(Locale("id", "ID")).apply {
                maximumFractionDigits = 0
            }
            val balanceStr = try {
                formatter.format(remaining)
            } catch (_: Exception) {
                "Rp $remaining"
            }

            val dailyStr = if (remaining > 0) {
                try {
                    "Aman jajan ~${formatter.format(dailySafe)} / hari"
                } catch (_: Exception) {
                    "Aman jajan ~Rp $dailySafe / hari"
                }
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
                try {
                    val views = RemoteViews(context.packageName, R.layout.widget_jajan)
                    views.setTextViewText(R.id.widget_balance, balanceStr)
                    views.setTextViewText(R.id.widget_subtext, dailyStr)

                    // Tapping button or widget container triggers Quick-Log
                    views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)
                    views.setOnClickPendingIntent(R.id.widget_btn_quick_log, pendingIntent)

                    appWidgetManager.updateAppWidget(widgetId, views)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
    }
}
