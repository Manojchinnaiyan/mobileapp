package com.example.go_flutter_demo

import android.util.Log

class GoKotlinBridge {
    private val TAG = "GoKotlinBridge"
    
    fun callSimpleFunction(input: String): String {
        try {
            val gomainClass = Class.forName("gomain.Gomain")
            // Use the correct method name - lowercase 's'
            val method = gomainClass.getMethod("simpleFunction", String::class.java)
            return method.invoke(null, input) as String
        } catch (e: Exception) {
            Log.e(TAG, "Error calling simpleFunction: ${e.message}")
            e.printStackTrace()
            return "Error: ${e.message}"
        }
    }
    
    fun sumNumbers(a: Int, b: Int): Int {
        try {
            val gomainClass = Class.forName("gomain.Gomain")
            // The parameters for sumNumbers are long, not int
            val method = gomainClass.getMethod("sumNumbers", Long::class.javaPrimitiveType, Long::class.javaPrimitiveType)
            return (method.invoke(null, a.toLong(), b.toLong()) as Long).toInt()
        } catch (e: Exception) {
            Log.e(TAG, "Error calling sumNumbers: ${e.message}")
            e.printStackTrace()
            return -1
        }
    }
}