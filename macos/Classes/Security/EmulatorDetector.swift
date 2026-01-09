import Foundation

/// Emulator Detection for macOS
/// 
/// Note: The concept of "emulator" doesn't apply to macOS.
/// macOS apps run on real Mac hardware (Intel or Apple Silicon).
///
/// However, we can detect:
/// - Virtual Machines (VMware, Parallels, VirtualBox)
/// - Rosetta 2 translation (Intel apps on Apple Silicon)
///
/// This class exists for API consistency but always returns false.
class EmulatorDetector {
    
    /// Check if running in an emulator
    /// - Returns: Always returns false (N/A for macOS)
    static func isEmulator() -> Bool {
        // Concept doesn't apply to macOS
        // Could check for VM instead
        return isRunningInVM()
    }
    
    /// Check if running in a Virtual Machine
    /// - Returns: true if running in VM (VMware, Parallels, VirtualBox)
    static func isRunningInVM() -> Bool {
        // Check for VM-specific hardware identifiers
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        // Check for VM indicators
        let vmIndicators = ["vmware", "parallels", "virtualbox", "qemu"]
        let identifierLower = identifier.lowercased()
        
        for indicator in vmIndicators {
            if identifierLower.contains(indicator) {
                return true
            }
        }
        
        // Check for VM-specific files or processes
        let vmPaths = [
            "/Library/Application Support/VMware Tools",
            "/Library/Application Support/Parallels",
            "/Applications/Parallels Desktop.app"
        ]
        
        for path in vmPaths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        
        return false
    }
    
    /// Check if running under Rosetta 2 (Intel app on Apple Silicon)
    /// - Returns: true if running under Rosetta 2 translation
    static func isRunningUnderRosetta() -> Bool {
        var ret: Int32 = 0
        var size = MemoryLayout<Int32>.size
        
        let result = sysctlbyname("sysctl.proc_translated", &ret, &size, nil, 0)
        
        if result == 0 {
            return ret == 1
        }
        
        return false
    }
    
    /// Get device architecture
    /// - Returns: "arm64" for Apple Silicon, "x86_64" for Intel
    static func getArchitecture() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return identifier
    }
    
    /// Get detailed device information
    /// - Returns: Dictionary with device details
    static func getDeviceInfo() -> [String: Any] {
        var info: [String: Any] = [:]
        
        info["isEmulator"] = isEmulator()
        info["isVM"] = isRunningInVM()
        info["isRosetta"] = isRunningUnderRosetta()
        info["architecture"] = getArchitecture()
        info["note"] = "macOS runs on real hardware; can detect VMs instead"
        
        return info
    }
}
