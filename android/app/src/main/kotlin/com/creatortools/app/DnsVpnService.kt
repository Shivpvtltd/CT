package com.shieldx.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import android.util.Log
import androidx.core.app.NotificationCompat
import java.net.InetAddress

class DnsVpnService : VpnService() {

    companion object {
        const val ACTION_START = "com.shieldx.app.START_DNS"
        const val ACTION_STOP = "com.shieldx.app.STOP_DNS"
        const val CHANNEL_ID = "dns_service_channel"
        const val NOTIFICATION_ID = 2001
        @JvmStatic
        var isRunning = false
            private set
    }

    private var vpnInterface: ParcelFileDescriptor? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                val providerId = intent.getStringExtra("providerId") ?: "adguard"
                val dnsAddresses = intent.getStringArrayListExtra("dnsAddresses")
                    ?: arrayListOf("94.140.14.14", "94.140.15.15")
                startVpn(providerId, dnsAddresses)
            }
            ACTION_STOP -> {
                stopVpn()
            }
        }
        return START_STICKY
    }

    private fun startVpn(providerId: String, dnsAddresses: List<String>) {
        try {
            val builder = Builder()
                .setSession("ShieldX DNS - $providerId")
                .addAddress("10.0.0.2", 32)
                .addRoute("0.0.0.0", 0)
                .setMtu(1500)

            for (dns in dnsAddresses) {
                try {
                    InetAddress.getByName(dns)
                    builder.addDnsServer(dns)
                } catch (_: Exception) {
                    Log.w("DnsVpnService", "Invalid DNS: $dns")
                }
            }

            vpnInterface = builder.establish()
            isRunning = true
            startForeground(NOTIFICATION_ID, buildNotification(providerId, true))
            Log.i("DnsVpnService", "VPN started: $providerId")
        } catch (e: Exception) {
            Log.e("DnsVpnService", "Failed to start VPN", e)
            isRunning = false
        }
    }

    private fun stopVpn() {
        try {
            vpnInterface?.close()
            vpnInterface = null
            isRunning = false
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
            Log.i("DnsVpnService", "VPN stopped")
        } catch (e: Exception) {
            Log.e("DnsVpnService", "Error stopping VPN", e)
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "DNS Protection",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Keeps DNS protection active in background"
                setShowBadge(false)
                enableVibration(false)
                enableLights(false)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(providerId: String, isActive: Boolean): android.app.Notification {
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("ShieldX")
            .setContentText("DNS protection active via $providerId")
            .setSmallIcon(android.R.drawable.ic_menu_compass)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setSilent(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    override fun onDestroy() {
        super.onDestroy()
        stopVpn()
    }
}
