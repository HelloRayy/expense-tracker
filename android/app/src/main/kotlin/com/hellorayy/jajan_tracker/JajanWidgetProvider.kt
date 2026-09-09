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

                val updateIntent = Intent(context, JajanWidgetProvider::class.java).apply {
                    action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    if (appWidgetIds != null && appWidgetIds.isNotEmpty()) {
                        putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds)
                    }
                }
                context.sendBroadcast(updateIntent)

                JajanWidget4x2Provider.updateAllWidgets(context)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        private fun updateWidgets(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
            val data = JajanWidgetStorage.loadWidgetData(context)
            val remaining = data.remainingBalance
            val dailySafe = data.dailySafe

            val formatter = NumberFormat.getCurrencyInstance(Locale("id", "ID")).apply {
                maximumFractionDigits = 0
            }
            val dailyStr = if (remaining > 0 && dailySafe > 0) {
                try {
                    formatter.format(dailySafe)
                } catch (_: Exception) {
                    "Rp $dailySafe"
                }
            } else {
                "Rp 0"
            }

            val totalStr = try {
                formatter.format(remaining)
            } catch (_: Exception) {
                "Rp $remaining"
            }

            val subtext = if (remaining > 0) {
                "Sisa periode: $totalStr"
            } else {
                "⚠️ Saldo periode habis!"
            }

            // PendingIntent to launch Floating Calculator directly (via Trampoline)
            val intent = Intent(context, QuickTileTrampolineActivity::class.java).apply {
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
                    views.setTextViewText(R.id.widget_balance, dailyStr)
                    views.setTextViewText(R.id.widget_subtext, subtext)

                    if (remaining <= 0 || dailySafe <= 0) {
                        views.setTextColor(R.id.widget_balance, android.graphics.Color.parseColor("#EF4444"))
                    } else {
                        views.setTextColor(R.id.widget_balance, android.graphics.Color.parseColor("#10B981"))
                    }

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
