package com.example.go_flutter_demo

import android.content.Context
import android.content.Intent
import android.net.VpnService
import android.util.Log
import java.io.File
import java.io.FileOutputStream

class NebulaBridge(private val context: Context) {
    private val TAG = "NebulaBridge"
    
    // Start Nebula VPN
    fun startNebula(config: String, privateKey: String): Boolean {
        Log.d(TAG, "Attempting to start Nebula VPN")
        
        try {
            // Check if VPN permission is granted
            val intent = VpnService.prepare(context)
            if (intent != null) {
                Log.d(TAG, "VPN permission required")
                return false
            }
            
            // Save config and key for the service to use
            saveConfigToFile(config, "nebula_config.yaml")
            saveConfigToFile(privateKey, "nebula_key.txt")
            
            // Start the VPN service
            val serviceIntent = Intent(context, NebulaVpnService::class.java).apply {
                action = NebulaVpnService.ACTION_CONNECT
                putExtra(NebulaVpnService.EXTRA_CONFIG, config)
                putExtra(NebulaVpnService.EXTRA_PRIVATE_KEY, privateKey)
            }
            
            context.startService(serviceIntent)
            
            // The service will handle connection in the background
            // We initially report success if we could start the service
            return true
        } catch (e: Exception) {
            Log.e(TAG, "Error starting Nebula: ${e.message}")
            e.printStackTrace()
            return false
        }
    }
    
    // Stop Nebula VPN
    fun stopNebula(): Boolean {
        Log.d(TAG, "Stopping Nebula VPN")
        try {
            // Send disconnect intent to the service
            val serviceIntent = Intent(context, NebulaVpnService::class.java).apply {
                action = NebulaVpnService.ACTION_DISCONNECT
            }
            
            context.startService(serviceIntent)
            return true
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping Nebula: ${e.message}")
            return false
        }
    }
    
    // Check if VPN is running
    fun isRunning(): Boolean {
        return NebulaVpnService.isRunning()
    }
    
    // Test configuration
    fun testConfig(config: String, privateKey: String): Boolean {
        // Save the config temporarily
        try {
            saveConfigToFile(config, "test_config.yaml")
            saveConfigToFile(privateKey, "test_key.txt")
            
            // For now, we'll just assume the config is valid if it can be saved
            // In a real implementation, you would call the Nebula test method
            return true
        } catch (e: Exception) {
            Log.e(TAG, "Error testing config: ${e.message}")
            return false
        }
    }
    
    // Get hostmap (list of connected peers)
    fun getHostmap(): String {
        // In a real implementation, you would query the Nebula service for this
        // For now, return an empty JSON object or a mock hostmap
        return if (isRunning()) {
            """
            {
              "100.64.0.1": {
                "name": "lighthouse",
                "remote_address": "mza.cosgrid.net:4242",
                "connection_active": true,
                "last_handshake": ${System.currentTimeMillis() / 1000}
              }
            }
            """.trimIndent()
        } else {
            "{}"
        }
    }
    
    // Rebind Nebula (useful when network changes)
    fun rebindNebula(reason: String): Boolean {
        // In a real implementation, you would send a message to the service
        // to rebind its networking
        return isRunning()
    }
    
    // Ping a host in the Nebula network
    fun pingHost(host: String): Boolean {
        try {
            if (!isRunning()) {
                Log.d(TAG, "Can't ping when VPN is not connected")
                return false
            }
            
            // Execute a real ping command
            val process = Runtime.getRuntime().exec("ping -c 3 -W 2 $host")
            val exitValue = process.waitFor()
            Log.d(TAG, "Ping to $host result: $exitValue")
            return exitValue == 0
        } catch (e: Exception) {
            Log.e(TAG, "Error pinging host: ${e.message}")
            return false
        }
    }
    
    // Helper to save config to a file in the app's files directory
    private fun saveConfigToFile(content: String, filename: String) {
        try {
            val file = File(context.filesDir, filename)
            FileOutputStream(file).use { 
                it.write(content.toByteArray())
            }
            Log.d(TAG, "Saved $filename to ${file.absolutePath}")
        } catch (e: Exception) {
            Log.e(TAG, "Error saving $filename: ${e.message}")
        }
    }
}