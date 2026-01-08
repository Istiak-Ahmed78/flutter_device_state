package com.example.flutter_device_state

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterDeviceStatePlugin */
class FlutterDeviceStatePlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var context: Context
    private var eventSink: EventChannel.EventSink? = null
    private var networkCallback: ConnectivityManager.NetworkCallback? = null
    
    // Handler for posting to main thread - CRITICAL FIX
    private val mainHandler = Handler(Looper.getMainLooper())

    companion object {
        private const val TAG = "FlutterDeviceState"
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "Plugin attached to engine")
        context = flutterPluginBinding.applicationContext

        methodChannel = MethodChannel(
            flutterPluginBinding.binaryMessenger,
            "flutter_device_state/vpn"
        )
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(
            flutterPluginBinding.binaryMessenger,
            "flutter_device_state/vpn_state"
        )
        eventChannel.setStreamHandler(this)
        
        Log.d(TAG, "Channels registered successfully")
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.d(TAG, "Method call received: ${call.method}")
        
        when (call.method) {
            "checkVpnStatus" -> {
                try {
                    val isVpnActive = isVpnActive()
                    Log.d(TAG, "VPN status checked: $isVpnActive")
                    result.success(isVpnActive)
                } catch (e: Exception) {
                    Log.e(TAG, "Error checking VPN status", e)
                    result.error(
                        "VPN_CHECK_ERROR",
                        "Failed to check VPN status: ${e.message}",
                        null
                    )
                }
            }
            else -> {
                Log.w(TAG, "Method not implemented: ${call.method}")
                result.notImplemented()
            }
        }
    }

    private fun isVpnActive(): Boolean {
        Log.d(TAG, "Checking VPN status, SDK: ${Build.VERSION.SDK_INT}")
        
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            Log.w(TAG, "VPN detection not available on API < 21")
            return false
        }

        val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) 
            as? ConnectivityManager
        
        if (connectivityManager == null) {
            Log.e(TAG, "ConnectivityManager is null")
            return false
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val activeNetwork = connectivityManager.activeNetwork
            if (activeNetwork == null) {
                Log.d(TAG, "No active network")
                return false
            }
            
            val capabilities = connectivityManager.getNetworkCapabilities(activeNetwork)
            if (capabilities == null) {
                Log.d(TAG, "No network capabilities")
                return false
            }
            
            val hasNotVpn = capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_VPN)
            val isVpn = !hasNotVpn
            
            Log.d(TAG, "Network capabilities - NOT_VPN: $hasNotVpn, isVPN: $isVpn")
            return isVpn
        } else {
            val allNetworks = connectivityManager.allNetworks
            Log.d(TAG, "Checking ${allNetworks.size} networks")
            
            for (network in allNetworks) {
                val capabilities = connectivityManager.getNetworkCapabilities(network)
                if (capabilities != null) {
                    val hasNotVpn = capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_VPN)
                    Log.d(TAG, "Network $network - NOT_VPN: $hasNotVpn")
                    
                    if (!hasNotVpn) {
                        return true
                    }
                }
            }
            return false
        }
    }

    /**
     * CRITICAL: Send VPN state to Flutter on the main thread
     * Network callbacks run on background thread, must post to main thread
     */
    private fun sendVpnState(isActive: Boolean) {
        mainHandler.post {
            try {
                eventSink?.success(isActive)
                Log.d(TAG, "VPN state sent to Flutter: $isActive")
            } catch (e: Exception) {
                Log.e(TAG, "Error sending VPN state", e)
            }
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        Log.d(TAG, "Event channel listener attached")
        eventSink = events

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            Log.w(TAG, "VPN monitoring not available on API < 21")
            eventSink?.success(false)
            return
        }

        // Send initial state (already on main thread here)
        val initialState = isVpnActive()
        Log.d(TAG, "Sending initial VPN state: $initialState")
        eventSink?.success(initialState)

        val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) 
            as? ConnectivityManager

        if (connectivityManager != null) {
            networkCallback = object : ConnectivityManager.NetworkCallback() {
                override fun onAvailable(network: Network) {
                    super.onAvailable(network)
                    val state = isVpnActive()
                    Log.d(TAG, "Network available, VPN state: $state")
                    sendVpnState(state)  // ✅ FIXED: Post to main thread
                }

                override fun onLost(network: Network) {
                    super.onLost(network)
                    val state = isVpnActive()
                    Log.d(TAG, "Network lost, VPN state: $state")
                    sendVpnState(state)  // ✅ FIXED: Post to main thread
                }

                override fun onCapabilitiesChanged(
                    network: Network,
                    networkCapabilities: NetworkCapabilities
                ) {
                    super.onCapabilitiesChanged(network, networkCapabilities)
                    val state = isVpnActive()
                    Log.d(TAG, "Network capabilities changed, VPN state: $state")
                    sendVpnState(state)  // ✅ FIXED: Post to main thread
                }
            }

            val networkRequest = NetworkRequest.Builder().build()
            connectivityManager.registerNetworkCallback(networkRequest, networkCallback!!)
            Log.d(TAG, "Network callback registered")
        } else {
            Log.e(TAG, "ConnectivityManager is null, cannot register callback")
        }
    }

    override fun onCancel(arguments: Any?) {
        Log.d(TAG, "Event channel listener cancelled")
        
        val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) 
            as? ConnectivityManager

        networkCallback?.let {
            try {
                connectivityManager?.unregisterNetworkCallback(it)
                Log.d(TAG, "Network callback unregistered")
            } catch (e: Exception) {
                Log.e(TAG, "Error unregistering callback", e)
            }
        }

        networkCallback = null
        eventSink = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "Plugin detached from engine")
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }
}
