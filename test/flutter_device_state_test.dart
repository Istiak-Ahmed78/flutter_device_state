import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_device_state/flutter_device_state.dart';
import 'package:flutter_device_state/flutter_device_state_platform_interface.dart';
import 'package:flutter_device_state/flutter_device_state_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterDeviceStatePlatform
    with MockPlatformInterfaceMixin
    implements FlutterDeviceStatePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterDeviceStatePlatform initialPlatform = FlutterDeviceStatePlatform.instance;

  test('$MethodChannelFlutterDeviceState is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterDeviceState>());
  });

  test('getPlatformVersion', () async {
    FlutterDeviceState flutterDeviceStatePlugin = FlutterDeviceState();
    MockFlutterDeviceStatePlatform fakePlatform = MockFlutterDeviceStatePlatform();
    FlutterDeviceStatePlatform.instance = fakePlatform;

    expect(await flutterDeviceStatePlugin.getPlatformVersion(), '42');
  });
}
