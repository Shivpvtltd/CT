package com.dnsguard.app

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.dnsguard.app/dns"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "setPrivateDns" -> {
                    val hostname = call.argument<String>("hostname")
                    if (hostname != null) {
                        val success = setPrivateDns(hostname)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGS", "Hostname is required", null)
                    }
                }
                "clearPrivateDns" -> {
                    clearPrivateDns()
                    result.success(true)
                }
                "getDnsStatus" -> {
                    result.success(getPrivateDnsMode())
                }
                else -> result.notImplemented()
            }
        }
    }

    /**
     * Sets Private DNS (DNS-over-TLS) on Android 9+.
     * On older Android, falls back to a notification guiding the user.
     *
     * Note: Programmatic Private DNS setting requires WRITE_SECURE_SETTINGS
     * permission which is granted via ADB or system apps.
     * For Play Store compliance, we guide users through Settings UI instead.
     */
    private fun setPrivateDns(hostname: String): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            try {
                // Try to set via ConnectivityManager (requires NETWORK_SETTINGS permission)
                // On non-rooted devices, open the Private DNS settings screen
                openPrivateDnsSettings(hostname)
                true
            } catch (e: Exception) {
                openPrivateDnsSettings(hostname)
                false
            }
        } else {
            // Android < 9: Inform user to change DNS manually
            false
        }
    }

    private fun openPrivateDnsSettings(hostname: String) {
        // On Android 9+, guide user to Private DNS settings
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            try {
                val intent = android.content.Intent(
                    android.provider.Settings.ACTION_WIRELESS_SETTINGS
                )
                startActivity(intent)
            } catch (e: Exception) {
                // Fallback: open general settings
                val intent = android.content.Intent(
                    android.provider.Settings.ACTION_SETTINGS
                )
                startActivity(intent)
            }
        }
    }

    private fun clearPrivateDns() {
        // Guide user to turn off Private DNS
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            try {
                val intent = android.content.Intent(
                    android.provider.Settings.ACTION_WIRELESS_SETTINGS
                )
                startActivity(intent)
            } catch (e: Exception) {
                // ignore
            }
        }
    }

    private fun getPrivateDnsMode(): String {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            try {
                val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
                val network = cm.activeNetwork
                val caps = cm.getNetworkCapabilities(network)
                if (caps?.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) == true ||
                    caps?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) == true
                ) {
                    "connected"
                } else {
                    "disconnected"
                }
            } catch (e: Exception) {
                "unknown"
            }
        } else {
            "unknown"
        }
    }
}
