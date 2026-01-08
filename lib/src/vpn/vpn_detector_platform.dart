import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'vpn_state.dart';

/// Platform-specific implementation for VPN detection
class VpnDetectorPlatform {
  static const MethodChannel _methodChannel =
      MethodChannel('flutter_device_state/vpn');
  static const EventChannel _eventChannel =
      EventChannel('flutter_device_state/vpn_state');

  /// Check current VPN status
  ///
  /// Returns [VpnState.connected] if VPN is active,
  /// [VpnState.disconnected] if VPN is not active,
  /// or [VpnState.unknown] if status cannot be determined.
  Future<VpnState> checkVpnStatus() async {
    try {
      debugPrint('VpnDetectorPlatform: Calling checkVpnStatus');
      final isActive =
          await _methodChannel.invokeMethod<bool>('checkVpnStatus');
      debugPrint('VpnDetectorPlatform: Received response: $isActive');

      if (isActive == null) {
        debugPrint('VpnDetectorPlatform: Received null response');
        return VpnState.unknown;
      }
      return isActive ? VpnState.connected : VpnState.disconnected;
    } on PlatformException catch (e) {
      debugPrint(
          'VpnDetectorPlatform: PlatformException - Code: ${e.code}, Message: ${e.message}');
      return VpnState.unknown;
    } on Object catch (e) {
      debugPrint('VpnDetectorPlatform: Unexpected error - $e');
      return VpnState.unknown;
    }
  }

  /// Stream of VPN state changes
  ///
  /// Emits [VpnState] whenever the VPN connection state changes.
  ///
  /// Note: Continuous monitoring may not be available on all platforms.
  /// On platforms without native monitoring support, this stream will
  /// only emit the initial state.
  Stream<VpnState> get vpnStateStream =>
      _eventChannel.receiveBroadcastStream().map((isActive) {
        debugPrint(
            'VpnDetectorPlatform: Stream received: $isActive (${isActive.runtimeType})');

        if (isActive is bool) {
          return isActive ? VpnState.connected : VpnState.disconnected;
        }
        debugPrint('VpnDetectorPlatform: Stream received non-boolean value');
        return VpnState.unknown;
      }).handleError((Object error) {
        debugPrint('VpnDetectorPlatform: Stream error - $error');
        // Error is handled, stream continues
      });
}
