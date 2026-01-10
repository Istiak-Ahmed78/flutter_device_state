import 'package:flutter_device_state/flutter_device_state.dart';
import 'package:flutter_device_state/src/vpn/vpn_detector_platform.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock platform for testing
class MockVpnDetectorPlatform extends VpnDetectorPlatform {
  VpnState mockState = VpnState.disconnected;
  final List<VpnState> mockStreamStates = [];

  @override
  Future<VpnState> checkVpnStatus() async => mockState;

  @override
  Stream<VpnState> get vpnStateStream => Stream.fromIterable(mockStreamStates);
}

void main() {
  group('VpnDetector', () {
    late MockVpnDetectorPlatform mockPlatform;
    late VpnDetector vpnDetector;

    setUp(() {
      mockPlatform = MockVpnDetectorPlatform();
      vpnDetector = VpnDetector(platform: mockPlatform);
    });

    group('checkStatus', () {
      test('returns connected state when VPN is active', () async {
        mockPlatform.mockState = VpnState.connected;

        final state = await vpnDetector.checkStatus();

        expect(state, VpnState.connected);
        expect(state.isConnected, isTrue);
      });

      test('returns disconnected state when VPN is inactive', () async {
        mockPlatform.mockState = VpnState.disconnected;

        final state = await vpnDetector.checkStatus();

        expect(state, VpnState.disconnected);
        expect(state.isDisconnected, isTrue);
      });

      test('returns unknown state when status cannot be determined', () async {
        mockPlatform.mockState = VpnState.unknown;

        final state = await vpnDetector.checkStatus();

        expect(state, VpnState.unknown);
        expect(state.isUnknown, isTrue);
      });
    });

    group('isActive', () {
      test('returns true when VPN is connected', () async {
        mockPlatform.mockState = VpnState.connected;

        final isActive = await vpnDetector.isActive();

        expect(isActive, isTrue);
      });

      test('returns false when VPN is disconnected', () async {
        mockPlatform.mockState = VpnState.disconnected;

        final isActive = await vpnDetector.isActive();

        expect(isActive, isFalse);
      });

      test('returns false when VPN state is unknown', () async {
        mockPlatform.mockState = VpnState.unknown;

        final isActive = await vpnDetector.isActive();

        expect(isActive, isFalse);
      });
    });

    group('stateStream', () {
      test('emits state changes', () async {
        mockPlatform.mockStreamStates.addAll([
          VpnState.disconnected,
          VpnState.connected,
          VpnState.disconnected,
        ]);

        final states = await vpnDetector.stateStream.toList();

        expect(states, [
          VpnState.disconnected,
          VpnState.connected,
          VpnState.disconnected,
        ]);
      });

      test('emits connected state when VPN connects', () async {
        mockPlatform.mockStreamStates.add(VpnState.connected);

        final state = await vpnDetector.stateStream.first;

        expect(state, VpnState.connected);
        expect(state.isConnected, isTrue);
      });

      test('emits disconnected state when VPN disconnects', () async {
        mockPlatform.mockStreamStates.add(VpnState.disconnected);

        final state = await vpnDetector.stateStream.first;

        expect(state, VpnState.disconnected);
        expect(state.isDisconnected, isTrue);
      });
    });
  });
}
