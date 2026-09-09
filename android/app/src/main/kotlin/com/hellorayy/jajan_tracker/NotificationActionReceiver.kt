package com.hellorayy.jajan_tracker

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import android.os.Build
import android.provider.Settings
import android.widget.Toast
import java.text.NumberFormat
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class NotificationActionReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        if (intent == null) return

        val notifId = intent.getIntExtra(EXTRA_NOTIF_ID, 0)
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        if (notifId != 0) {
            nm?.cancel(notifId)
        }

        when (intent.action) {
            ACTION_AUTO_LOG -> {
                val amount = intent.getLongExtra(EXTRA_AMOUNT, 0L)
                val note = intent.getStringExtra(EXTRA_NOTE) ?: "Jajan"
                if (amount > 0) {
                    saveExpenseToDatabase(context, amount, note)
                }
            }
            ACTION_OPEN_CALC -> {
                val amount = intent.getLongExtra(EXTRA_AMOUNT, 0L)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && Settings.canDrawOverlays(context)) {
                    val calcIntent = Intent(context, FloatingBubbleService::class.java).apply {
                        putExtra(FloatingBubbleService.EXTRA_OPEN_CALCULATOR, true)
                        putExtra(FloatingBubbleService.EXTRA_STANDALONE, true)
                    }
                    try {
                        context.startService(calcIntent)
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                } else {
                    val appIntent = Intent(context, MainActivity::class.java).apply {
                        action = "ACTION_QUICK_LOG"
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    }
                    context.startActivity(appIntent)
                }
            }
            ACTION_DISMISS -> {
                // Already canceled above
            }
            ACTION_MUTE_SHOPEE -> {
                ShopeeAccessibilityService.isMutedForSession = true
                ShopeeAccessibilityService.hasShownGeneralInSession = true
            }
        }
    }

    private fun saveExpenseToDatabase(context: Context, amount: Long, note: String) {
        try {
            val dbPath = context.getDatabasePath("jajan_tracker.db")
            var exactRemaining: Long? = null
            var exactDailySafe: Long? = null

            if (dbPath.exists()) {
                val db = SQLiteDatabase.openDatabase(dbPath.path, null, SQLiteDatabase.OPEN_READWRITE)
                try {
                    db.beginTransaction()
                    try {
                        val values = ContentValues().apply {
                            put("amount", amount)
                            put("note", note)
                            val sdf = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS", Locale.US)
                            put("created_at", sdf.format(Date()))
                        }
                        db.insert("expenses", null, values)
                        db.setTransactionSuccessful()
                    } finally {
                        db.endTransaction()
                    }

                    // Query exact active budget & total expenses to prevent cache drift
                    var weeklyIncome = 0L
                    var weeklySavingsTarget = 0L
                    var totalBudgetFallback = 0L
                    var startDate = ""
                    var endDate = ""

                    try {
                        val budgetCursor = db.rawQuery(
                            "SELECT weekly_income, weekly_savings_target, start_date, end_date, total_budget FROM budget WHERE id = 1 LIMIT 1",
                            null
                        )
                        if (budgetCursor.moveToFirst()) {
                            weeklyIncome = budgetCursor.getLong(0)
                            weeklySavingsTarget = budgetCursor.getLong(1)
                            startDate = budgetCursor.getString(2) ?: ""
                            endDate = budgetCursor.getString(3) ?: ""
                            totalBudgetFallback = budgetCursor.getLong(4)
                        }
                        budgetCursor.close()
                    } catch (_: Exception) {
                        try {
                            val budgetCursor = db.rawQuery(
                                "SELECT total_budget, start_date, end_date FROM budget WHERE id = 1 LIMIT 1",
                                null
                            )
                            if (budgetCursor.moveToFirst()) {
                                totalBudgetFallback = budgetCursor.getLong(0)
                                startDate = budgetCursor.getString(1) ?: ""
                                endDate = budgetCursor.getString(2) ?: ""
                            }
                            budgetCursor.close()
                        } catch (_: Exception) {}
                    }

                    val activeBudget = if (weeklyIncome > 0) Math.max(0L, weeklyIncome - weeklySavingsTarget) else totalBudgetFallback

                    var totalSpent = 0L
                    if (startDate.isNotEmpty() && endDate.isNotEmpty()) {
                        val sumCursor = db.rawQuery(
                            "SELECT SUM(amount) FROM expenses WHERE created_at >= ? AND created_at <= ?",
                            arrayOf(startDate, endDate)
                        )
                        if (sumCursor.moveToFirst()) {
                            totalSpent = sumCursor.getLong(0)
                        }
                        sumCursor.close()
                    } else {
                        val sumCursor = db.rawQuery("SELECT SUM(amount) FROM expenses", null)
                        if (sumCursor.moveToFirst()) {
                            totalSpent = sumCursor.getLong(0)
                        }
                        sumCursor.close()
                    }

                    val computed = activeBudget - totalSpent
                    exactRemaining = computed

                    if (endDate.isNotEmpty()) {
                        try {
                            val sdfEnd = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.US)
                            val endClean = endDate.split(".")[0]
                            val endD = sdfEnd.parse(endClean)
                            if (endD != null) {
                                val diffMs = endD.time - System.currentTimeMillis()
                                val days = Math.max(1L, Math.ceil(diffMs / (1000.0 * 60 * 60 * 24)).toLong())
                                exactDailySafe = if (computed > 0) computed / days else 0L
                            }
                        } catch (_: Exception) {}
                    }
                } finally {
                    db.close()
                }
            }

            // Update SharedPreferences atomically
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val editor = prefs.edit()
            if (exactRemaining != null) {
                editor.putLong("flutter.remaining_balance", exactRemaining)
                if (exactDailySafe != null) {
                    editor.putLong("flutter.daily_safe", exactDailySafe)
                }
            } else {
                val all = prefs.all
                var remaining = 0L
                val raw = all["flutter.remaining_balance"] ?: all["remaining_balance"]
                if (raw is Number) {
                    remaining = raw.toLong()
                }
                editor.putLong("flutter.remaining_balance", remaining - amount)

                var currentSpent = 0L
                val rawSpent = all["flutter.total_spent"] ?: all["total_spent"]
                if (rawSpent is Number) {
                    currentSpent = rawSpent.toLong()
                }
                editor.putLong("flutter.total_spent", currentSpent + amount)
                editor.putLong("total_spent", currentSpent + amount)
            }
            editor.commit()

            // Update Widget & Quick Tile
            JajanWidgetProvider.updateAllWidgets(context)
            JajanQuickTileService.requestTileUpdate(context)

            val formatter = NumberFormat.getCurrencyInstance(Locale("id", "ID")).apply {
                maximumFractionDigits = 0
            }
            Toast.makeText(context, "✓ Tercatat jajan ${formatter.format(amount)} ($note)", Toast.LENGTH_SHORT).show()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    companion object {
        const val ACTION_AUTO_LOG = "com.hellorayy.jajan_tracker.ACTION_AUTO_LOG"
        const val ACTION_OPEN_CALC = "com.hellorayy.jajan_tracker.ACTION_OPEN_CALC"
        const val ACTION_DISMISS = "com.hellorayy.jajan_tracker.ACTION_DISMISS"
        const val ACTION_MUTE_SHOPEE = "com.hellorayy.jajan_tracker.ACTION_MUTE_SHOPEE"

        const val EXTRA_AMOUNT = "EXTRA_AMOUNT"
        const val EXTRA_NOTE = "EXTRA_NOTE"
        const val EXTRA_NOTIF_ID = "EXTRA_NOTIF_ID"
    }
}
