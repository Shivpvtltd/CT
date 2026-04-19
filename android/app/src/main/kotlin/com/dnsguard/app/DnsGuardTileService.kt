package com.dnsguard.app

import android.content.Intent
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import androidx.annotation.RequiresApi
import android.content.SharedPreferences

@RequiresApi(Build.VERSION_CODES.N)
class DnsGuardTileService : TileService() {

    private val prefs: SharedPreferences by lazy {
        getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
    }

    override fun onStartListening() {
        super.onStartListening()
        updateTile()
    }

    override fun onClick() {
        super.onClick()
        // Open the app when tile is tapped
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        startActivityAndCollapse(intent)
    }

    private fun updateTile() {
        val tile = qsTile ?: return
        val isEnabled = prefs.getBoolean("flutter.dns_enabled", false)
        val sessionActive = prefs.getBoolean("flutter.session_active", false)

        tile.state = when {
            isEnabled && sessionActive -> Tile.STATE_ACTIVE
            sessionActive && !isEnabled -> Tile.STATE_INACTIVE
            else -> Tile.STATE_UNAVAILABLE
        }

        tile.label = "DNSGuard"
        tile.contentDescription = when (tile.state) {
            Tile.STATE_ACTIVE -> "Ad protection active"
            Tile.STATE_INACTIVE -> "Ad protection off"
            else -> "Session expired"
        }
        tile.updateTile()
    }
}
