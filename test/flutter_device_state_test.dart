import 'package:flutter_device_state/flutter_device_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('flutter_device_state', () {
    test('exports VpnDetector', () {
      expect(VpnDetector, isNotNull);
      expect(VpnDetector.new, returnsNormally);
    });

    test('exports VpnState', () {
      expect(VpnState.values, isNotEmpty);
      expect(VpnState.connected, isNotNull);
      expect(VpnState.disconnected, isNotNull);
      expect(VpnState.unknown, isNotNull);
    });

    test('VpnDetector can be instantiated', () {
      final detector = VpnDetector();
      expect(detector, isA<VpnDetector>());
    });
  });
}
