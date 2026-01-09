package com.example.flutter_device_state

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

// Import security detectors
import com.example.flutter_device_state.security.DeveloperModeDetector
import com.example.flutter_device_state.security.ScreenLockDetector
import com.example.flutter_device_state.security.EmulatorDetector

class FlutterDeviceStatePlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
    companion object {
        private const val TAG = "FlutterDeviceState"
        private const val VPN_METHOD_CHANNEL = "flutter_device_state/vpn"
        private const val VPN_EVENT_CHANNEL = "flutter_device_state/vpn_state"
        private const val SECURITY_METHOD_CHANNEL = "flutter_device_state/security" // 🆕 NEW
    }

    private lateinit var context: Context
    private lateinit var vpnMethodChannel: MethodChannel
    private lateinit var vpnEventChannel: EventChannel
    private lateinit var securityMethodChannel: MethodChannel // 🆕 NEW

    private var connectivityManager: ConnectivityManager? = null
    private var networkCallback: ConnectivityManager.NetworkCallback? = null
    private var eventSink: EventChannel.EventSink? = null

    // 🆕 Security detectors
    private var developerModeDetector: DeveloperModeDetector? = null
    private var screenLockDetector: ScreenLockDetector? = null
    private var emulatorDetector: EmulatorDetector? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext

        // VPN channels (existing)
        vpnMethodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, VPN_METHOD_CHANNEL)
        vpnMethodChannel.setMethodCallHandler(this)

        vpnEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, VPN_EVENT_CHANNEL)
        vpnEventChannel.setStreamHandler(this)

        // 🆕 Security channel (new)
        securityMethodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, SECURITY_METHOD_CHANNEL)
        securityMethodChannel.setMethodCallHandler(this)

        // Initialize connectivity manager
        connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager

        // 🆕 Initialize security detectors
        developerModeDetector = DeveloperModeDetector(context)
        screenLockDetector = ScreenLockDetector(context)
        emulatorDetector = EmulatorDetector(context)

        Log.d(TAG, "Plugin attached to engine")
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            // VPN methods (existing)
            "checkVpnStatus" -> {
                Log.d(TAG, "Method call: checkVpnStatus")
                val isVpnActive = checkVpnStatus()
                result.success(isVpnActive)
            }

            // 🆕 Security methods (new)
            "isDeveloperModeEnabled" -> {
                Log.d(TAG, "Method call: isDeveloperModeEnabled")
                val isDeveloperMode = developerModeDetector?.isDeveloperModeEnabled() ?: false
                result.success(isDeveloperMode)
            }

            "hasScreenLock" -> {
                Log.d(TAG, "Method call: hasScreenLock")
                val hasScreenLock = screenLockDetector?.hasScreenLock() ?: false
                result.success(hasScreenLock)
            }

            "isEmulator" -> {
                Log.d(TAG, "Method call: isEmulator")
                val isEmulator = emulatorDetector?.isEmulator() ?: false
                result.success(isEmulator)
            }

            else -> {
                Log.w(TAG, "Unknown method: ${call.method}")
                result.notImplemented()
            }
        }
    }

    // VPN detection (existing code)
    private fun checkVpnStatus(): Boolean {
        return try {
            val cm = connectivityManager ?: return false

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val activeNetwork = cm.activeNetwork ?: return false
                val capabilities = cm.getNetworkCapabilities(activeNetwork) ?: return false

                val hasVpn = capabilities.hasTransport(NetworkCapabilities.TRANSPORT_VPN)
                Log.d(TAG, "VPN status: $hasVpn")
                hasVpn
            } else {
                @Suppress("DEPRECATION")
                val activeNetworkInfo = cm.activeNetworkInfo
                val isVpn = activeNetworkInfo?.type == ConnectivityManager.TYPE_VPN
                Log.d(TAG, "VPN status (legacy): $isVpn")
                isVpn
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error checking VPN status", e)
            false
        }
    }

    // EventChannel.StreamHandler (existing code)
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        Log.d(TAG, "Event channel listener attached")
        eventSink = events

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            startVpnMonitoring()
        } else {
            Log.w(TAG, "VPN monitoring not supported on API < 21")
            eventSink?.success(false)
        }
    }

    override fun onCancel(arguments: Any?) {
        Log.d(TAG, "Event channel listener cancelled")
        stopVpnMonitoring()
        eventSink = null
    }

    private fun startVpnMonitoring() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val cm = connectivityManager ?: return

            // Send initial state
            eventSink?.success(checkVpnStatus())

            // Register network callback
            val request = NetworkRequest.Builder()
                .addTransportType(NetworkCapabilities.TRANSPORT_VPN)
                .build()

            networkCallback = object : ConnectivityManager.NetworkCallback() {
                override fun onAvailable(network: Network) {
                    Log.d(TAG, "VPN network available")
                    eventSink?.success(true)
                }

                override fun onLost(network: Network) {
                    Log.d(TAG, "VPN network lost")
                    eventSink?.success(checkVpnStatus())
                }
            }

            try {
                cm.registerNetworkCallback(request, networkCallback!!)
                Log.d(TAG, "Network callback registered")
            } catch (e: Exception) {
                Log.e(TAG, "Error registering network callback", e)
            }
        }
    }

    private fun stopVpnMonitoring() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            networkCallback?.let { callback ->
                try {
                    connectivityManager?.unregisterNetworkCallback(callback)
                    Log.d(TAG, "Network callback unregistered")
                } catch (e: Exception) {
                    Log.e(TAG, "Error unregistering network callback", e)
                }
            }
            networkCallback = null
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "Plugin detached from engine")
        
        vpnMethodChannel.setMethodCallHandler(null)
        vpnEventChannel.setStreamHandler(null)
        securityMethodChannel.setMethodCallHandler(null) // 🆕 NEW
        
        stopVpnMonitoring()
        
        // 🆕 Clean up security detectors
        developerModeDetector = null
        screenLockDetector = null
        emulatorDetector = null
    }
}
