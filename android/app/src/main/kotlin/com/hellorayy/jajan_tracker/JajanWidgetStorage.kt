package com.hellorayy.jajan_tracker

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

object JajanWidgetStorage {
    const val PREFS_NAME = "FlutterSharedPreferences"

    data class WidgetData(
        val userName: String,
        val dailyAllowance: Long,
        val weeklyIncome: Long,
        val totalSpent: Long,
        val remainingBalance: Long,
        val dailySafe: Long
    )

    fun saveWidgetData(context: Context, data: Map<*, *>) {
        try {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val editor = prefs.edit()

            for ((rawKey, value) in data) {
                val key = rawKey?.toString() ?: continue
                when (value) {
                    is Number -> {
                        editor.putLong(key, value.toLong())
                        editor.putLong("flutter.$key", value.toLong())
                    }
                    is String -> {
                        editor.putString(key, value)
                        editor.putString("flutter.$key", value)
                    }
                    is Boolean -> {
                        editor.putBoolean(key, value)
                        editor.putBoolean("flutter.$key", value)
                    }
                }
            }
            editor.commit()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun loadWidgetData(context: Context): WidgetData {
        var userName = "Raditya Rayhan"
        var dailyAllowance = 0L
        var weeklyIncome = 0L
        var totalSpent = 0L
        var remainingBalance = 0L
        var dailySafe = 0L

        try {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val all = prefs.all

            val rawUserName = all["flutter.user_name"] ?: all["user_name"]
            if (rawUserName != null && rawUserName.toString().isNotBlank()) {
                userName = rawUserName.toString().trim()
            }

            val rawAllowance = all["flutter.daily_allowance"] ?: all["daily_allowance"] ?: all["flutter.daily_safe"] ?: all["daily_safe"]
            if (rawAllowance is Number) {
                dailyAllowance = rawAllowance.toLong()
            }

            val rawIncome = all["flutter.weekly_income"] ?: all["weekly_income"] ?: all["flutter.total_budget"] ?: all["total_budget"]
            if (rawIncome is Number) {
                weeklyIncome = rawIncome.toLong()
            }

            val rawSpent = all["flutter.total_spent"] ?: all["total_spent"]
            if (rawSpent is Number) {
                totalSpent = rawSpent.toLong()
            }

            val rawRemaining = all["flutter.remaining_balance"] ?: all["remaining_balance"]
            if (rawRemaining is Number) {
                remainingBalance = rawRemaining.toLong()
            }

            val rawDailySafe = all["flutter.daily_safe"] ?: all["daily_safe"]
            if (rawDailySafe is Number) {
                dailySafe = rawDailySafe.toLong()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }

        // If SharedPreferences has no data yet (cold boot / first install / un-synced), fallback to SQLite database
        if (dailyAllowance == 0L && weeklyIncome == 0L && totalSpent == 0L && remainingBalance == 0L) {
            val fromDb = loadFromDatabase(context, userName)
            if (fromDb != null) {
                return fromDb
            }
        }

        return WidgetData(
            userName = userName,
            dailyAllowance = dailyAllowance,
            weeklyIncome = weeklyIncome,
            totalSpent = totalSpent,
            remainingBalance = remainingBalance,
            dailySafe = dailySafe
        )
    }

    private fun loadFromDatabase(context: Context, defaultUserName: String): WidgetData? {
        try {
            val dbFile = context.getDatabasePath("jajan_tracker.db")
            if (!dbFile.exists()) return null

            val db = SQLiteDatabase.openDatabase(dbFile.path, null, SQLiteDatabase.OPEN_READONLY)
            try {
                var weeklyIncome = 0L
                var weeklySavingsTarget = 0L
                var totalBudgetFallback = 0L
                var startDateStr = ""
                var endDateStr = ""

                val budgetCursor = db.rawQuery(
                    "SELECT weekly_income, weekly_savings_target, start_date, end_date, total_budget FROM budget WHERE id = 1 LIMIT 1",
                    null
                )
                if (budgetCursor.moveToFirst()) {
                    weeklyIncome = budgetCursor.getLong(0)
                    weeklySavingsTarget = budgetCursor.getLong(1)
                    startDateStr = budgetCursor.getString(2) ?: ""
                    endDateStr = budgetCursor.getString(3) ?: ""
                    totalBudgetFallback = budgetCursor.getLong(4)
                }
                budgetCursor.close()

                if (weeklyIncome == 0L && totalBudgetFallback > 0L) {
                    weeklyIncome = totalBudgetFallback
                }

                val spendableBudget = Math.max(0L, weeklyIncome - weeklySavingsTarget)

                var totalSpent = 0L
                if (startDateStr.isNotEmpty() && endDateStr.isNotEmpty()) {
                    val sumCursor = db.rawQuery(
                        "SELECT SUM(amount) FROM expenses WHERE created_at >= ? AND created_at <= ?",
                        arrayOf(startDateStr, endDateStr)
                    )
                    if (sumCursor.moveToFirst()) {
                        totalSpent = sumCursor.getLong(0)
                    }
                    sumCursor.close()
                }

                // Query spent today
                val cal = Calendar.getInstance().apply {
                    set(Calendar.HOUR_OF_DAY, 0)
                    set(Calendar.MINUTE, 0)
                    set(Calendar.SECOND, 0)
                    set(Calendar.MILLISECOND, 0)
                }
                val sdfIso = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.US)
                val todayStartStr = sdfIso.format(cal.time)

                var spentToday = 0L
                val todayCursor = db.rawQuery(
                    "SELECT SUM(amount) FROM expenses WHERE created_at >= ?",
                    arrayOf(todayStartStr)
                )
                if (todayCursor.moveToFirst()) {
                    spentToday = todayCursor.getLong(0)
                }
                todayCursor.close()

                val spentUntilYesterday = Math.max(0L, totalSpent - spentToday)
                val remainingBudgetForAllowance = Math.max(0L, spendableBudget - spentUntilYesterday)

                var daysRemaining = 1L
                if (endDateStr.isNotEmpty()) {
                    try {
                        val endClean = endDateStr.split(".")[0]
                        val parsedEnd = sdfIso.parse(endClean)
                        if (parsedEnd != null) {
                            val diffMs = parsedEnd.time - System.currentTimeMillis()
                            daysRemaining = Math.max(1L, Math.ceil(diffMs / (1000.0 * 60 * 60 * 24)).toLong())
                        }
                    } catch (_: Exception) {}
                }

                val dailyAllowance = if (daysRemaining > 0) remainingBudgetForAllowance / daysRemaining else 0L
                val remainingToday = dailyAllowance - spentToday
                val remainingBalance = spendableBudget - totalSpent

                val widgetData = WidgetData(
                    userName = defaultUserName,
                    dailyAllowance = dailyAllowance,
                    weeklyIncome = weeklyIncome,
                    totalSpent = totalSpent,
                    remainingBalance = remainingBalance,
                    dailySafe = remainingToday
                )

                // Persist to SharedPreferences so subsequent queries are instant
                val toSave = mapOf(
                    "user_name" to defaultUserName,
                    "daily_allowance" to dailyAllowance,
                    "weekly_income" to weeklyIncome,
                    "total_spent" to totalSpent,
                    "remaining_balance" to remainingBalance,
                    "daily_safe" to remainingToday
                )
                saveWidgetData(context, toSave)

                return widgetData
            } finally {
                db.close()
            }
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }
}
