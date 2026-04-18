package com.shieldx.app

import android.content.Intent
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import androidx.annotation.RequiresApi

@RequiresApi(Build.VERSION_CODES.N)
class DnsQuickSettingsTile : TileService() {

    override fun onStartListening() {
        super.onStartListening()
        updateTile()
    }

    override fun onClick() {
        super.onClick()

        if (DnsVpnService.isRunning) {
            // Stop DNS
            val intent = Intent(this, DnsVpnService::class.java).apply {
                action = DnsVpnService.ACTION_STOP
            }
            startService(intent)
        } else {
            // Start DNS with default provider
            val intent = Intent(this, DnsVpnService::class.java).apply {
                action = DnsVpnService.ACTION_START
                putExtra("providerId", "adguard")
                putStringArrayListExtra(
                    "dnsAddresses",
                    arrayListOf("94.140.14.14", "94.140.15.15")
                )
            }
            startService(intent)
        }

        updateTile()
    }

    private fun updateTile() {
        qsTile?.apply {
            if (DnsVpnService.isRunning) {
                state = Tile.STATE_ACTIVE
                label = "DNS On"
            } else {
                state = Tile.STATE_INACTIVE
                label = "DNS Off"
            }
            updateTile()
        }
    }
}
