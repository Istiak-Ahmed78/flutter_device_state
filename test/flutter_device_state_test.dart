import 'package:flutter_device_state/flutter_device_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlutterDeviceState', () {
    test('creates instance with default detectors', () {
      final deviceState = FlutterDeviceState();

      expect(deviceState.vpn, isNotNull);
      expect(deviceState.security, isNotNull);
      expect(deviceState.vpn, isA<VpnDetector>());
      expect(deviceState.security, isA<SecurityDetector>());
    });

    test('creates instance with custom detectors', () {
      final customVpn = VpnDetector();
      final customSecurity = SecurityDetector();

      final deviceState = FlutterDeviceState.custom(
        vpn: customVpn,
        security: customSecurity,
      );

      expect(deviceState.vpn, equals(customVpn));
      expect(deviceState.security, equals(customSecurity));
    });

    test('multiple instances are independent', () {
      final deviceState1 = FlutterDeviceState();
      final deviceState2 = FlutterDeviceState();

      expect(deviceState1.vpn, isNot(equals(deviceState2.vpn)));
      expect(deviceState1.security, isNot(equals(deviceState2.security)));
    });
  });
}
