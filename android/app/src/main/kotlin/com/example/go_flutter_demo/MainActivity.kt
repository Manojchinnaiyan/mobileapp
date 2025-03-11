package com.example.go_flutter_demo

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.net.VpnService
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.go_flutter_demo/nebula_bridge"
    private lateinit var nebulaBridge: NebulaBridge
    private val TAG = "MainActivity"
    private val VPN_REQUEST_CODE = 24601

    // Operation info for when we need VPN permission
    private var pendingConfig: String? = null
    private var pendingKey: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        nebulaBridge = NebulaBridge(context)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "startNebula" -> {
                        val config = call.argument<String>("config") ?: ""
                        val key = call.argument<String>("key") ?: ""
                        
                        // Check if VPN permission is needed
                        val intent = VpnService.prepare(context)
                        if (intent != null) {
                            // Store the operation for when permission is granted
                            pendingConfig = config
                            pendingKey = key
                            startActivityForResult(intent, VPN_REQUEST_CODE)
                            result.success(false) // Not started yet, waiting for permission
                        } else {
                            // No permission needed, proceed
                            val success = nebulaBridge.startNebula(config, key)
                            result.success(success)
                        }
                    }
                    "stopNebula" -> {
                        val success = nebulaBridge.stopNebula()
                        result.success(success)
                    }
                    "testConfig" -> {
                        val config = call.argument<String>("config") ?: ""
                        val key = call.argument<String>("key") ?: ""
                        
                        val isValid = nebulaBridge.testConfig(config, key)
                        result.success(isValid)
                    }
                    "getHostmap" -> {
                        val hostmap = nebulaBridge.getHostmap()
                        result.success(hostmap)
                    }
                    "rebindNebula" -> {
                        val reason = call.argument<String>("reason") ?: "network_change"
                        
                        val success = nebulaBridge.rebindNebula(reason)
                        result.success(success)
                    }
                    "pingHost" -> {
                        val host = call.argument<String>("host") ?: ""
                        
                        val success = nebulaBridge.pingHost(host)
                        result.success(success)
                    }
                    "checkConnectionStatus" -> {
                        val isConnected = nebulaBridge.checkConnectionStatus()
                        result.success(isConnected)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error: ${e.message}")
                result.error("ERROR", e.message, null)
            }
        }
    }
    
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        if (requestCode == VPN_REQUEST_CODE && resultCode == RESULT_OK) {
            // VPN permission granted, execute the pending operation
            val config = pendingConfig
            val key = pendingKey
            
            if (config != null && key != null) {
                nebulaBridge.startNebula(config, key)
            }
            
            // Clear pending operation
            pendingConfig = null
            pendingKey = null
        }
    }
}