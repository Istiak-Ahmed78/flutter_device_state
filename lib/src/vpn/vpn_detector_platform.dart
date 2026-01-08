import 'dart:async';
import 'package:flutter/services.dart';
import 'vpn_state.dart';

/// Platform interface for VPN detection
class VpnDetectorPlatform {
  /// The method channel used to communicate with native platforms
  static const MethodChannel _channel =
      MethodChannel('flutter_device_state/vpn');

  /// The event channel for VPN state changes
  static const EventChannel _eventChannel =
      EventChannel('flutter_device_state/vpn_state');

  /// Checks if VPN is currently active
  ///
  /// Returns [VpnState.connected] if VPN is active,
  /// [VpnState.disconnected] if not active,
  /// or [VpnState.unknown] if state cannot be determined.
  ///
  /// Throws [PlatformException] if the platform is not supported.
  Future<VpnState> checkVpnStatus() async {
    try {
      final isActive = await _channel.invokeMethod<bool>('checkVpnStatus');

      if (isActive == null) {
        return VpnState.unknown;
      }

      return isActive ? VpnState.connected : VpnState.disconnected;
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('Error checking VPN status: ${e.message}');
      return VpnState.unknown;
    } on Exception catch (e) {
      // ignore: avoid_print
      print('Unexpected error checking VPN status: $e');
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
        if (isActive is bool) {
          return isActive ? VpnState.connected : VpnState.disconnected;
        }
        return VpnState.unknown;
      }).handleError((Object error) {
        // ignore: avoid_print
        print('Error in VPN state stream: $error');
        return VpnState.unknown;
      });
}
