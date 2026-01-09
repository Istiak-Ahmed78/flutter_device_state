import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'vpn_state.dart';

class VpnDetectorPlatform {
  static const MethodChannel _methodChannel =
      MethodChannel('flutter_device_state/vpn');
  static const EventChannel _eventChannel =
      EventChannel('flutter_device_state/vpn_state');

  /// Check if VPN is currently active
  Future<VpnState> checkVpnStatus() async {
    // Web doesn't support VPN detection
    if (kIsWeb) {
      debugPrint(
          'VpnDetectorPlatform: Web platform - VPN detection not supported');
      return VpnState.unknown;
    }

    // Only Android, iOS, and macOS are supported
    if (!Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS) {
      debugPrint(
          'VpnDetectorPlatform: ${Platform.operatingSystem} - VPN detection not supported');
      return VpnState.unknown;
    }

    try {
      debugPrint(
          'VpnDetectorPlatform: Calling checkVpnStatus on ${Platform.operatingSystem}');
      final isActive =
          await _methodChannel.invokeMethod<bool>('checkVpnStatus');

      if (isActive == null) {
        debugPrint('VpnDetectorPlatform: Received null response');
        return VpnState.unknown;
      }

      debugPrint(
          'VpnDetectorPlatform: VPN is ${isActive ? "active" : "inactive"}');
      return isActive ? VpnState.connected : VpnState.disconnected;
    } on PlatformException catch (e) {
      debugPrint(
          'VpnDetectorPlatform: PlatformException - ${e.code}: ${e.message}');
      return VpnState.unknown;
    } catch (e) {
      debugPrint('VpnDetectorPlatform: Unexpected error - $e');
      return VpnState.unknown;
    }
  }

  /// Stream of VPN state changes
  Stream<VpnState> get vpnStateStream {
    // Web doesn't support VPN detection
    if (kIsWeb) {
      debugPrint(
          'VpnDetectorPlatform: Web platform - returning unknown state stream');
      return Stream.value(VpnState.unknown);
    }

    // Only Android, iOS, and macOS are supported
    if (!Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS) {
      debugPrint(
          'VpnDetectorPlatform: ${Platform.operatingSystem} - returning unknown state stream');
      return Stream.value(VpnState.unknown);
    }

    return _eventChannel.receiveBroadcastStream().map((isActive) {
      debugPrint(
          'VpnDetectorPlatform: Stream received: $isActive (${isActive.runtimeType})');

      if (isActive is bool) {
        return isActive ? VpnState.connected : VpnState.disconnected;
      }

      return VpnState.unknown;
    }).handleError((Object error) {
      debugPrint('VpnDetectorPlatform: Stream error - $error');
    });
  }
}
