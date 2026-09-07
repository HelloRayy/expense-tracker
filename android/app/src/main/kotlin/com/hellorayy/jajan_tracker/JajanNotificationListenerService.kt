package com.hellorayy.jajan_tracker

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import androidx.core.app.NotificationCompat
import java.text.NumberFormat
import java.util.Locale

class JajanNotificationListenerService : NotificationListenerService() {

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        try {
            if (sbn == null) return
            val pkg = sbn.packageName ?: return

            // Never process our own notifications
            if (pkg == packageName) return

            val extras = sbn.notification?.extras ?: return
            val title = extras.getCharSequence("android.title")?.toString() ?: ""
            val text = extras.getCharSequence("android.text")?.toString() ?: ""
            val bigText = extras.getCharSequence("android.bigText")?.toString() ?: ""
            val fullContent = "$title $text $bigText"

            if (fullContent.isEmpty()) return

            // Check for payment/transaction confirmation keywords
            val isPayment = PAYMENT_KEYWORDS.any { kw ->
                fullContent.contains(kw, ignoreCase = true)
            }

            if (!isPayment) return

            // Extract amount using regex
            val match = AMOUNT_REGEX.find(fullContent) ?: return
            val rawNum = match.groupValues[1].replace(".", "").split(",")[0]
            val amount = rawNum.toLongOrNull() ?: return

            if (amount <= 0 || amount > 100_000_000L) return

            // Prevent duplicate triggers within 5 seconds for the same amount
            val now = System.currentTimeMillis()
            if (now - lastTriggerTime < 5000 && lastAmount == amount) {
                return
            }
            lastTriggerTime = now
            lastAmount = amount

            val sourceNote = determineSource(pkg, fullContent)
            showActionableTransactionNotification(this, amount, sourceNote)
        } catch (t: Throwable) {
            t.printStackTrace()
        }
    }

    companion object {
        const val TRANSACTION_CHANNEL_ID = "jajan_transaction_detected_channel"
        private const val NOTIFICATION_ID_BASE = 8000

        private var lastTriggerTime: Long = 0
        private var lastAmount: Long = 0

        private val PAYMENT_KEYWORDS = listOf(
            "pembayaran berhasil",
            "berhasil bayar",
            "transaksi berhasil",
            "kamu membayar",
            "berhasil melakukan pembayaran",
            "transaksi qris",
            "berhasil ditransfer",
            "pesanan berhasil dibayar",
            "berhasil melakukan transaksi",
            "pembayaran qris berhasil"
        )

        private val AMOUNT_REGEX = Regex(
            """(?:Rp|IDR)\s*([0-9]{1,3}(?:\.[0-9]{3})*(?:,[0-9]+)?)""",
            RegexOption.IGNORE_CASE
        )

        fun determineSource(pkg: String, content: String): String {
            return when {
                pkg.contains("shopee") -> "ShopeePay"
                pkg.contains("gojek") -> "GoPay"
                pkg.contains("dana") -> "DANA"
                pkg.contains("bca") -> "BCA QRIS"
                pkg.contains("mandiri") -> "Livin QRIS"
                content.contains("qris", ignoreCase = true) -> "QRIS"
                else -> "Jajan"
            }
        }

        fun showActionableTransactionNotification(context: Context, amount: Long, sourceNote: String) {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager ?: return

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    TRANSACTION_CHANNEL_ID,
                    "Deteksi Transaksi Jajan",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Notifikasi interaktif 1-tap untuk mencatat pengeluaran yang terdeteksi"
                    enableLights(true)
                    enableVibration(true)
                }
                nm.createNotificationChannel(channel)
            }

            val formatter = NumberFormat.getCurrencyInstance(Locale("id", "ID")).apply {
                maximumFractionDigits = 0
            }
            val formattedAmount = formatter.format(amount)

            val notifId = NOTIFICATION_ID_BASE + (amount % 1000).toInt()
            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }

            // Action 1: Catat Langsung (1-Tap instant SQLite write)
            val logIntent = Intent(context, NotificationActionReceiver::class.java).apply {
                action = NotificationActionReceiver.ACTION_AUTO_LOG
                putExtra(NotificationActionReceiver.EXTRA_AMOUNT, amount)
                putExtra(NotificationActionReceiver.EXTRA_NOTE, sourceNote)
                putExtra(NotificationActionReceiver.EXTRA_NOTIF_ID, notifId)
            }
            val logPendingIntent = PendingIntent.getBroadcast(
                context,
                notifId * 10 + 1,
                logIntent,
                flags
            )

            // Action 2: Buka Floating Calculator pre-filled
            val calcIntent = Intent(context, NotificationActionReceiver::class.java).apply {
                action = NotificationActionReceiver.ACTION_OPEN_CALC
                putExtra(NotificationActionReceiver.EXTRA_AMOUNT, amount)
                putExtra(NotificationActionReceiver.EXTRA_NOTIF_ID, notifId)
            }
            val calcPendingIntent = PendingIntent.getBroadcast(
                context,
                notifId * 10 + 2,
                calcIntent,
                flags
            )

            // Action 3: Abaikan
            val dismissIntent = Intent(context, NotificationActionReceiver::class.java).apply {
                action = NotificationActionReceiver.ACTION_DISMISS
                putExtra(NotificationActionReceiver.EXTRA_NOTIF_ID, notifId)
            }
            val dismissPendingIntent = PendingIntent.getBroadcast(
                context,
                notifId * 10 + 3,
                dismissIntent,
                flags
            )

            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val allEntries = prefs.all
            var remaining = 1500000L
            val rawRemaining = allEntries["flutter.remaining_balance"] ?: allEntries["remaining_balance"]
            if (rawRemaining is Number) {
                remaining = rawRemaining.toLong()
            }
            val newRemaining = remaining - amount
            val newRemainingStr = formatter.format(newRemaining)

            val title = "💳 Anda telah membayar $formattedAmount ($sourceNote)"
            val subtitle = if (newRemaining >= 0) {
                "Sisa uang jajan Anda jadi: $newRemainingStr"
            } else {
                "⚠️ Overbudget! Sisa uang jajan Anda: $newRemainingStr"
            }

            val builder = NotificationCompat.Builder(context, TRANSACTION_CHANNEL_ID)
                .setSmallIcon(R.drawable.ic_quick_tile)
                .setContentTitle(title)
                .setContentText(subtitle)
                .setStyle(
                    NotificationCompat.BigTextStyle()
                        .setBigContentTitle(title)
                        .bigText(subtitle)
                )
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setCategory(NotificationCompat.CATEGORY_REMINDER)
                .setDefaults(NotificationCompat.DEFAULT_ALL)
                .setAutoCancel(true)
                .setDeleteIntent(dismissPendingIntent)
                .addAction(
                    android.R.drawable.checkbox_on_background,
                    "✓ Catat $formattedAmount",
                    logPendingIntent
                )
                .addAction(
                    android.R.drawable.ic_menu_edit,
                    "✎ Ubah",
                    calcPendingIntent
                )

            nm.notify(notifId, builder.build())
        }
    }
}
