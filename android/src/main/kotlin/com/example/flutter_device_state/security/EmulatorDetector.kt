package com.example.flutter_device_state.security

import android.content.Context
import android.os.Build
import android.telephony.TelephonyManager
import android.util.Log
import java.io.File

class EmulatorDetector(private val context: Context) {
    
    companion object {
        private const val TAG = "EmulatorDetector"
        
        // Known emulator characteristics
        private val KNOWN_EMULATOR_BRANDS = setOf("generic", "unknown", "google_sdk")
        private val KNOWN_EMULATOR_DEVICES = setOf("generic", "generic_x86", "generic_x86_64")
        private val KNOWN_EMULATOR_MODELS = setOf(
            "sdk", "emulator", "android sdk built for x86", "android sdk built for arm",
            "google_sdk", "droid4x", "andy", "ttvm_hdragon"
        )
        private val KNOWN_EMULATOR_MANUFACTURERS = setOf("genymotion", "unknown", "google")
        private val KNOWN_EMULATOR_HARDWARE = setOf("goldfish", "ranchu", "vbox86")
        private val KNOWN_EMULATOR_PRODUCTS = setOf(
            "sdk", "sdk_x86", "sdk_google", "google_sdk", "sdk_gphone64_arm64",
            "sdk_gphone_x86", "vbox86p", "emulator", "simulator"
        )
        
        // Emulator files
        private val EMULATOR_FILES = listOf(
            "/dev/socket/qemud",
            "/dev/qemu_pipe",
            "/system/lib/libc_malloc_debug_qemu.so",
            "/sys/qemu_trace",
            "/system/bin/qemu-props",
            "/dev/socket/genyd",
            "/dev/socket/baseband_genyd"
        )
        
        // Genymotion files
        private val GENYMOTION_FILES = listOf(
            "/dev/socket/genyd",
            "/dev/socket/baseband_genyd"
        )
        
        // x86 emulator files
        private val X86_FILES = listOf(
            "ueventd.android_x86.rc",
            "x86.prop",
            "ueventd.ttVM_x86.rc",
            "init.ttVM_x86.rc",
            "fstab.ttVM_x86",
            "fstab.vbox86",
            "init.vbox86.rc",
            "ueventd.vbox86.rc"
        )
        
        // Andy emulator files
        private val ANDY_FILES = listOf(
            "fstab.andy",
            "ueventd.andy.rc"
        )
        
        // NOX emulator files
        private val NOX_FILES = listOf(
            "fstab.nox",
            "init.nox.rc",
            "ueventd.nox.rc"
        )
    }
    
    /**
     * Check if running on emulator
     * 
     * Uses multiple detection methods:
     * 1. Build properties
     * 2. Hardware characteristics
     * 3. Emulator-specific files
     * 4. Telephony features
     */
    fun isEmulator(): Boolean {
        return try {
            val checks = listOf(
                checkBuildProperties(),
                checkHardwareProperties(),
                checkEmulatorFiles(),
                checkTelephonyFeatures(),
                checkOperatorName()
            )
            
            val detectionCount = checks.count { it }
            
            Log.d(TAG, "Emulator detection checks passed: $detectionCount/${checks.size}")
            Log.d(TAG, "Build Properties: ${checks[0]}")
            Log.d(TAG, "Hardware Properties: ${checks[1]}")
            Log.d(TAG, "Emulator Files: ${checks[2]}")
            Log.d(TAG, "Telephony Features: ${checks[3]}")
            Log.d(TAG, "Operator Name: ${checks[4]}")
            
            // Consider emulator if 2 or more checks pass
            detectionCount >= 2
            
        } catch (e: Exception) {
            Log.e(TAG, "Error detecting emulator", e)
            false
        }
    }
    
