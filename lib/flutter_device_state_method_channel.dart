import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_device_state_platform_interface.dart';

/// An implementation of [FlutterDeviceStatePlatform] that uses method channels.
///
/// Note: VPN and Security features use their own dedicated method channels.
/// This is kept for potential future features.
class MethodChannelFlutterDeviceState extends FlutterDeviceStatePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_device_state');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
