import Foundation
import LocalAuthentication

/// Detects if the device has screen lock (passcode, Touch ID, or Face ID) enabled
class ScreenLockDetector {
    
    /// Check if device has any form of screen lock enabled
    /// - Returns: true if passcode, Touch ID, or Face ID is set up
    static func hasScreenLock() -> Bool {
        let context = LAContext()
        var error: NSError?
        
        // Check if device can evaluate biometric or passcode authentication
        let canEvaluate = context.canEvaluatePolicy(
            .deviceOwnerAuthentication,
            error: &error
        )
        
        if let error = error {
            // Log error for debugging
            print("ScreenLockDetector: Error checking screen lock - \(error.localizedDescription)")
            
            // If error is LAError.passcodeNotSet, device has no screen lock
            if let laError = error as? LAError {
                switch laError.code {
                case .passcodeNotSet:
                    return false
                case .biometryNotAvailable:
                    // Biometry not available, but passcode might be set
                    // Check again with passcode-only policy
                    return checkPasscodeOnly()
                default:
                    // For other errors, assume no screen lock for safety
                    return false
                }
            }
            
            return false
        }
        
        return canEvaluate
    }
    
    /// Check if device has passcode set (without biometric requirement)
    /// - Returns: true if passcode is set
    private static func checkPasscodeOnly() -> Bool {
        let context = LAContext()
        var error: NSError?
        
        // Try to evaluate with device owner authentication (includes passcode)
        let canEvaluate = context.canEvaluatePolicy(
            .deviceOwnerAuthentication,
            error: &error
        )
        
        // If no error, passcode is set
        return canEvaluate
    }
    
    /// Get detailed screen lock information
    /// - Returns: Dictionary with screen lock details
    static func getScreenLockInfo() -> [String: Any] {
        let context = LAContext()
        var info: [String: Any] = [:]
        
        // Check if biometric authentication is available
        var error: NSError?
        let biometryAvailable = context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        )
        
        info["hasBiometry"] = biometryAvailable
        
        // Determine biometry type
        if #available(iOS 11.0, *) {
            switch context.biometryType {
            case .none:
                info["biometryType"] = "none"
            case .touchID:
                info["biometryType"] = "touchID"
            case .faceID:
                info["biometryType"] = "faceID"
            @unknown default:
                info["biometryType"] = "unknown"
            }
        } else {
            info["biometryType"] = "unknown"
        }
        
        // Check if passcode is set
        info["hasPasscode"] = hasScreenLock()
        
        return info
    }
}
