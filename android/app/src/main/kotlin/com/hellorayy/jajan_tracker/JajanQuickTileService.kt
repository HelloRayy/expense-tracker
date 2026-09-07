package com.hellorayy.jajan_tracker

import android.app.PendingIntent
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.drawable.Icon
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import java.text.NumberFormat
import java.util.Locale

class JajanQuickTileService : TileService() {

    override fun onStartListening() {
        super.onStartListening()
        updateTileState()
    }

    override fun onClick() {
        super.onClick()

        val intent = Intent(this, MainActivity::class.java).apply {
            action = JajanWidgetProvider.ACTION_QUICK_LOG
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            val pendingIntent = PendingIntent.getActivity(
                this,
                2001,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            startActivityAndCollapse(pendingIntent)
        } else {
            @Suppress("DEPRECATION")
            startActivityAndCollapse(intent)
        }
    }

    private fun updateTileState() {
        val tile = qsTile ?: return

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
        val formattedBalance = try {
            formatter.format(remaining)
        } catch (_: Exception) {
            "Rp $remaining"
        }

        tile.label = "Catat Jajan"
        tile.icon = Icon.createWithResource(this, R.drawable.ic_quick_tile)
        tile.state = Tile.STATE_ACTIVE

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            tile.subtitle = formattedBalance
        }

        tile.updateTile()
    }

    companion object {
        fun requestTileUpdate(context: Context) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                try {
                    requestListeningState(
                        context,
                        ComponentName(context, JajanQuickTileService::class.java)
                    )
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
    }
}
