import 'package:flutter_device_state/flutter_device_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VpnState', () {
    test('has correct enum values', () {
      expect(VpnState.values.length, 3);
      expect(VpnState.values, contains(VpnState.connected));
      expect(VpnState.values, contains(VpnState.disconnected));
      expect(VpnState.values, contains(VpnState.unknown));
    });

    group('isConnected', () {
      test('returns true for connected state', () {
        expect(VpnState.connected.isConnected, isTrue);
      });

      test('returns false for disconnected state', () {
        expect(VpnState.disconnected.isConnected, isFalse);
      });

      test('returns false for unknown state', () {
        expect(VpnState.unknown.isConnected, isFalse);
      });
    });

    group('isDisconnected', () {
      test('returns true for disconnected state', () {
        expect(VpnState.disconnected.isDisconnected, isTrue);
      });

      test('returns false for connected state', () {
        expect(VpnState.connected.isDisconnected, isFalse);
      });

      test('returns false for unknown state', () {
        expect(VpnState.unknown.isDisconnected, isFalse);
      });
    });

    group('isUnknown', () {
      test('returns true for unknown state', () {
        expect(VpnState.unknown.isUnknown, isTrue);
      });

      test('returns false for connected state', () {
        expect(VpnState.connected.isUnknown, isFalse);
      });

      test('returns false for disconnected state', () {
        expect(VpnState.disconnected.isUnknown, isFalse);
      });
    });

    group('description', () {
      test('returns correct description for connected', () {
        expect(VpnState.connected.description, 'VPN is connected');
      });

      test('returns correct description for disconnected', () {
        expect(VpnState.disconnected.description, 'VPN is disconnected');
      });

      test('returns correct description for unknown', () {
        expect(VpnState.unknown.description, 'VPN state is unknown');
      });
    });
  });
}
