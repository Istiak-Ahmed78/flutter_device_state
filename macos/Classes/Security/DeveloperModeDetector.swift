import Foundation

/// Developer Mode Detection for macOS
/// 
/// Note: macOS does not have a unified "Developer Mode" like Android.
/// There are various developer-related settings and tools, but no single
/// "developer mode" flag to check.
///
/// Possible indicators (not implemented):
/// - Xcode installation
/// - System Integrity Protection (SIP) status
/// - Gatekeeper status
/// - Code signing requirements
///
/// This class exists for API consistency but always returns false.
class DeveloperModeDetector {
    
    /// Check if developer mode is enabled
    /// - Returns: Always returns false on macOS (no unified developer mode)
    static func isDeveloperModeEnabled() -> Bool {
        // macOS does not have a unified "developer mode"
        // Return false as safe default
        return false
    }
    
    /// Check if System Integrity Protection (SIP) is disabled
    /// - Returns: true if SIP is disabled (less secure)
    static func isSIPDisabled() -> Bool {
        let task = Process()
        task.launchPath = "/usr/bin/csrutil"
        task.arguments = ["status"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                // SIP is disabled if output contains "disabled"
                return output.lowercased().contains("disabled")
            }
        } catch {
            print("DeveloperModeDetector: Error checking SIP - \(error.localizedDescription)")
        }
        
        return false
    }
    
    /// Check if Gatekeeper is disabled
    /// - Returns: true if Gatekeeper is disabled (less secure)
    static func isGatekeeperDisabled() -> Bool {
        let task = Process()
        task.launchPath = "/usr/sbin/spctl"
        task.arguments = ["--status"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                // Gatekeeper is disabled if output contains "disabled"
                return output.lowercased().contains("disabled")
            }
        } catch {
            print("DeveloperModeDetector: Error checking Gatekeeper - \(error.localizedDescription)")
        }
        
        return false
    }
    
    /// Check if Xcode is installed
    /// - Returns: true if Xcode is installed
    static func isXcodeInstalled() -> Bool {
        return FileManager.default.fileExists(atPath: "/Applications/Xcode.app")
    }
    
    /// Get developer-related information
    /// - Returns: Dictionary with developer mode info
    static func getDeveloperInfo() -> [String: Any] {
        var info: [String: Any] = [:]
        
        info["isDeveloperModeEnabled"] = isDeveloperModeEnabled()
        info["isSIPDisabled"] = isSIPDisabled()
        info["isGatekeeperDisabled"] = isGatekeeperDisabled()
        info["isXcodeInstalled"] = isXcodeInstalled()
        info["note"] = "macOS does not have a unified developer mode"
        
        #if DEBUG
            info["buildConfiguration"] = "debug"
        #else
            info["buildConfiguration"] = "release"
        #endif
        
        return info
    }
}
