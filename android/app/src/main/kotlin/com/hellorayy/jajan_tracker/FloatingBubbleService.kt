package com.hellorayy.jajan_tracker

import android.annotation.SuppressLint
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import android.graphics.PixelFormat
import android.graphics.Point
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.view.Gravity
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
        val notification = NotificationCompat.Builder(this, BUBBLE_CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_quick_tile)
            .setContentTitle("Floating Bubble Jajan Aktif")
            .setContentText("Ketuk gelembung di layar untuk kalkulator jajan instan")
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()

        startForeground(FOREGROUND_ID, notification)
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
                            // Snap to nearest screen edge (left or right)
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
            gravity = Gravity.CENTER
        }

        val inflater = LayoutInflater.from(this)
        calcView = inflater.inflate(R.layout.floating_calculator_layout, null)

        setupCalculatorControls()
    }

    private fun setupCalculatorControls() {
        val view = calcView ?: return

        // Close / Collapse Button
        view.findViewById<View>(R.id.btn_calc_close)?.setOnClickListener {
            collapseToBubble()
        }

        // Clear Button
        view.findViewById<View>(R.id.btn_calc_clear)?.setOnClickListener {
            currentAmount = 0L
            updateCalculatorDisplay()
        }

        // Numpad Buttons
        val numIds = mapOf(
            R.id.num_0 to "0",
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
                onNumpadDigit(strVal)
            }
        }

        // Backspace Button
        view.findViewById<View>(R.id.num_backspace)?.setOnClickListener {
            val s = currentAmount.toString()
            currentAmount = if (s.length > 1) {
                s.substring(0, s.length - 1).toLongOrNull() ?: 0L
            } else {
                0L
            }
            updateCalculatorDisplay()
        }

        // Preset Chips
        view.findViewById<View>(R.id.chip_5k)?.setOnClickListener { onAddPreset(5000L) }
        view.findViewById<View>(R.id.chip_10k)?.setOnClickListener { onAddPreset(10000L) }
        view.findViewById<View>(R.id.chip_20k)?.setOnClickListener { onAddPreset(20000L) }
        view.findViewById<View>(R.id.chip_50k)?.setOnClickListener { onAddPreset(50000L) }

        // Save Button
        view.findViewById<View>(R.id.btn_calc_save)?.setOnClickListener {
            saveExpense()
        }
    }

    private fun onNumpadDigit(digit: String) {
        val currentStr = if (currentAmount == 0L) "" else currentAmount.toString()
        if (currentStr.length + digit.length <= 9) { // Up to 999 million
            currentAmount = (currentStr + digit).toLongOrNull() ?: currentAmount
            updateCalculatorDisplay()
        }
    }

    private fun onAddPreset(nominal: Long) {
        currentAmount += nominal
        updateCalculatorDisplay()
    }

    private fun updateCalculatorDisplay() {
        val view = calcView ?: return
        val display = view.findViewById<TextView>(R.id.tv_calc_display)

        val formatter = NumberFormat.getCurrencyInstance(Locale("id", "ID")).apply {
            maximumFractionDigits = 0
        }
        display?.text = formatter.format(currentAmount)
    }

    private fun expandToCalculator() {
        val wm = windowManager ?: return

        // Hide bubble
        try {
            bubbleView?.visibility = View.GONE
        } catch (_: Exception) {}

        // Read remaining balance for header
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val allEntries = prefs.all
        var remaining = 1500000L
        val rawRemaining = allEntries["flutter.remaining_balance"] ?: allEntries["remaining_balance"]
        if (rawRemaining is Number) {
            remaining = rawRemaining.toLong()
        }

        val formatter = NumberFormat.getCurrencyInstance(Locale("id", "ID")).apply {
            maximumFractionDigits = 0
        }
        calcView?.findViewById<TextView>(R.id.tv_calc_remaining)?.text = "Sisa: ${formatter.format(remaining)}"

        currentAmount = 0L
        updateCalculatorDisplay()

        try {
            wm.addView(calcView, calcParams)
        } catch (_: Exception) {}
    }

    private fun collapseToBubble() {
        val wm = windowManager ?: return

        try {
            wm.removeView(calcView)
        } catch (_: Exception) {}

        try {
            bubbleView?.visibility = View.VISIBLE
        } catch (_: Exception) {}
    }

    private fun saveExpense() {
        if (currentAmount <= 0) return

        try {
            // 1. Insert directly into SQLite database jajan_tracker.db
            val dbPath = getDatabasePath("jajan_tracker.db")
            if (dbPath.exists()) {
                val db = SQLiteDatabase.openDatabase(dbPath.path, null, SQLiteDatabase.OPEN_READWRITE)
                val values = ContentValues().apply {
                    put("amount", currentAmount)
                    put("note", "Jajan")
                    val sdf = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS", Locale.US)
                    put("created_at", sdf.format(Date()))
                }
                db.insert("expenses", null, values)
                db.close()
            }

            // 2. Update SharedPreferences
            val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val all = prefs.all
            var remaining = 1500000L
            val raw = all["flutter.remaining_balance"] ?: all["remaining_balance"]
            if (raw is Number) {
                remaining = raw.toLong()
            }
            val newRemaining = remaining - currentAmount
            prefs.edit().putLong("flutter.remaining_balance", newRemaining).apply()

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
            if (bubbleView != null) wm.removeView(bubbleView)
            if (calcView != null && calcView?.isAttachedToWindow == true) wm.removeView(calcView)
        } catch (_: Exception) {}
    }

    companion object {
        private const val FOREGROUND_ID = 4001
        private const val BUBBLE_CHANNEL_ID = "jajan_floating_bubble_channel"
        var isRunning: Boolean = false

        fun start(context: Context) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(context)) {
                return
            }
            val intent = Intent(context, FloatingBubbleService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            val intent = Intent(context, FloatingBubbleService::class.java)
            context.stopService(intent)
        }
    }
}
