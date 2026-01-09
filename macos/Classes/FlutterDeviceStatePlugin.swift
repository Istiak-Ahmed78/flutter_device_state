import FlutterMacOS
import NetworkExtension
import os.log

public class FlutterDeviceStatePlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var vpnManager: NEVPNManager?
    
    private static let logger = OSLog(
        subsystem: "com.example.flutter_device_state",
        category: "VPN"
    )
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(
            name: "flutter_device_state/vpn",
            binaryMessenger: registrar.messenger
        )
        
        let eventChannel = FlutterEventChannel(
            name: "flutter_device_state/vpn_state",
            binaryMessenger: registrar.messenger
        )
        
        let instance = FlutterDeviceStatePlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
        
        os_log("Plugin registered", log: logger, type: .info)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        os_log("Method call received: %{public}@", log: Self.logger, type: .debug, call.method)
        
        switch call.method {
        case "checkVpnStatus":
            checkVpnStatus(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func checkVpnStatus(result: @escaping FlutterResult) {
        os_log("Checking VPN status", log: Self.logger, type: .info)
        
        NEVPNManager.shared().loadFromPreferences { [weak self] error in
            if let error = error {
                os_log("Error loading VPN preferences: %{public}@", 
                       log: Self.logger, 
                       type: .error, 
                       error.localizedDescription)
                result(false)
                return
            }
            
            let isVpnActive = self?.isVpnActive() ?? false
            os_log("VPN status: %{public}@", 
                   log: Self.logger, 
                   type: .info, 
                   isVpnActive ? "active" : "inactive")
            result(isVpnActive)
        }
    }
    
    private func isVpnActive() -> Bool {
        let vpnManager = NEVPNManager.shared()
        let status = vpnManager.connection.status
        
        os_log("VPN connection status: %{public}d", log: Self.logger, type: .debug, status.rawValue)
        
        switch status {
        case .connected, .connecting, .reasserting:
            return true
        case .disconnected, .disconnecting, .invalid:
            return false
        @unknown default:
            os_log("Unknown VPN status: %{public}d", log: Self.logger, type: .warning, status.rawValue)
            return false
        }
    }
    
    // MARK: - FlutterStreamHandler
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        os_log("Event channel listener attached", log: Self.logger, type: .info)
        self.eventSink = events
        
        NEVPNManager.shared().loadFromPreferences { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                os_log("Error loading VPN preferences: %{public}@", 
                       log: Self.logger, 
                       type: .error, 
                       error.localizedDescription)
                events(false)
                return
            }
            
            self.vpnManager = NEVPNManager.shared()
            
            let initialState = self.isVpnActive()
            os_log("Sending initial VPN state: %{public}@", 
                   log: Self.logger, 
                   type: .info, 
                   initialState ? "active" : "inactive")
            events(initialState)
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.vpnStatusDidChange),
                name: .NEVPNStatusDidChange,
                object: nil
            )
            
            os_log("VPN status observer registered", log: Self.logger, type: .debug)
        }
        
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        os_log("Event channel listener cancelled", log: Self.logger, type: .info)
        
        NotificationCenter.default.removeObserver(
            self,
            name: .NEVPNStatusDidChange,
            object: nil
        )
        os_log("VPN status observer removed", log: Self.logger, type: .debug)
        
        eventSink = nil
        vpnManager = nil
        
        return nil
    }
    
    @objc private func vpnStatusDidChange(_ notification: Notification) {
        guard let eventSink = eventSink else { 
            os_log("Event sink is nil, cannot send VPN status", log: Self.logger, type: .warning)
            return 
        }
        
        let isVpnActive = self.isVpnActive()
        os_log("VPN status changed: %{public}@", 
               log: Self.logger, 
               type: .info, 
               isVpnActive ? "active" : "inactive")
        eventSink(isVpnActive)
    }
}
