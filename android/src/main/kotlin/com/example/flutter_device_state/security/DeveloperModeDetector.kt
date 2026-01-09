package com.example.flutter_device_state.security

import android.content.Context
import android.os.Build
import android.provider.Settings
import android.util.Log

class DeveloperModeDetector(private val context: Context) {
    
    companion object {
        private const val TAG = "DeveloperModeDetector"
    }
    
    /**
     * Check if developer mode is enabled
     * 
     * Checks multiple indicators:
     * 1. Developer options enabled
     * 2. USB debugging enabled
     * 3. ADB enabled
     */
    fun isDeveloperModeEnabled(): Boolean {
        return try {
            val isDeveloperOptionsEnabled = checkDeveloperOptions()
            val isUsbDebuggingEnabled = checkUsbDebugging()
            val isAdbEnabled = checkAdbEnabled()
            
            Log.d(TAG, "Developer Options: $isDeveloperOptionsEnabled")
            Log.d(TAG, "USB Debugging: $isUsbDebuggingEnabled")
            Log.d(TAG, "ADB Enabled: $isAdbEnabled")
            
            // Consider developer mode enabled if any of these are true
            isDeveloperOptionsEnabled || isUsbDebuggingEnabled || isAdbEnabled
            
        } catch (e: Exception) {
            Log.e(TAG, "Error checking developer mode", e)
            false
        }
    }
    
    /**
     * Check if developer options are enabled
     */
    private fun checkDeveloperOptions(): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                Settings.Global.getInt(
                    context.contentResolver,
                    Settings.Global.DEVELOPMENT_SETTINGS_ENABLED,
                    0
                ) != 0
            } else {
                @Suppress("DEPRECATION")
                Settings.Secure.getInt(
                    context.contentResolver,
                    Settings.Secure.DEVELOPMENT_SETTINGS_ENABLED,
                    0
                ) != 0
            }
        } catch (e: Exception) {
            Log.w(TAG, "Could not check developer options", e)
            false
        }
    }
    
    /**
     * Check if USB debugging is enabled
     */
    private fun checkUsbDebugging(): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                Settings.Global.getInt(
                    context.contentResolver,
                    Settings.Global.ADB_ENABLED,
                    0
                ) != 0
            } else {
                @Suppress("DEPRECATION")
                Settings.Secure.getInt(
                    context.contentResolver,
                    Settings.Secure.ADB_ENABLED,
                    0
                ) != 0
            }
        } catch (e: Exception) {
            Log.w(TAG, "Could not check USB debugging", e)
            false
        }
    }
    
    /**
     * Check if ADB is enabled (alternative method)
     */
    private fun checkAdbEnabled(): Boolean {
        return try {
            Settings.Secure.getInt(
                context.contentResolver,
                Settings.Secure.ADB_ENABLED,
                0
            ) == 1
        } catch (e: Exception) {
            Log.w(TAG, "Could not check ADB enabled", e)
            false
        }
    }
    
    /**
     * Get detailed developer mode information
     */
    fun getDeveloperModeDetails(): Map<String, Boolean> {
        return mapOf(
            "developerOptionsEnabled" to checkDeveloperOptions(),
            "usbDebuggingEnabled" to checkUsbDebugging(),
            "adbEnabled" to checkAdbEnabled()
        )
    }
}
