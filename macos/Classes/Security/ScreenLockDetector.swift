import Foundation
import LocalAuthentication

/// Detects if the Mac has screen lock (password, Touch ID) enabled
class ScreenLockDetector {
    
    /// Check if Mac has any form of screen lock enabled
    /// - Returns: true if password or Touch ID is set up
    static func hasScreenLock() -> Bool {
        let context = LAContext()
        var error: NSError?
        
        // Check if Mac can evaluate biometric or password authentication
        let canEvaluate = context.canEvaluatePolicy(
            .deviceOwnerAuthentication,
            error: &error
        )
        
        if let error = error {
            // Log error for debugging
            print("ScreenLockDetector: Error checking screen lock - \(error.localizedDescription)")
            
            // Handle specific errors
            if let laError = error as? LAError {
                switch laError.code {
                case .passcodeNotSet:
                    return false
                case .biometryNotAvailable:
                    // Touch ID not available, but password might be set
                    return checkPasswordOnly()
                case .biometryNotEnrolled:
                    // Touch ID not enrolled, check password
                    return checkPasswordOnly()
                default:
                    // For other errors, assume no screen lock for safety
                    return false
                }
            }
            
            return false
        }
        
        return canEvaluate
    }
    
    /// Check if Mac has password set (without Touch ID requirement)
    /// - Returns: true if password is set
    private static func checkPasswordOnly() -> Bool {
        let context = LAContext()
        var error: NSError?
        
        // Try to evaluate with device owner authentication (includes password)
        let canEvaluate = context.canEvaluatePolicy(
            .deviceOwnerAuthentication,
            error: &error
        )
        
        // If no error, password is set
        return canEvaluate
    }
    
    /// Check if automatic login is disabled (more secure)
    /// - Returns: true if automatic login is disabled
    static func isAutoLoginDisabled() -> Bool {
        // Check if automatic login is disabled
        // This is a security best practice on macOS
        let task = Process()
        task.launchPath = "/usr/bin/defaults"
        task.arguments = ["read", "/Library/Preferences/com.apple.loginwindow", "autoLoginUser"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            // If the command succeeds, auto-login is enabled (less secure)
            return task.terminationStatus != 0
        } catch {
            // If command fails, assume auto-login is disabled (more secure)
            return true
        }
    }
    
    /// Check if FileVault (disk encryption) is enabled
    /// - Returns: true if FileVault is enabled
    static func isFileVaultEnabled() -> Bool {
        let task = Process()
        task.launchPath = "/usr/bin/fdesetup"
        task.arguments = ["status"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                return output.contains("FileVault is On")
            }
        } catch {
            print("ScreenLockDetector: Error checking FileVault - \(error.localizedDescription)")
        }
        
        return false
    }
    
    /// Get detailed screen lock information
    /// - Returns: Dictionary with screen lock details
    static func getScreenLockInfo() -> [String: Any] {
        let context = LAContext()
        var info: [String: Any] = [:]
        
        // Check if Touch ID is available
        var error: NSError?
        let biometryAvailable = context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        )
        
        info["hasTouchID"] = biometryAvailable
        
        // Determine biometry type (Touch ID on Mac)
        if #available(macOS 10.13.2, *) {
            switch context.biometryType {
            case .none:
                info["biometryType"] = "none"
            case .touchID:
                info["biometryType"] = "touchID"
            @unknown default:
                info["biometryType"] = "unknown"
            }
        } else {
            info["biometryType"] = "unknown"
        }
        
        // Check if password is set
        info["hasPassword"] = hasScreenLock()
        
        // Additional macOS-specific security checks
        info["autoLoginDisabled"] = isAutoLoginDisabled()
        info["fileVaultEnabled"] = isFileVaultEnabled()
        
        return info
    }
    
    /// Check if screen saver password is required
    /// - Returns: true if password is required after screen saver
    static func isScreenSaverPasswordRequired() -> Bool {
        let task = Process()
        task.launchPath = "/usr/bin/defaults"
        task.arguments = ["read", "com.apple.screensaver", "askForPassword"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                return output == "1"
            }
        } catch {
            print("ScreenLockDetector: Error checking screen saver password - \(error.localizedDescription)")
        }
        
        return false
    }
    
    /// Get comprehensive security score for macOS
    /// - Returns: Security score from 0-100
    static func getSecurityScore() -> Int {
        var score = 0
        
        // Password/Touch ID set: +40 points
        if hasScreenLock() {
            score += 40
        }
        
        // Touch ID available and working: +20 points
        let context = LAContext()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            score += 20
        }
        
        // Auto-login disabled: +15 points
        if isAutoLoginDisabled() {
            score += 15
        }
        
        // FileVault enabled: +15 points
        if isFileVaultEnabled() {
            score += 15
        }
        
        // Screen saver password required: +10 points
        if isScreenSaverPasswordRequired() {
            score += 10
        }
        
        return score
    }
}
