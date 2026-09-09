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

                // Explicit broadcast to notify launcher widgets
                val updateIntent = Intent(context, JajanWidget4x2Provider::class.java).apply {
                    action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    if (appWidgetIds != null && appWidgetIds.isNotEmpty()) {
                        putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds)
                    }
                }
                context.sendBroadcast(updateIntent)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        private fun updateWidgets(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
            val data = JajanWidgetStorage.loadWidgetData(context)
            val userName = data.userName
            val dailyAllowance = data.dailyAllowance
            val weeklyIncome = data.weeklyIncome
            val totalSpent = data.totalSpent

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

            val weeklyIncomeStr = try {
                formatter.format(weeklyIncome)
            } catch (_: Exception) {
                "Rp $weeklyIncome"
            }

            val totalSpentStr = try {
                formatter.format(totalSpent)
            } catch (_: Exception) {
                "Rp $totalSpent"
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
                    views.setTextViewText(R.id.tv_widget_remaining, weeklyIncomeStr)
                    views.setTextViewText(R.id.tv_widget_spent, totalSpentStr)

                    // Hero Nominal Color (Soft White when safe, Soft Rose Red when negative)
                    if (isAllowanceNegative) {
                        views.setTextColor(R.id.tv_widget_daily_amount, Color.parseColor("#E87B7B"))
                    } else {
                        views.setTextColor(R.id.tv_widget_daily_amount, Color.parseColor("#EBEBEB"))
                    }

                    // Weekly Income Color (Mint Green)
                    views.setTextColor(R.id.tv_widget_remaining, Color.parseColor("#6ECE9D"))

                    // Total Spent Color (Rose Red)
                    views.setTextColor(R.id.tv_widget_spent, Color.parseColor("#E87B7B"))

                    // Attach click PendingIntent to container and all interactive subviews
                    views.setOnClickPendingIntent(R.id.widget_4x2_container, appPendingIntent)
                    views.setOnClickPendingIntent(R.id.tv_widget_daily_amount, appPendingIntent)
                    views.setOnClickPendingIntent(R.id.tv_widget_greeting, appPendingIntent)
                    views.setOnClickPendingIntent(R.id.tv_widget_subtitle, appPendingIntent)
                    views.setOnClickPendingIntent(R.id.tv_widget_remaining, appPendingIntent)
                    views.setOnClickPendingIntent(R.id.tv_widget_spent, appPendingIntent)

                    appWidgetManager.updateAppWidget(widgetId, views)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
    }
}
