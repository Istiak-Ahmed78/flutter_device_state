import Flutter
import UIKit
import NetworkExtension

public class FlutterDeviceStatePlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    
    // Method channels
    private static let VPN_CHANNEL = "flutter_device_state/vpn"
    private static let SECURITY_CHANNEL = "flutter_device_state/security"
    
    // Event channels
    private static let VPN_STATE_CHANNEL = "flutter_device_state/vpn_state"
    
    // VPN state stream
    private var eventSink: FlutterEventSink?
    private var vpnManager: NEVPNManager?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = FlutterDeviceStatePlugin()
        
        // Setup VPN method channel
        let vpnMethodChannel = FlutterMethodChannel(
            name: VPN_CHANNEL,
            binaryMessenger: registrar.messenger()
        )
        registrar.addMethodCallDelegate(instance, channel: vpnMethodChannel)
        
        // Setup Security method channel
        let securityMethodChannel = FlutterMethodChannel(
            name: SECURITY_CHANNEL,
            binaryMessenger: registrar.messenger()
        )
        registrar.addMethodCallDelegate(instance, channel: securityMethodChannel)
        
        // Setup VPN event channel
        let vpnEventChannel = FlutterEventChannel(
            name: VPN_STATE_CHANNEL,
            binaryMessenger: registrar.messenger()
        )
        vpnEventChannel.setStreamHandler(instance)
        
        // Initialize VPN manager
        instance.setupVPNManager()
    }
    
    private func setupVPNManager() {
        NEVPNManager.shared().loadFromPreferences { [weak self] error in
            if let error = error {
                print("FlutterDeviceStatePlugin: Error loading VPN preferences - \(error.localizedDescription)")
                return
            }
            self?.vpnManager = NEVPNManager.shared()
            self?.observeVPNStatusChanges()
        }
    }
    
    private func observeVPNStatusChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(vpnStatusDidChange),
            name: .NEVPNStatusDidChange,
            object: nil
        )
    }
    
    @objc private func vpnStatusDidChange() {
        guard let eventSink = eventSink else { return }
        let isConnected = checkVPNStatus()
        eventSink(isConnected)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Handle VPN methods
        if call.method == "checkVpnStatus" {
            handleCheckVpnStatus(result: result)
            return
        }
        
        // Handle Security methods
        switch call.method {
        case "isDeveloperModeEnabled":
            handleIsDeveloperModeEnabled(result: result)
        case "hasScreenLock":
            handleHasScreenLock(result: result)
        case "isEmulator":
            handleIsEmulator(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - VPN Methods
    
    private func handleCheckVpnStatus(result: @escaping FlutterResult) {
        let isConnected = checkVPNStatus()
        result(isConnected)
    }
    
    private func checkVPNStatus() -> Bool {
        guard let vpnManager = vpnManager else {
            // Fallback: check current VPN status without manager
            return NEVPNManager.shared().connection.status == .connected
        }
        
        let status = vpnManager.connection.status
        
        switch status {
        case .connected, .connecting, .reasserting:
            return true
        case .disconnected, .disconnecting, .invalid:
            return false
        @unknown default:
            return false
        }
    }
    
    // MARK: - Security Methods
    
    private func handleIsDeveloperModeEnabled(result: @escaping FlutterResult) {
        let isDeveloperMode = DeveloperModeDetector.isDeveloperModeEnabled()
        result(isDeveloperMode)
    }
    
    private func handleHasScreenLock(result: @escaping FlutterResult) {
        let hasScreenLock = ScreenLockDetector.hasScreenLock()
        result(hasScreenLock)
    }
    
    private func handleIsEmulator(result: @escaping FlutterResult) {
        let isEmulator = EmulatorDetector.isEmulator()
        result(isEmulator)
    }
    
    // MARK: - FlutterStreamHandler
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        
        // Send initial VPN state
        let isConnected = checkVPNStatus()
        events(isConnected)
        
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
