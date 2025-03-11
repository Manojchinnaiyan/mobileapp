package com.example.go_flutter_demo

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.go_flutter_demo/go_bridge"
    private lateinit var goBridge: GoKotlinBridge
    private val TAG = "MainActivity"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        goBridge = GoKotlinBridge()
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "simpleFunction" -> {
                        val input = call.argument<String>("input") ?: ""
                        val response = goBridge.callSimpleFunction(input)
                        result.success(response)
                    }
                    "sumNumbers" -> {
                        val a = call.argument<Int>("a") ?: 0
                        val b = call.argument<Int>("b") ?: 0
                        val sum = goBridge.sumNumbers(a, b)
                        result.success(sum)
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
}