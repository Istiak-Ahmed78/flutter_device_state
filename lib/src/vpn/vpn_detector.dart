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
/// final state = await vpnDetector.checkVpnStatus();
/// print('VPN is ${state.isConnected ? "connected" : "disconnected"}');
///
/// // Listen to VPN state changes
/// vpnDetector.vpnStateStream.listen((state) {
///   print('VPN state changed: ${state.description}');
/// });
/// ```
class VpnDetector {
  final VpnDetectorPlatform _platform = VpnDetectorPlatform();

  /// Checks the current VPN connection status
  ///
  /// Returns:
  /// - [VpnState.connected] if VPN is active
  /// - [VpnState.disconnected] if VPN is not active
  /// - [VpnState.unknown] if status cannot be determined
  ///
  /// Example:
  /// ```dart
  /// final state = await vpnDetector.checkVpnStatus();
  /// if (state.isConnected) {
  ///   print('VPN is active');
  /// }
  /// ```
  Future<VpnState> checkVpnStatus() => _platform.checkVpnStatus();

  /// Checks if VPN is currently active (convenience method)
  ///
  /// Returns `true` if VPN is connected, `false` otherwise.
  /// Returns `false` if state is unknown.
  ///
  /// Example:
  /// ```dart
  /// if (await vpnDetector.isVpnActive()) {
  ///   print('VPN detected!');
  /// }
  /// ```
  Future<bool> isVpnActive() async {
    final state = await checkVpnStatus();
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
  /// final subscription = vpnDetector.vpnStateStream.listen((state) {
  ///   print('VPN state: ${state.description}');
  /// });
  ///
  /// // Don't forget to cancel when done
  /// await subscription.cancel();
  /// ```
  Stream<VpnState> get vpnStateStream => _platform.vpnStateStream;
}
