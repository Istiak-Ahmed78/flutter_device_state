import 'package:flutter_device_state/flutter_device_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VpnState', () {
    test('enum has all expected values', () {
      expect(VpnState.values.length, 3);
      expect(VpnState.values, contains(VpnState.connected));
      expect(VpnState.values, contains(VpnState.disconnected));
      expect(VpnState.values, contains(VpnState.unknown));
    });
  });

  group('VpnStateExtension', () {
    group('isConnected', () {
      test('returns true when state is connected', () {
        expect(VpnState.connected.isConnected, true);
      });

      test('returns false when state is disconnected', () {
        expect(VpnState.disconnected.isConnected, false);
      });

      test('returns false when state is unknown', () {
        expect(VpnState.unknown.isConnected, false);
      });
    });

    group('isDisconnected', () {
      test('returns true when state is disconnected', () {
        expect(VpnState.disconnected.isDisconnected, true);
      });

      test('returns false when state is connected', () {
        expect(VpnState.connected.isDisconnected, false);
      });

      test('returns false when state is unknown', () {
        expect(VpnState.unknown.isDisconnected, false);
      });
    });

    group('isUnknown', () {
      test('returns true when state is unknown', () {
        expect(VpnState.unknown.isUnknown, true);
      });

      test('returns false when state is connected', () {
        expect(VpnState.connected.isUnknown, false);
      });

      test('returns false when state is disconnected', () {
        expect(VpnState.disconnected.isUnknown, false);
      });
    });

    group('description', () {
      test('returns correct description for connected state', () {
        expect(VpnState.connected.description, 'VPN is connected');
      });

      test('returns correct description for disconnected state', () {
        expect(VpnState.disconnected.description, 'VPN is disconnected');
      });

      test('returns correct description for unknown state', () {
        expect(VpnState.unknown.description, 'VPN state is unknown');
      });
    });
  });
}
