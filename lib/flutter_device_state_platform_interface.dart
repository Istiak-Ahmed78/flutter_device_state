import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_device_state_method_channel.dart';

abstract class FlutterDeviceStatePlatform extends PlatformInterface {
  /// Constructs a FlutterDeviceStatePlatform.
  FlutterDeviceStatePlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterDeviceStatePlatform _instance = MethodChannelFlutterDeviceState();

  /// The default instance of [FlutterDeviceStatePlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterDeviceState].
  static FlutterDeviceStatePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterDeviceStatePlatform] when
  /// they register themselves.
  static set instance(FlutterDeviceStatePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
