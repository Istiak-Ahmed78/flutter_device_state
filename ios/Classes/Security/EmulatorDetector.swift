import Foundation

/// Detects if the app is running on iOS Simulator
class EmulatorDetector {
    
    /// Check if running on iOS Simulator
    /// - Returns: true if running on simulator, false if on physical device
    static func isEmulator() -> Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }
    
    /// Get detailed emulator/device information
    /// - Returns: Dictionary with device details
    static func getDeviceInfo() -> [String: Any] {
        var info: [String: Any] = [:]
        
        // Check if simulator
        info["isSimulator"] = isEmulator()
        
        // Get device model
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        info["deviceModel"] = identifier
        
        // Simulator models contain "x86_64" or "arm64" for M1 Macs
        if identifier.contains("x86_64") || identifier.contains("i386") {
            info["architecture"] = "x86_64"
            info["isSimulator"] = true
        } else if isEmulator() {
            info["architecture"] = "arm64"
        } else {
            info["architecture"] = "arm"
        }
        
        return info
    }
    
    /// Check if device is jailbroken (additional security check)
    /// - Returns: true if device appears to be jailbroken
    static func isJailbroken() -> Bool {
        // Check for common jailbreak files
        let jailbreakPaths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/",
            "/private/var/lib/cydia",
            "/private/var/mobile/Library/SBSettings/Themes",
            "/private/var/tmp/cydia.log",
            "/private/var/stash",
            "/usr/libexec/sftp-server",
            "/usr/bin/ssh"
        ]
        
        for path in jailbreakPaths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        
        // Check if can write to system directory (jailbroken devices allow this)
        let testPath = "/private/jailbreak_test.txt"
        do {
            try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: testPath)
            return true
        } catch {
            // Cannot write - device is not jailbroken
        }
        
        // Check if Cydia URL scheme is available
        if let url = URL(string: "cydia://package/com.example.package") {
            if UIApplication.shared.canOpenURL(url) {
                return true
            }
        }
        
        return false
    }
}
