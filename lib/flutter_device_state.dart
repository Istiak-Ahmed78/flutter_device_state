library;

import 'src/security/security_detector.dart';
// 🆕 Import for internal use (export makes them available to users, import makes them available here)
import 'src/vpn/vpn_detector.dart';

// Security Detection
export 'src/security/security_detector.dart';
export 'src/security/security_state.dart';
// VPN Detection
export 'src/vpn/vpn_detector.dart';
export 'src/vpn/vpn_state.dart';

/// Main entry point for Flutter Device State plugin
///
/// Provides access to device state monitoring features:
/// - VPN detection
/// - Security features (developer mode, screen lock, emulator detection)
///
/// Example:
/// ```dart
/// final deviceState = FlutterDeviceState();
///
/// // Check VPN
/// final vpnState = await deviceState.vpn.checkStatus();
///
/// // Check security
/// final securityState = await deviceState.security.getSecurityState();
/// ```
class FlutterDeviceState {
  /// Create a FlutterDeviceState instance
  FlutterDeviceState()
      : vpn = VpnDetector(),
        security = SecurityDetector();

  /// Create a FlutterDeviceState instance with custom detectors (for testing)
  FlutterDeviceState.custom({
    required this.vpn,
    required this.security,
  });

  /// VPN detector instance
  final VpnDetector vpn;

  /// Security detector instance
  final SecurityDetector security;
}
