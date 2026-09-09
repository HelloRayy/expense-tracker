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
            var remainingToday = 0L
            var dailyAllowance = 0L
            var spentToday = 0L
            var userName = "Username"

            try {
                val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                val allEntries = prefs.all

                val rawUserName = allEntries["flutter.user_name"] ?: allEntries["user_name"]
                if (rawUserName != null && rawUserName.toString().isNotBlank()) {
                    userName = rawUserName.toString().trim()
                }

                val rawDailyAllowance = allEntries["flutter.daily_allowance"] ?: allEntries["daily_allowance"] ?: allEntries["flutter.daily_safe"] ?: allEntries["daily_safe"]
                if (rawDailyAllowance is Number) {
                    dailyAllowance = rawDailyAllowance.toLong()
                }

                val rawRemainingToday = allEntries["flutter.remaining_today"] ?: allEntries["remaining_today"] ?: allEntries["flutter.daily_safe"] ?: allEntries["daily_safe"]
                if (rawRemainingToday is Number) {
                    remainingToday = rawRemainingToday.toLong()
                }

                val rawSpentToday = allEntries["flutter.spent_today"] ?: allEntries["spent_today"] ?: allEntries["flutter.total_spent"] ?: allEntries["total_spent"]
                if (rawSpentToday is Number) {
                    spentToday = rawSpentToday.toLong()
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }

            val formatter = NumberFormat.getCurrencyInstance(Locale("id", "ID")).apply {
                maximumFractionDigits = 0
            }

            val isAllowanceNegative = dailyAllowance < 0
            val dailyStr = if (isAllowanceNegative) {
                try {
                    "-${formatter.format(Math.abs(dailyAllowance))}"
                } catch (_: Exception) {
                    "-Rp ${Math.abs(dailyAllowance)}"
                }
            } else {
                try {
                    formatter.format(dailyAllowance)
                } catch (_: Exception) {
                    "Rp $dailyAllowance"
                }
            }

            val isRemainingNegative = remainingToday < 0
            val remainingStr = if (isRemainingNegative) {
                try {
                    "-${formatter.format(Math.abs(remainingToday))}"
                } catch (_: Exception) {
                    "-Rp ${Math.abs(remainingToday)}"
                }
            } else {
                try {
                    formatter.format(remainingToday)
                } catch (_: Exception) {
                    "Rp $remainingToday"
                }
            }

            val spentStr = try {
                formatter.format(spentToday)
            } catch (_: Exception) {
                "Rp $spentToday"
            }

            val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }

            // Intent to open Main App Dashboard
            val appIntent = Intent(context, MainActivity::class.java).apply {
                this.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val appPendingIntent = PendingIntent.getActivity(context, 2001, appIntent, pendingIntentFlags)

            for (widgetId in appWidgetIds) {
                try {
                    val views = RemoteViews(context.packageName, R.layout.widget_jajan_4x2)
                    views.setTextViewText(R.id.tv_widget_greeting, "Hi, $userName")
                    views.setTextViewText(R.id.tv_widget_subtitle, "Batas jajan hari ini")
                    views.setTextViewText(R.id.tv_widget_daily_amount, dailyStr)
                    views.setTextViewText(R.id.tv_widget_daily_unit, "/hari")
                    views.setTextViewText(R.id.tv_widget_remaining, remainingStr)
                    views.setTextViewText(R.id.tv_widget_spent, spentStr)

                    // Hero Nominal Color (Soft White when safe, Soft Rose Red when negative)
                    if (isAllowanceNegative) {
                        views.setTextColor(R.id.tv_widget_daily_amount, Color.parseColor("#E87B7B"))
                    } else {
                        views.setTextColor(R.id.tv_widget_daily_amount, Color.parseColor("#EBEBEB"))
                    }

                    // Remaining Today Color (Mint Green if safe, Rose Red if negative)
                    if (isRemainingNegative) {
                        views.setTextColor(R.id.tv_widget_remaining, Color.parseColor("#E87B7B"))
                    } else {
                        views.setTextColor(R.id.tv_widget_remaining, Color.parseColor("#6ECE9D"))
                    }

                    // Spent Today Color (Always Rose Red)
                    views.setTextColor(R.id.tv_widget_spent, Color.parseColor("#E87B7B"))

                    // Main Container click -> Open App Dashboard
                    views.setOnClickPendingIntent(R.id.widget_4x2_container, appPendingIntent)

                    appWidgetManager.updateAppWidget(widgetId, views)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
    }
}
