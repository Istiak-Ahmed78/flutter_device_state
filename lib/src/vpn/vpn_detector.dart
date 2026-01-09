import 'dart:async';
import 'vpn_detector_platform.dart';
import 'vpn_state.dart';

/// VPN Detection API
///
/// Provides methods to detect VPN connections on Android and iOS.
///
/// Example usage:
/// ```dart
/// final vpnDetector = VpnDetector();
///
/// // Check current VPN status
/// final state = await vpnDetector.checkStatus();
/// print('VPN is ${state.isConnected ? "connected" : "disconnected"}');
///
/// // Listen to VPN state changes
/// vpnDetector.stateStream.listen((state) {
///   print('VPN state changed: ${state.description}');
/// });
/// ```
class VpnDetector {
  /// Create a VpnDetector with optional custom platform implementation
  VpnDetector({VpnDetectorPlatform? platform})
      : _platform = platform ?? VpnDetectorPlatform();
  final VpnDetectorPlatform _platform;

  /// Checks the current VPN connection status
  ///
  /// Returns:
  /// - [VpnState.connected] if VPN is active
  /// - [VpnState.disconnected] if VPN is not active
  /// - [VpnState.unknown] if status cannot be determined
  ///
  /// Example:
  /// ```dart
  /// final state = await vpnDetector.checkStatus();
  /// if (state.isConnected) {
  ///   print('VPN is active');
  /// }
  /// ```
  Future<VpnState> checkStatus() => _platform.checkVpnStatus();

  /// Checks if VPN is currently active (convenience method)
  ///
  /// Returns `true` if VPN is connected, `false` otherwise.
  /// Returns `false` if state is unknown.
  ///
  /// Example:
  /// ```dart
  /// if (await vpnDetector.isActive()) {
  ///   print('VPN detected!');
  /// }
  /// ```
  Future<bool> isActive() async {
    final state = await checkStatus();
    return state.isConnected;
  }

  /// Stream that emits VPN state changes
  ///
  /// Continuously monitors VPN connection state and emits updates
  /// whenever the state changes.
  ///
  /// Note: Continuous monitoring may not be available on all platforms.
  ///
  /// Example:
  /// ```dart
  /// final subscription = vpnDetector.stateStream.listen((state) {
  ///   print('VPN state: ${state.description}');
  /// });
  ///
  /// // Don't forget to cancel when done
  /// await subscription.cancel();
  /// ```
  Stream<VpnState> get stateStream => _platform.vpnStateStream;
}
