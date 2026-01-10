package com.example.flutter_device_state.security

import android.app.KeyguardManager
import android.content.Context
import android.os.Build
import android.util.Log

class ScreenLockDetector(private val context: Context) {
    
    companion object {
        private const val TAG = "ScreenLockDetector"
    }
    
    /**
     * Check if device has screen lock enabled
     * 
     * Detects:
     * - PIN
     * - Pattern
     * - Password
     * - Biometric (fingerprint, face)
     */
    fun hasScreenLock(): Boolean {
        return try {
            val keyguardManager = context.getSystemService(Context.KEYGUARD_SERVICE) as? KeyguardManager
            
            if (keyguardManager == null) {
                Log.w(TAG, "KeyguardManager not available")
                return false
            }
            
            val hasScreenLock = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                // Android 6.0+ (API 23+)
                keyguardManager.isDeviceSecure
            } else {
                // Android 5.0-5.1 (API 21-22)
                @Suppress("DEPRECATION")
                keyguardManager.isKeyguardSecure
            }
            
            Log.d(TAG, "Screen lock enabled: $hasScreenLock")
            hasScreenLock
            
        } catch (e: Exception) {
            Log.e(TAG, "Error checking screen lock", e)
            false
        }
    }
    
    /**
     * Check if device is currently locked
     */
    fun isDeviceLocked(): Boolean {
        return try {
            val keyguardManager = context.getSystemService(Context.KEYGUARD_SERVICE) as? KeyguardManager
            
            if (keyguardManager == null) {
                Log.w(TAG, "KeyguardManager not available")
                return false
            }
            
            val isLocked = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
                keyguardManager.isDeviceLocked
            } else {
                @Suppress("DEPRECATION")
                keyguardManager.isKeyguardLocked
            }
            
            Log.d(TAG, "Device currently locked: $isLocked")
            isLocked
            
        } catch (e: Exception) {
            Log.e(TAG, "Error checking if device is locked", e)
            false
        }
    }
    
    /**
     * Get detailed screen lock information
     */
    fun getScreenLockDetails(): Map<String, Boolean> {
        return mapOf(
            "hasScreenLock" to hasScreenLock(),
            "isCurrentlyLocked" to isDeviceLocked()
        )
    }
}
