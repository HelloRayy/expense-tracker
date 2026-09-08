package com.hellorayy.jajan_tracker

import android.annotation.SuppressLint
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Point
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.text.SpannableStringBuilder
import android.text.Spanned
import android.text.style.ForegroundColorSpan
import android.view.Gravity
import android.view.HapticFeedbackConstants
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.TextView
import android.widget.Toast
import androidx.core.app.NotificationCompat
import java.text.NumberFormat
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import kotlin.math.abs

class FloatingBubbleService : Service() {

    private var windowManager: WindowManager? = null
    private var bubbleView: View? = null
    private var calcView: View? = null

    private lateinit var bubbleParams: WindowManager.LayoutParams
    private lateinit var calcParams: WindowManager.LayoutParams

    private var currentAmount: Long = 0L
    private var expression: String = ""
    private var dailyAllowance: Long = 50000L
    private var isStandalone: Boolean = false

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        isRunning = true
        windowManager = getSystemService(Context.WINDOW_SERVICE) as? WindowManager

        createNotificationChannel()
        startForegroundServiceNotification()

        initBubble()
        initCalculator()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.getBooleanExtra(EXTRA_OPEN_CALCULATOR, false) == true) {
            isStandalone = intent.getBooleanExtra(EXTRA_STANDALONE, false)
            expandToCalculator()
        }
        return START_STICKY
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                BUBBLE_CHANNEL_ID,
                "Layanan Floating Bubble Jajan",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Menjaga bubble pintasan melayang tetap aktif di layar"
            }
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
            nm?.createNotificationChannel(channel)
        }
    }

    private fun startForegroundServiceNotification() {
        try {
            val notification = NotificationCompat.Builder(this, BUBBLE_CHANNEL_ID)
                .setSmallIcon(R.drawable.ic_quick_tile)
                .setContentTitle("Floating Bubble Jajan Aktif")
                .setContentText("Ketuk gelembung di layar untuk kalkulator jajan instan")
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .build()

            startForeground(FOREGROUND_ID, notification)
        } catch (_: Throwable) {
            // Safe fallback on Android 14+ to prevent MissingForegroundServiceTypeException crash
        }
    }

    @SuppressLint("ClickableViewAccessibility")
    private fun initBubble() {
        val wm = windowManager ?: return

        val layoutFlag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        bubbleParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            layoutFlag,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = 20
            y = 300
        }

        val inflater = LayoutInflater.from(this)
        bubbleView = inflater.inflate(R.layout.floating_bubble_layout, null)

        // Drag & Snap handling for bubble
        bubbleView?.setOnTouchListener(object : View.OnTouchListener {
            private var initialX = 0
            private var initialY = 0
            private var initialTouchX = 0f
            private var initialTouchY = 0f
            private var isClick = true

            override fun onTouch(v: View?, event: MotionEvent?): Boolean {
                if (event == null) return false
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        initialX = bubbleParams.x
                        initialY = bubbleParams.y
                        initialTouchX = event.rawX
                        initialTouchY = event.rawY
                        isClick = true
                        return true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        val dx = (event.rawX - initialTouchX).toInt()
                        val dy = (event.rawY - initialTouchY).toInt()
                        if (abs(dx) > 10 || abs(dy) > 10) {
                            isClick = false
                        }
                        bubbleParams.x = initialX + dx
                        bubbleParams.y = initialY + dy
                        try {
                            wm.updateViewLayout(bubbleView, bubbleParams)
                        } catch (_: Exception) {}
                        return true
                    }
                    MotionEvent.ACTION_UP -> {
                        if (isClick) {
                            expandToCalculator()
                        } else {
                            snapBubbleToEdge()
                        }
                        return true
                    }
                }
                return false
            }
        })

        try {
            wm.addView(bubbleView, bubbleParams)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun snapBubbleToEdge() {
        val wm = windowManager ?: return
        val size = Point()
        @Suppress("DEPRECATION")
        wm.defaultDisplay.getSize(size)
        val screenWidth = size.x

        bubbleParams.x = if (bubbleParams.x < screenWidth / 2) 16 else screenWidth - 160
        try {
            wm.updateViewLayout(bubbleView, bubbleParams)
        } catch (_: Exception) {}
    }

    @SuppressLint("ClickableViewAccessibility")
    private fun initCalculator() {
        val wm = windowManager ?: return

        val layoutFlag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        calcParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            layoutFlag,
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL
            x = 0
            y = (28 * resources.displayMetrics.density).toInt()
        }

        val inflater = LayoutInflater.from(this)
        calcView = inflater.inflate(R.layout.floating_calculator_layout, null)

        setupCalculatorControls()
    }

    @SuppressLint("ClickableViewAccessibility")
    private fun setupCalculatorControls() {
        val view = calcView ?: return
        val wm = windowManager ?: return

        // Outside touch dismiss
        view.setOnTouchListener { _, event ->
            if (event.action == MotionEvent.ACTION_OUTSIDE) {
                collapseToBubble()
                true
            } else {
                false
            }
        }

        // Moveable via Drag Handle and Header
        val dragTouchListener = object : View.OnTouchListener {
            private var initialX = 0
            private var initialY = 0
            private var initialTouchX = 0f
            private var initialTouchY = 0f

            override fun onTouch(v: View?, event: MotionEvent?): Boolean {
                if (event == null) return false
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        initialX = calcParams.x
                        initialY = calcParams.y
                        initialTouchX = event.rawX
                        initialTouchY = event.rawY
                        return true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        val dx = (event.rawX - initialTouchX).toInt()
                        val dy = (event.rawY - initialTouchY).toInt()
                        calcParams.x = initialX + dx
                        calcParams.y = initialY - dy
                        try {
                            wm.updateViewLayout(calcView, calcParams)
                        } catch (_: Exception) {}
                        return true
                    }
                }
                return false
            }
        }
        view.findViewById<View>(R.id.calc_drag_handle)?.setOnTouchListener(dragTouchListener)
        view.findViewById<View>(R.id.calc_header)?.setOnTouchListener(dragTouchListener)

        // Close / Collapse Button
        view.findViewById<View>(R.id.btn_calc_close)?.setOnClickListener {
            triggerHaptic(it)
            collapseToBubble()
        }

        // Clear Button
        view.findViewById<View>(R.id.btn_calc_clear)?.setOnClickListener {
            triggerHaptic(it)
            expression = ""
            currentAmount = 0L
            updateCalculatorDisplay()
        }

        // Numpad Buttons (0-9, 00, 000)
        val numIds = mapOf(
            R.id.num_0 to "0",
            R.id.num_00 to "00",
            R.id.num_1 to "1",
            R.id.num_2 to "2",
            R.id.num_3 to "3",
            R.id.num_4 to "4",
            R.id.num_5 to "5",
            R.id.num_6 to "6",
            R.id.num_7 to "7",
            R.id.num_8 to "8",
            R.id.num_9 to "9",
            R.id.num_000 to "000"
        )

        for ((id, strVal) in numIds) {
            view.findViewById<View>(id)?.setOnClickListener {
                triggerHaptic(it)
                onNumpadDigit(strVal)
            }
        }

        // Operator Buttons (÷, ×, -, +, %)
        view.findViewById<View>(R.id.btn_calc_plus)?.setOnClickListener {
            triggerHaptic(it)
            onOperator("+")
        }
        view.findViewById<View>(R.id.btn_calc_minus)?.setOnClickListener {
            triggerHaptic(it)
            onOperator("-")
        }
        view.findViewById<View>(R.id.btn_calc_mul)?.setOnClickListener {
            triggerHaptic(it)
            onOperator("×")
        }
        view.findViewById<View>(R.id.btn_calc_div)?.setOnClickListener {
            triggerHaptic(it)
            onOperator("÷")
        }
        view.findViewById<View>(R.id.btn_calc_percent)?.setOnClickListener {
            triggerHaptic(it)
            if (expression.isNotEmpty() && !expression.endsWith(" ") && !expression.endsWith("%")) {
                expression += "%"
                updateCalculatorDisplay()
            }
        }

        // Backspace Button
        view.findViewById<View>(R.id.num_backspace)?.setOnClickListener {
            triggerHaptic(it)
            if (expression.isNotEmpty()) {
                expression = if (expression.endsWith(" + ") ||
                    expression.endsWith(" - ") ||
                    expression.endsWith(" × ") ||
                    expression.endsWith(" ÷ ")) {
                    expression.substring(0, expression.length - 3)
                } else {
                    expression.substring(0, expression.length - 1)
                }
                updateCalculatorDisplay()
            }
        }

        // Save / Equal Button
        view.findViewById<View>(R.id.btn_calc_save)?.setOnClickListener {
            triggerHaptic(it)
            currentAmount = getCurrentTotal()
            if (currentAmount > 0) {
                saveExpense()
                collapseToBubble()
            }
        }
    }

    private fun triggerHaptic(v: View?) {
        try {
            v?.performHapticFeedback(HapticFeedbackConstants.KEYBOARD_TAP)
        } catch (_: Exception) {}
    }

    private fun onOperator(op: String) {
        if (expression.isNotEmpty()) {
            expression = if (expression.endsWith(" + ") ||
                expression.endsWith(" - ") ||
                expression.endsWith(" × ") ||
                expression.endsWith(" ÷ ")) {
                expression.substring(0, expression.length - 3) + " $op "
            } else {
                expression + " $op "
            }
            updateCalculatorDisplay()
        }
    }

    private fun evaluateExpression(expr: String): Long {
        if (expr.trim().isEmpty()) return 0L
        val rawTokens = expr.trim().split(Regex("\\s+")).filter { it.isNotEmpty() }
        if (rawTokens.isEmpty()) return 0L

        val tokens = mutableListOf<Any>()
        for (t in rawTokens) {
            when (t) {
                "+", "-", "×", "÷", "*", "/" -> tokens.add(if (t == "*") "×" else if (t == "/") "÷" else t)
                else -> {
                    if (t.endsWith("%")) {
                        val clean = t.replace("%", "").replace(".", "").replace(",", "").trim()
                        val v = clean.toDoubleOrNull() ?: 0.0
                        tokens.add(v / 100.0)
                    } else {
                        val clean = t.replace(".", "").replace(",", "").trim()
                        val v = clean.toDoubleOrNull() ?: 0.0
                        tokens.add(v)
                    }
                }
            }
        }

        if (tokens.isEmpty()) return 0L
        if (tokens.last() is String) tokens.removeAt(tokens.size - 1)
        if (tokens.isEmpty()) return 0L

        // Pass 1: × and ÷
        val pass1 = mutableListOf<Any>()
        var i = 0
        while (i < tokens.size) {
            val token = tokens[i]
            if ((token == "×" || token == "÷") && pass1.isNotEmpty() && i + 1 < tokens.size && tokens[i + 1] is Double) {
                val prev = pass1.removeAt(pass1.size - 1) as Double
                val next = tokens[i + 1] as Double
                if (token == "×") {
                    pass1.add(prev * next)
                } else {
                    pass1.add(if (next != 0.0) prev / next else 0.0)
                }
                i += 2
                continue
            }
            pass1.add(token)
            i++
        }

        // Pass 2: + and -
        if (pass1.isEmpty()) return 0L
        var result = if (pass1[0] is Double) pass1[0] as Double else 0.0
        var j = 1
        while (j < pass1.size) {
            val op = pass1[j]
            if (j + 1 < pass1.size && pass1[j + 1] is Double) {
                val v = pass1[j + 1] as Double
                if (op == "+") result += v
                else if (op == "-") result -= v
                j += 2
            } else {
                j++
            }
        }

        return result.toLong().coerceIn(0L, 999999999L)
    }

    private fun getCurrentTotal(): Long = evaluateExpression(expression)

    private fun onNumpadDigit(digit: String) {
        if (digit == "000" || digit == "00") {
            if (expression.isNotEmpty() && !expression.endsWith(" ") && expression.length <= 11) {
                expression += digit
                updateCalculatorDisplay()
            }
        } else {
            if (expression.length <= 14) {
                expression += digit
                updateCalculatorDisplay()
            }
        }
    }

    private fun loadDailyAllowance(): Long {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val allEntries = prefs.all
        val rawDaily = allEntries["flutter.daily_safe"] ?: allEntries["daily_safe"]
        if (rawDaily is Number) {
            return rawDaily.toLong()
        }
        return 50000L
    }

    private fun formatCompactDaily(amount: Long): String {
        return if (amount >= 1000000) {
            val jt = amount.toDouble() / 1000000.0
            val s = String.format(Locale.US, "%.1f", jt).replace(".0", "")
            "Rp ${s}jt"
        } else if (amount >= 1000) {
            val rb = amount / 1000
            "Rp ${rb}rb"
        } else {
            "Rp $amount"
        }
    }

    private fun updateCalculatorDisplay() {
        val view = calcView ?: return
        val display = view.findViewById<TextView>(R.id.tv_calc_display)
        val formula = view.findViewById<TextView>(R.id.tv_calc_formula)
        val remainingText = view.findViewById<TextView>(R.id.tv_calc_remaining)

        val total = getCurrentTotal()
        val isOverBudget = (total > 0 && total > dailyAllowance) || (dailyAllowance <= 0)

        // Clean UI text in header (no badge styling)
        remainingText?.background = null
        remainingText?.setTextColor(Color.parseColor("#8E8E93"))
        remainingText?.text = "Batas Hari Ini: ${formatCompactDaily(dailyAllowance)}"

        val digitColor = if (isOverBudget) Color.parseColor("#E87B7B") else Color.WHITE

        // Format expression with cyan operators and cyan cursor matching Gambar 2
        val ssb = SpannableStringBuilder()
        if (expression.isEmpty()) {
            ssb.append("0")
            val cursorStart = ssb.length
            ssb.append(" |")
            ssb.setSpan(
                ForegroundColorSpan(Color.parseColor("#00E5FF")),
                cursorStart,
                ssb.length,
                Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
            )
            display?.text = ssb
            formula?.visibility = View.GONE
        } else {
            val formatter = NumberFormat.getNumberInstance(Locale("id", "ID"))
            val tokens = Regex("(\\d+|[+\\-×÷%])").findAll(expression)
            for (match in tokens) {
                val token = match.value
                if (token in listOf("+", "-", "×", "÷", "%")) {
                    val start = ssb.length
                    ssb.append(token)
                    ssb.setSpan(
                        ForegroundColorSpan(Color.parseColor("#00E5FF")),
                        start,
                        ssb.length,
                        Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
                    )
                } else {
                    val num = token.toLongOrNull()
                    val formatted = if (num != null) formatter.format(num) else token
                    val start = ssb.length
                    ssb.append(formatted)
                    if (isOverBudget) {
                        ssb.setSpan(
                            ForegroundColorSpan(digitColor),
                            start,
                            ssb.length,
                            Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
                        )
                    }
                }
            }

            // Append cyan cursor
            val cursorStart = ssb.length
            ssb.append(" |")
            ssb.setSpan(
                ForegroundColorSpan(Color.parseColor("#00E5FF")),
                cursorStart,
                ssb.length,
                Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
            )
            display?.text = ssb

            val hasOp = expression.contains("+") ||
                expression.contains("-") ||
                expression.contains("×") ||
                expression.contains("÷") ||
                expression.contains("%")

            if (hasOp && total > 0) {
                formula?.text = formatter.format(total)
                formula?.setTextColor(if (isOverBudget) Color.parseColor("#E87B7B") else Color.parseColor("#8E8E93"))
                formula?.visibility = View.VISIBLE
            } else {
                formula?.visibility = View.GONE
            }
        }
    }

    private fun expandToCalculator() {
        val wm = windowManager ?: return

        // Hide bubble
        try {
            bubbleView?.visibility = View.GONE
        } catch (_: Exception) {}

        dailyAllowance = loadDailyAllowance()
        expression = ""
        currentAmount = 0L
        updateCalculatorDisplay()

        try {
            if (calcView?.isAttachedToWindow == true) {
                wm.updateViewLayout(calcView, calcParams)
            } else {
                wm.addView(calcView, calcParams)
            }
        } catch (_: Exception) {}
    }

    private fun collapseToBubble() {
        val wm = windowManager ?: return

        try {
            if (calcView?.isAttachedToWindow == true) {
                wm.removeView(calcView)
            }
        } catch (_: Exception) {}

        if (isStandalone && !isPermanentBubbleEnabled()) {
            stopSelf()
        } else {
            try {
                bubbleView?.visibility = View.VISIBLE
            } catch (_: Exception) {}
        }
    }

    private fun isPermanentBubbleEnabled(): Boolean {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        return prefs.getBoolean("flutter.floating_bubble_enabled", false)
    }

    private fun saveExpense() {
        if (currentAmount <= 0) return

        try {
            val dbPath = getDatabasePath("jajan_tracker.db")
            var exactRemaining: Long? = null
            var exactDailySafe: Long? = null

            // 1. Insert into SQLite with transaction and reconcile balance directly from DB
            if (dbPath.exists()) {
                val db = SQLiteDatabase.openDatabase(dbPath.path, null, SQLiteDatabase.OPEN_READWRITE)
                try {
                    db.beginTransaction()
                    try {
                        val values = ContentValues().apply {
                            put("amount", currentAmount)
                            put("note", "Jajan")
                            val sdf = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS", Locale.US)
                            put("created_at", sdf.format(Date()))
                        }
                        db.insert("expenses", null, values)
                        db.setTransactionSuccessful()
                    } finally {
                        db.endTransaction()
                    }

                    // Query exact active budget & total expenses to prevent any cache drift
                    var totalBudget = 1500000L
                    var startDate = ""
                    var endDate = ""
                    val budgetCursor = db.rawQuery("SELECT total_budget, start_date, end_date FROM budget WHERE id = 1 LIMIT 1", null)
                    if (budgetCursor.moveToFirst()) {
                        totalBudget = budgetCursor.getLong(0)
                        startDate = budgetCursor.getString(1)
                        endDate = budgetCursor.getString(2)
                    }
                    budgetCursor.close()

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

                    val computed = totalBudget - totalSpent
                    exactRemaining = computed

                    // Calculate days remaining if endDate available
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

            // 2. Update SharedPreferences atomically
            val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val editor = prefs.edit()
            if (exactRemaining != null) {
                editor.putLong("flutter.remaining_balance", exactRemaining)
                if (exactDailySafe != null) {
                    editor.putLong("flutter.daily_safe", exactDailySafe)
                }
            } else {
                val all = prefs.all
                var remaining = 1500000L
                val raw = all["flutter.remaining_balance"] ?: all["remaining_balance"]
                if (raw is Number) {
                    remaining = raw.toLong()
                }
                editor.putLong("flutter.remaining_balance", remaining - currentAmount)
            }
            editor.apply()

            // 3. Update Widget & Quick Tile
            JajanWidgetProvider.updateAllWidgets(this)
            JajanQuickTileService.requestTileUpdate(this)

            val formatter = NumberFormat.getCurrencyInstance(Locale("id", "ID")).apply {
                maximumFractionDigits = 0
            }
            Toast.makeText(this, "✓ Tercatat jajan ${formatter.format(currentAmount)}", Toast.LENGTH_SHORT).show()
        } catch (e: Exception) {
            e.printStackTrace()
        }

        collapseToBubble()
    }

    override fun onDestroy() {
        super.onDestroy()
        isRunning = false
        val wm = windowManager ?: return

        try {
            if (bubbleView != null && bubbleView?.isAttachedToWindow == true) wm.removeView(bubbleView)
            if (calcView != null && calcView?.isAttachedToWindow == true) wm.removeView(calcView)
        } catch (_: Exception) {}
    }

    companion object {
        private const val FOREGROUND_ID = 4001
        private const val BUBBLE_CHANNEL_ID = "jajan_floating_bubble_channel"
        const val EXTRA_OPEN_CALCULATOR = "EXTRA_OPEN_CALCULATOR"
        const val EXTRA_STANDALONE = "EXTRA_STANDALONE"

        var isRunning: Boolean = false

        fun start(context: Context) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(context)) {
                return
            }
            try {
                val intent = Intent(context, FloatingBubbleService::class.java)
                context.startService(intent)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        fun startWithCalculator(context: Context) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(context)) {
                return
            }
            try {
                val intent = Intent(context, FloatingBubbleService::class.java).apply {
                    putExtra(EXTRA_OPEN_CALCULATOR, true)
                    putExtra(EXTRA_STANDALONE, true)
                }
                context.startService(intent)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        fun stop(context: Context) {
            try {
                val intent = Intent(context, FloatingBubbleService::class.java)
                context.stopService(intent)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}
