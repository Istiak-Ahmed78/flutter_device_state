import Foundation

/// Developer Mode Detection for iOS
/// 
/// Note: iOS does not have a direct "Developer Mode" like Android.
/// There is no official API to detect if Xcode is connected or if the app
/// is running in debug mode from a security perspective.
///
/// Possible workarounds (not recommended for production):
/// - Check if debugger is attached (can be bypassed)
/// - Check provisioning profile type (unreliable)
/// - Check for jailbreak (different security concern)
///
/// This class exists for API consistency but always returns false.
class DeveloperModeDetector {
    
    /// Check if developer mode is enabled
    /// - Returns: Always returns false on iOS (no reliable detection method)
    static func isDeveloperModeEnabled() -> Bool {
        // iOS does not have a reliable way to detect developer mode
        // Return false as safe default
        return false
    }
    
    /// Check if debugger is attached (unreliable)
    /// - Returns: true if debugger appears to be attached
    static func isDebuggerAttached() -> Bool {
        var info = kinfo_proc()
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.stride
        
        let result = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        
        if result != 0 {
            return false
        }
        
        // Check if P_TRACED flag is set
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }
    
    /// Get developer-related information
    /// - Returns: Dictionary with developer mode info
    static func getDeveloperInfo() -> [String: Any] {
        var info: [String: Any] = [:]
        
        info["isDeveloperModeEnabled"] = isDeveloperModeEnabled()
        info["isDebuggerAttached"] = isDebuggerAttached()
        info["note"] = "iOS does not support reliable developer mode detection"
        
        #if DEBUG
            info["buildConfiguration"] = "debug"
        #else
            info["buildConfiguration"] = "release"
        #endif
        
        return info
    }
}