    /**
     * Check Build properties for emulator characteristics
     */
    private fun checkBuildProperties(): Boolean {
        val brand = Build.BRAND.lowercase()
        val device = Build.DEVICE.lowercase()
        val model = Build.MODEL.lowercase()
        val manufacturer = Build.MANUFACTURER.lowercase()
        val hardware = Build.HARDWARE.lowercase()
        val product = Build.PRODUCT.lowercase()
        
        Log.d(TAG, "Brand: $brand, Device: $device, Model: $model")
        Log.d(TAG, "Manufacturer: $manufacturer, Hardware: $hardware, Product: $product")
        
        return KNOWN_EMULATOR_BRANDS.contains(brand) ||
                KNOWN_EMULATOR_DEVICES.contains(device) ||
                KNOWN_EMULATOR_MODELS.any { model.contains(it) } ||
                KNOWN_EMULATOR_MANUFACTURERS.contains(manufacturer) ||
                KNOWN_EMULATOR_HARDWARE.contains(hardware) ||
                KNOWN_EMULATOR_PRODUCTS.contains(product)
    }
    
    /**
     * Check hardware properties
     */
    private fun checkHardwareProperties(): Boolean {
        val fingerprint = Build.FINGERPRINT.lowercase()
        
        Log.d(TAG, "Fingerprint: $fingerprint")
        
        return fingerprint.contains("generic") ||
                fingerprint.contains("unknown") ||
                fingerprint.contains("emulator") ||
                fingerprint.contains("sdk") ||
                fingerprint.contains("genymotion") ||
                fingerprint.contains("vbox") ||
                fingerprint.contains("test-keys")
    }
    
    /**
     * Check for emulator-specific files
     */
    private fun checkEmulatorFiles(): Boolean {
        val allEmulatorFiles = EMULATOR_FILES + GENYMOTION_FILES + 
                               X86_FILES + ANDY_FILES + NOX_FILES
        
        val foundFiles = allEmulatorFiles.filter { path ->
            File(path).exists()
        }
        
        if (foundFiles.isNotEmpty()) {
            Log.d(TAG, "Found emulator files: $foundFiles")
        }
        
        return foundFiles.isNotEmpty()
    }
    
    /**
     * Check telephony features
     */
    private fun checkTelephonyFeatures(): Boolean {
        return try {
            val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager
            
            if (telephonyManager == null) {
                Log.w(TAG, "TelephonyManager not available")
                return false
            }
            
            // Emulators often don't have proper telephony features
            val phoneType = telephonyManager.phoneType
            val networkOperator = telephonyManager.networkOperatorName
            
            Log.d(TAG, "Phone Type: $phoneType, Network Operator: $networkOperator")
            
            // Phone type NONE is common in emulators
            phoneType == TelephonyManager.PHONE_TYPE_NONE
            
        } catch (e: Exception) {
            Log.w(TAG, "Could not check telephony features", e)
            false
        }
    }
    
    /**
     * Check operator name
     */
    private fun checkOperatorName(): Boolean {
        return try {
            val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager
            
            if (telephonyManager == null) {
                return false
            }
            
            val operatorName = telephonyManager.networkOperatorName?.lowercase() ?: ""
            
            Log.d(TAG, "Operator Name: $operatorName")
            
            // Emulators often have "android" as operator name
            operatorName.contains("android") || operatorName.isEmpty()
            
        } catch (e: Exception) {
            Log.w(TAG, "Could not check operator name", e)
            false
        }
    }
    
    /**
     * Get detailed emulator detection information
     */
    fun getEmulatorDetails(): Map<String, Any> {
        return mapOf(
            "isEmulator" to isEmulator(),
            "buildProperties" to checkBuildProperties(),
            "hardwareProperties" to checkHardwareProperties(),
            "emulatorFiles" to checkEmulatorFiles(),
            "telephonyFeatures" to checkTelephonyFeatures(),
            "brand" to Build.BRAND,
            "device" to Build.DEVICE,
            "model" to Build.MODEL,
            "manufacturer" to Build.MANUFACTURER,
            "hardware" to Build.HARDWARE,
            "product" to Build.PRODUCT
        )
    }
}
