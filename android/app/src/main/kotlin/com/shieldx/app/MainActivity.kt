package com.shieldx.app

import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.shieldx.app/dns"
    private var pendingResult: MethodChannel.Result? = null

    companion object {
        const val VPN_REQUEST_CODE = 1001
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startDns" -> {
                    val providerId = call.argument<String>("providerId") ?: "adguard"
                    val dnsAddresses = call.argument<List<String>>("dnsAddresses")
                        ?: listOf("94.140.14.14", "94.140.15.15")
                    startDnsService(providerId, dnsAddresses, result)
                }
                "stopDns" -> {
                    stopDnsService(result)
                }
                "getDnsStatus" -> {
                    result.success(DnsVpnService.isRunning)
                }
                "pingDns" -> {
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun startDnsService(
        providerId: String,
        dnsAddresses: List<String>,
        result: MethodChannel.Result
    ) {
        val intent = VpnService.prepare(this)
        if (intent != null) {
            pendingResult = result
            startActivityForResult(intent, VPN_REQUEST_CODE)
        } else {
            launchVpnService(providerId, dnsAddresses)
            result.success(true)
        }
    }

    private fun stopDnsService(result: MethodChannel.Result) {
        val intent = Intent(this, DnsVpnService::class.java).apply {
            action = DnsVpnService.ACTION_STOP
        }
        startService(intent)
        result.success(true)
    }

    private fun launchVpnService(providerId: String, dnsAddresses: List<String>) {
        val intent = Intent(this, DnsVpnService::class.java).apply {
            action = DnsVpnService.ACTION_START
            putExtra("providerId", providerId)
            putStringArrayListExtra("dnsAddresses", ArrayList(dnsAddresses))
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == VPN_REQUEST_CODE) {
            val result = pendingResult
            pendingResult = null
            if (resultCode == RESULT_OK) {
                result?.success(true)
            } else {
                result?.success(false)
            }
        }
    }
}
