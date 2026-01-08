import Flutter
import UIKit
import NetworkExtension

public class FlutterDeviceStatePlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var vpnManager: NEVPNManager?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        // Method Channel for one-time VPN checks
        let methodChannel = FlutterMethodChannel(
            name: "flutter_device_state/vpn",
            binaryMessenger: registrar.messenger()
        )
        
        // Event Channel for real-time VPN monitoring
        let eventChannel = FlutterEventChannel(
            name: "flutter_device_state/vpn_state",
            binaryMessenger: registrar.messenger()
        )
        
        let instance = FlutterDeviceStatePlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "checkVpnStatus":
            checkVpnStatus(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    /// Check if VPN is currently active
    private func checkVpnStatus(result: @escaping FlutterResult) {
        if #available(iOS 12.0, *) {
            NEVPNManager.shared().loadFromPreferences { [weak self] error in
                if let error = error {
                    print("Error loading VPN preferences: \(error.localizedDescription)")
                    result(false)
                    return
                }
                
                let isVpnActive = self?.isVpnActive() ?? false
                result(isVpnActive)
            }
        } else {
            // VPN detection not available on iOS < 12.0
            result(false)
        }
    }
    
    /// Determine if VPN is active based on NEVPNManager status
    private func isVpnActive() -> Bool {
        guard #available(iOS 12.0, *) else {
            return false
        }
        
        let vpnManager = NEVPNManager.shared()
        
        // Check VPN connection status
        switch vpnManager.connection.status {
        case .connected, .connecting, .reasserting:
            return true
        case .disconnected, .disconnecting, .invalid:
            return false
        @unknown default:
            return false
        }
    }
    
    // MARK: - FlutterStreamHandler
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        
        if #available(iOS 12.0, *) {
            // Load VPN preferences
            NEVPNManager.shared().loadFromPreferences { [weak self] error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error loading VPN preferences: \(error.localizedDescription)")
                    events(false)
                    return
                }
                
                self.vpnManager = NEVPNManager.shared()
                
                // Send initial state
                events(self.isVpnActive())
                
                // Register for VPN status change notifications
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(self.vpnStatusDidChange),
                    name: .NEVPNStatusDidChange,
                    object: nil
                )
            }
        } else {
            // VPN monitoring not available on iOS < 12.0
            events(false)
        }
        
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        // Remove notification observer
        NotificationCenter.default.removeObserver(
            self,
            name: .NEVPNStatusDidChange,
            object: nil
        )
        
        eventSink = nil
        vpnManager = nil
        
        return nil
    }
    
    /// Called when VPN status changes
    @objc private func vpnStatusDidChange(_ notification: Notification) {
        guard let eventSink = eventSink else { return }
        
        let isVpnActive = self.isVpnActive()
        eventSink(isVpnActive)
    }
}
