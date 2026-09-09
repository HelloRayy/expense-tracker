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
import android.os.Handler
import android.os.IBinder
import android.os.Looper
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
    private var dailyAllowance: Long = 0L
    private var isStandalone: Boolean = false

    private var cursorPosition: Int = 0
    private var cursorVisible: Boolean = true
    private var cursorBlinkHandler: Handler? = null
    private var cursorBlinkRunnable: Runnable? = null

    private fun startCursorBlink() {
        stopCursorBlink()
        cursorVisible = true
        val handler = Handler(Looper.getMainLooper())
        cursorBlinkHandler = handler
        val runnable = object : Runnable {
            override fun run() {
                cursorVisible = !cursorVisible
                updateCalculatorDisplay()
                cursorBlinkHandler?.postDelayed(this, 500)
            }
        }
        cursorBlinkRunnable = runnable
        handler.postDelayed(runnable, 500)
    }

    private fun stopCursorBlink() {
        cursorBlinkRunnable?.let { cursorBlinkHandler?.removeCallbacks(it) }
        cursorBlinkHandler = null
        cursorBlinkRunnable = null
    }

    private fun resetCursorBlink() {
        cursorVisible = true
        updateCalculatorDisplay()
        cursorBlinkRunnable?.let { r ->
            cursorBlinkHandler?.removeCallbacks(r)
            cursorBlinkHandler?.postDelayed(r, 500)
        }
    }

    private fun mapRenderedOffsetToRawCursor(offset: Int, rendered: String): Int {
        var rawCount = 0
        val safeOffset = offset.coerceIn(0, rendered.length)
        for (i in 0 until safeOffset) {
            val c = rendered[i]
            if (c != '.' && c != '|') {
                rawCount++
            }
        }
        return rawCount.coerceIn(0, expression.length)
    }

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

        val dm = resources.displayMetrics
        val screenWidth = dm.widthPixels
        val maxCalcWidth = (350 * dm.density).toInt()
        val calcWidth = minOf(maxCalcWidth, screenWidth - (24 * dm.density).toInt())

        calcParams = WindowManager.LayoutParams(
            calcWidth,
            WindowManager.LayoutParams.WRAP_CONTENT,
            layoutFlag,
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL
            x = 0
            y = (24 * dm.density).toInt()
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

        // Interactive cursor touch listener on display
        val displayContainer = view.findViewById<View>(R.id.calc_display_container)
        val tvDisplay = view.findViewById<TextView>(R.id.tv_calc_display)

        val displayTouchListener = View.OnTouchListener { v, event ->
            if (event.action == MotionEvent.ACTION_UP) {
                triggerHaptic(v)
                if (expression.isEmpty()) {
                    cursorPosition = 0
                    resetCursorBlink()
                    return@OnTouchListener true
                }

                val layout = tvDisplay?.layout
                if (layout != null && tvDisplay != null) {
                    val location = IntArray(2)
                    tvDisplay.getLocationOnScreen(location)
                    val localX = event.rawX - location[0] - tvDisplay.totalPaddingLeft + tvDisplay.scrollX

                    if (localX <= 0) {
                        cursorPosition = 0
                    } else if (localX >= layout.getLineWidth(0)) {
                        cursorPosition = expression.length
                    } else {
                        val offset = layout.getOffsetForHorizontal(0, localX)
                        val rendered = tvDisplay.text.toString()
                        cursorPosition = mapRenderedOffsetToRawCursor(offset, rendered)
                    }
                    resetCursorBlink()
                }
                true
            } else {
                event.action == MotionEvent.ACTION_DOWN
            }
        }

        displayContainer?.setOnTouchListener(displayTouchListener)
        tvDisplay?.setOnTouchListener(displayTouchListener)

        // Close / Collapse Button
        view.findViewById<View>(R.id.btn_calc_close)?.setOnClickListener {
            triggerHaptic(it)
            collapseToBubble()
        }

        // Clear Button
        view.findViewById<View>(R.id.btn_calc_clear)?.setOnClickListener {
            triggerHaptic(it)
            expression = ""
            cursorPosition = 0
            currentAmount = 0L
            resetCursorBlink()
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
            val left = expression.substring(0, cursorPosition)
            val right = expression.substring(cursorPosition)
            if (left.isNotEmpty() && !left.endsWith(" ") && !left.endsWith("%")) {
                expression = left + "%" + right
                cursorPosition += 1
                resetCursorBlink()
            }
        }

        // Backspace Button
        view.findViewById<View>(R.id.num_backspace)?.setOnClickListener {
            triggerHaptic(it)
            if (expression.isNotEmpty() && cursorPosition > 0) {
                val left = expression.substring(0, cursorPosition)
                val right = expression.substring(cursorPosition)
                if (left.endsWith(" + ") ||
                    left.endsWith(" - ") ||
                    left.endsWith(" × ") ||
                    left.endsWith(" ÷ ")) {
                    expression = left.substring(0, left.length - 3) + right
                    cursorPosition -= 3
                } else if (left.endsWith(" ")) {
                    expression = left.substring(0, left.length - 1) + right
                    cursorPosition -= 1
                } else {
                    expression = left.substring(0, left.length - 1) + right
                    cursorPosition -= 1
                }
                resetCursorBlink()
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
        if (expression.isEmpty()) {
            expression = "0 $op "
            cursorPosition = expression.length
            resetCursorBlink()
            return
        }

        val left = expression.substring(0, cursorPosition)
        val right = expression.substring(cursorPosition)

        if (left.endsWith(" + ") ||
            left.endsWith(" - ") ||
            left.endsWith(" × ") ||
            left.endsWith(" ÷ ")) {
            expression = left.substring(0, left.length - 3) + " $op " + right
            cursorPosition = left.length - 3 + " $op ".length
        } else {
            expression = left + " $op " + right
            cursorPosition += " $op ".length
        }
        resetCursorBlink()
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

    private fun getCurrentOperand(): String {
        val lastSpace = expression.lastIndexOf(' ')
        return if (lastSpace == -1) expression else expression.substring(lastSpace + 1)
    }

    private fun onNumpadDigit(digit: String) {
        val left = expression.substring(0, cursorPosition)
        val right = expression.substring(cursorPosition)

        val lastSpace = left.lastIndexOf(' ')
        val opStart = if (lastSpace == -1) 0 else lastSpace + 1
        val nextSpace = right.indexOf(' ')
        val opEnd = if (nextSpace == -1) expression.length else cursorPosition + nextSpace
        val curr = expression.substring(opStart, opEnd)

        if (digit == "00") {
            if (curr.isNotEmpty() && curr != "0" && curr.length + 2 <= 12) {
                expression = left + "00" + right
                cursorPosition += 2
                resetCursorBlink()
            }
            return
        }

        if (digit == "000") {
            if (curr.isNotEmpty() && curr != "0" && curr.length + 3 <= 12) {
                expression = left + "000" + right
                cursorPosition += 3
                resetCursorBlink()
            }
            return
        }

        if (digit == "0") {
            if (curr == "0") return
            if (curr.length < 12) {
                expression = left + "0" + right
                cursorPosition += 1
                resetCursorBlink()
            }
            return
        }

        // Digits 1-9
        if (curr == "0") {
            expression = expression.substring(0, opStart) + digit + right
            cursorPosition = opStart + 1
            resetCursorBlink()
            return
        }

        if (curr.length < 12 && expression.length < 100) {
            expression = left + digit + right
            cursorPosition += 1
            resetCursorBlink()
        }
    }

    private fun loadDailyAllowance(): Long {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val allEntries = prefs.all
        val rawDaily = allEntries["flutter.daily_safe"] ?: allEntries["daily_safe"]
        if (rawDaily is Number) {
            return rawDaily.toLong()
        }
        return 0L
    }

    private fun formatCompactDaily(amount: Long): String {
        val isNegative = amount < 0
        val absAmount = Math.abs(amount)
        val formatted = if (absAmount >= 1000000) {
            val jt = absAmount.toDouble() / 1000000.0
            val s = String.format(Locale.US, "%.1f", jt).replace(".0", "")
            "Rp ${s}jt"
        } else if (absAmount >= 1000) {
            val rb = absAmount / 1000
            "Rp ${rb}rb"
        } else {
            "Rp $absAmount"
        }
        return if (isNegative) "-$formatted" else formatted
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
        remainingText?.setTextColor(if (dailyAllowance < 0) Color.parseColor("#E87B7B") else Color.parseColor("#8E8E93"))
        remainingText?.text = "Batas Hari Ini: ${formatCompactDaily(dailyAllowance)}"

        val digitColor = if (isOverBudget) Color.parseColor("#E87B7B") else Color.WHITE
        val cursorColor = if (cursorVisible) Color.parseColor("#00E5FF") else Color.TRANSPARENT

        cursorPosition = cursorPosition.coerceIn(0, expression.length)

        // Format expression with cyan operators and blinking interactive cyan cursor
        val ssb = SpannableStringBuilder()
        if (expression.isEmpty()) {
            ssb.append("0")
            val cursorStart = ssb.length
            ssb.append(" |")
            ssb.setSpan(
                ForegroundColorSpan(cursorColor),
                cursorStart,
                ssb.length,
                Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
            )
            display?.text = ssb
            formula?.text = "0"
            formula?.visibility = View.INVISIBLE
        } else {
            val formatter = NumberFormat.getNumberInstance(Locale("id", "ID"))
            val tokens = Regex("(\\d+|[+\\-×÷%]|\\s+)").findAll(expression)
            var currentRawIndex = 0

            fun maybeInsertCursor() {
                if (currentRawIndex == cursorPosition) {
                    val cursorStart = ssb.length
                    ssb.append(" |")
                    ssb.setSpan(
                        ForegroundColorSpan(cursorColor),
                        cursorStart,
                        ssb.length,
                        Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
                    )
                }
            }

            maybeInsertCursor()

            for (match in tokens) {
                val token = match.value
                val tokenStartRaw = currentRawIndex

                if (token in listOf("+", "-", "×", "÷", "%")) {
                    val start = ssb.length
                    ssb.append(token)
                    ssb.setSpan(
                        ForegroundColorSpan(Color.parseColor("#00E5FF")),
                        start,
                        ssb.length,
                        Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
                    )
                    currentRawIndex += token.length
                    maybeInsertCursor()
                } else if (token.all { it.isWhitespace() }) {
                    ssb.append(token)
                    currentRawIndex += token.length
                    maybeInsertCursor()
                } else {
                    val num = token.toLongOrNull()
                    if (num != null) {
                        val formatted = formatter.format(num)
                        var numRawOffset = 0
                        for (ch in formatted) {
                            if (tokenStartRaw + numRawOffset == cursorPosition && ssb.isNotEmpty() && !ssb.endsWith('|')) {
                                val cursorStart = ssb.length
                                ssb.append("|")
                                ssb.setSpan(
                                    ForegroundColorSpan(cursorColor),
                                    cursorStart,
                                    ssb.length,
                                    Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
                                )
                            }
                            val start = ssb.length
                            ssb.append(ch)
                            if (isOverBudget) {
                                ssb.setSpan(
                                    ForegroundColorSpan(digitColor),
                                    start,
                                    ssb.length,
                                    Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
                                )
                            }
                            if (ch != '.') {
                                numRawOffset++
                            }
                        }
                        currentRawIndex += token.length
                        maybeInsertCursor()
                    } else {
                        val start = ssb.length
                        ssb.append(token)
                        if (isOverBudget) {
                            ssb.setSpan(
                                ForegroundColorSpan(digitColor),
                                start,
                                ssb.length,
                                Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
                            )
                        }
                        currentRawIndex += token.length
                        maybeInsertCursor()
                    }
                }
            }

            if (cursorPosition >= expression.length && ssb.indexOf('|') == -1) {
                val cursorStart = ssb.length
                ssb.append(" |")
                ssb.setSpan(
                    ForegroundColorSpan(cursorColor),
                    cursorStart,
                    ssb.length,
                    Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
                )
            }

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
                formula?.text = "0"
                formula?.visibility = View.INVISIBLE
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
        cursorPosition = 0
        currentAmount = 0L
        startCursorBlink()

        val dm = resources.displayMetrics
        val screenWidth = dm.widthPixels
        val maxCalcWidth = (350 * dm.density).toInt()
        calcParams.width = minOf(maxCalcWidth, screenWidth - (24 * dm.density).toInt())

        try {
            if (calcView?.isAttachedToWindow == true) {
                wm.updateViewLayout(calcView, calcParams)
            } else {
                wm.addView(calcView, calcParams)
            }
        } catch (_: Exception) {}
    }

    private fun collapseToBubble() {
        stopCursorBlink()
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

                    // Query adaptive weekly budget: weekly_income & weekly_savings_target
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
                    }

                    val income = if (weeklyIncome > 0) weeklyIncome else totalBudgetFallback
                    val spendableBudget = (income - weeklySavingsTarget).coerceAtLeast(0L)

                    // Calendar day of week (Monday=1..Sunday=7)
                    val calNow = java.util.Calendar.getInstance()
                    val calDay = calNow.get(java.util.Calendar.DAY_OF_WEEK)
                    val dayOfWeek = if (calDay == java.util.Calendar.SUNDAY) 7 else calDay - 1
                    val daysRemainingInWeek = 7 - (dayOfWeek - 1)

                    // Midnight today ISO8601
                    val calToday = java.util.Calendar.getInstance().apply {
                        set(java.util.Calendar.HOUR_OF_DAY, 0)
                        set(java.util.Calendar.MINUTE, 0)
                        set(java.util.Calendar.SECOND, 0)
                        set(java.util.Calendar.MILLISECOND, 0)
                    }
                    val sdfIso = SimpleDateFormat("yyyy-MM-dd'T'00:00:00.000", Locale.US)
                    val todayStart = sdfIso.format(calToday.time)

                    // Week start: default to Monday 00:00:00 of this week
                    val calMon = java.util.Calendar.getInstance().apply {
                        firstDayOfWeek = java.util.Calendar.MONDAY
                        set(java.util.Calendar.DAY_OF_WEEK, java.util.Calendar.MONDAY)
                        set(java.util.Calendar.HOUR_OF_DAY, 0)
                        set(java.util.Calendar.MINUTE, 0)
                        set(java.util.Calendar.SECOND, 0)
                        set(java.util.Calendar.MILLISECOND, 0)
                    }
                    val weekStart = if (startDate.isNotEmpty()) startDate else sdfIso.format(calMon.time)

                    // Sum expenses until yesterday (from weekStart to todayStart)
                    var spentUntilYesterday = 0L
                    val cursorBefore = db.rawQuery(
                        "SELECT SUM(amount) FROM expenses WHERE created_at >= ? AND created_at < ?",
                        arrayOf(weekStart, todayStart)
                    )
                    if (cursorBefore.moveToFirst()) {
                        spentUntilYesterday = cursorBefore.getLong(0)
                    }
                    cursorBefore.close()

                    // Sum expenses today
                    var spentToday = 0L
                    val cursorToday = db.rawQuery(
                        "SELECT SUM(amount) FROM expenses WHERE created_at >= ?",
                        arrayOf(todayStart)
                    )
                    if (cursorToday.moveToFirst()) {
                        spentToday = cursorToday.getLong(0)
                    }
                    cursorToday.close()

                    // Adaptive formula:
                    // sisaBudgetMingguIni = spendableBudget - spentUntilYesterday
                    // batasHarian = floor(sisaBudgetMingguIni / daysRemainingInWeek), rounded to 100
                    val remainingBudget = spendableBudget - spentUntilYesterday
                    val rawAllowance = if (remainingBudget <= 0L || daysRemainingInWeek <= 0) 0L
                        else Math.round((remainingBudget.toDouble() / daysRemainingInWeek) / 100.0) * 100L

                    exactDailySafe = rawAllowance - spentToday
                    exactRemaining = spendableBudget - (spentUntilYesterday + spentToday)
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
                var remaining = 0L
                val raw = all["flutter.remaining_balance"] ?: all["remaining_balance"]
                if (raw is Number) {
                    remaining = raw.toLong()
                }
                editor.putLong("flutter.remaining_balance", remaining - currentAmount)

                var currentSpent = 0L
                val rawSpent = all["flutter.total_spent"] ?: all["total_spent"]
                if (rawSpent is Number) {
                    currentSpent = rawSpent.toLong()
                }
                editor.putLong("flutter.total_spent", currentSpent + currentAmount)
                editor.putLong("total_spent", currentSpent + currentAmount)
            }
            editor.commit()

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
        stopCursorBlink()
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
