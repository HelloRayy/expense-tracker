package com.hellorayy.jajan_tracker

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.widget.RemoteViews
import java.text.NumberFormat
import java.util.Locale

class JajanWidget4x2Provider : AppWidgetProvider() {

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

        fun updateAllWidgets(context: Context) {
            try {
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val componentName = ComponentName(context, JajanWidget4x2Provider::class.java)
                val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
                if (appWidgetIds != null && appWidgetIds.isNotEmpty()) {
                    updateWidgets(context, appWidgetManager, appWidgetIds)
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        private fun updateWidgets(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
            var remaining = 1380000L
            var dailySafe = 30000L
            var totalSpent = 120000L
            var periodText = ""

            try {
                val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                val allEntries = prefs.all

                val rawRemaining = allEntries["flutter.remaining_balance"] ?: allEntries["remaining_balance"]
                if (rawRemaining is Number) {
                    remaining = rawRemaining.toLong()
                }

                val rawDaily = allEntries["flutter.daily_safe"] ?: allEntries["daily_safe"]
                if (rawDaily is Number) {
                    dailySafe = rawDaily.toLong()
                }

                val rawSpent = allEntries["flutter.total_spent"] ?: allEntries["total_spent"]
                if (rawSpent is Number) {
                    totalSpent = rawSpent.toLong()
                }

                val rawPeriod = allEntries["flutter.formatted_period"] ?: allEntries["formatted_period"]
                if (rawPeriod != null) {
                    periodText = rawPeriod.toString().trim()
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }

            val formatter = NumberFormat.getCurrencyInstance(Locale("id", "ID")).apply {
                maximumFractionDigits = 0
            }

            val isDailyNegative = dailySafe < 0
            val dailyStr = if (isDailyNegative) {
                try {
                    "-${formatter.format(Math.abs(dailySafe))}"
                } catch (_: Exception) {
                    "-Rp ${Math.abs(dailySafe)}"
                }
            } else {
                try {
                    formatter.format(dailySafe)
                } catch (_: Exception) {
                    "Rp $dailySafe"
                }
            }

            val isRemainingNegative = remaining < 0
            val remainingStr = if (isRemainingNegative) {
                try {
                    "↙ -${formatter.format(Math.abs(remaining))}"
                } catch (_: Exception) {
                    "↙ -Rp ${Math.abs(remaining)}"
                }
            } else {
                try {
                    "↙ ${formatter.format(remaining)}"
                } catch (_: Exception) {
                    "↙ Rp $remaining"
                }
            }

            val spentStr = try {
                "↗ ${formatter.format(totalSpent)}"
            } catch (_: Exception) {
                "↗ Rp $totalSpent"
            }

            val subtitleText = if (periodText.isNotEmpty()) {
                "batas jajan hari ini ⌄ • $periodText"
            } else {
                "batas jajan hari ini ⌄"
            }

            // Intent to open Main App Dashboard
            val appIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            val appPendingIntent = PendingIntent.getActivity(context, 2001, appIntent, flags)

            // Intent to open Quick-Log Floating Calculator
            val calcIntent = Intent(context, QuickTileTrampolineActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val calcPendingIntent = PendingIntent.getActivity(context, 2002, calcIntent, flags)

            for (widgetId in appWidgetIds) {
                try {
                    val views = RemoteViews(context.packageName, R.layout.widget_jajan_4x2)
                    views.setTextViewText(R.id.tv_widget_greeting, "Hi, Sobat")
                    views.setTextViewText(R.id.tv_widget_subtitle, subtitleText)
                    views.setTextViewText(R.id.tv_widget_daily_amount, dailyStr)
                    views.setTextViewText(R.id.tv_widget_daily_unit, "/ hari")
                    views.setTextViewText(R.id.tv_widget_remaining, remainingStr)
                    views.setTextViewText(R.id.tv_widget_spent, spentStr)

                    // Hero Nominal Color (White when safe, Red when negative/overbudget)
                    if (isDailyNegative || remaining <= 0) {
                        views.setTextColor(R.id.tv_widget_daily_amount, Color.parseColor("#EF4444"))
                    } else {
                        views.setTextColor(R.id.tv_widget_daily_amount, Color.parseColor("#FFFFFF"))
                    }

                    // Remaining Balance Color
                    if (isRemainingNegative) {
                        views.setTextColor(R.id.tv_widget_remaining, Color.parseColor("#EF4444"))
                    } else {
                        views.setTextColor(R.id.tv_widget_remaining, Color.parseColor("#10B981"))
                    }

                    // Click listeners:
                    // Main Container -> Open App Dashboard
                    views.setOnClickPendingIntent(R.id.widget_4x2_container, appPendingIntent)
                    // 3-Dots Action Button -> Open Instant Floating Calculator
                    views.setOnClickPendingIntent(R.id.btn_widget_action, calcPendingIntent)

                    appWidgetManager.updateAppWidget(widgetId, views)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
    }
}
