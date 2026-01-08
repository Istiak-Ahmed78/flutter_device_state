import 'package:flutter/services.dart';
import 'package:flutter_device_state/src/vpn/vpn_detector_platform.dart';
import 'package:flutter_device_state/src/vpn/vpn_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel('flutter_device_state/vpn');
  const eventChannel = EventChannel('flutter_device_state/vpn_state');

  late VpnDetectorPlatform platform;
  late List<MethodCall> methodCallLog;

  setUp(() {
    platform = VpnDetectorPlatform();
    methodCallLog = <MethodCall>[];

    // Mock method channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (MethodCall methodCall) async {
      methodCallLog.add(methodCall);

      switch (methodCall.method) {
        case 'checkVpnStatus':
          return true; // Default: VPN is connected
        default:
          return null;
      }
    });
  });

  tearDown(() {
    // Clear method channel handler
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);

    // Clear event channel handler
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(eventChannel, null);
  });

  group('VpnDetectorPlatform', () {
    group('checkVpnStatus', () {
      test('returns connected when platform returns true', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
                methodChannel, (MethodCall methodCall) async => true);

        final state = await platform.checkVpnStatus();
        expect(state, VpnState.connected);
      });

      test('returns disconnected when platform returns false', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
                methodChannel, (MethodCall methodCall) async => false);

        final state = await platform.checkVpnStatus();
        expect(state, VpnState.disconnected);
      });

      test('returns unknown when platform returns null', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
                methodChannel, (MethodCall methodCall) async => null);

        final state = await platform.checkVpnStatus();
        expect(state, VpnState.unknown);
      });

      test('returns unknown when PlatformException is thrown', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel,
                (MethodCall methodCall) async {
          throw PlatformException(
            code: 'UNAVAILABLE',
            message: 'VPN detection not available',
          );
        });

        final state = await platform.checkVpnStatus();
        expect(state, VpnState.unknown);
      });

      test('returns unknown when generic exception is thrown', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel,
                (MethodCall methodCall) async {
          throw Exception('Unexpected error');
        });

        final state = await platform.checkVpnStatus();
        expect(state, VpnState.unknown);
      });

      test('calls correct method on platform', () async {
        await platform.checkVpnStatus();
        expect(methodCallLog, hasLength(1));
        expect(methodCallLog.first.method, 'checkVpnStatus');
      });
    });

    group('vpnStateStream', () {
      test('emits connected when platform sends true', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockStreamHandler(
          eventChannel,
          MockStreamHandler.inline(
            onListen: (Object? arguments, MockStreamHandlerEventSink events) {
              events
                ..success(true)
                ..endOfStream();
            },
          ),
        );

        final states = await platform.vpnStateStream.toList();
        expect(states, [VpnState.connected]);
      });

      test('emits disconnected when platform sends false', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockStreamHandler(
          eventChannel,
          MockStreamHandler.inline(
            onListen: (Object? arguments, MockStreamHandlerEventSink events) {
              events
                ..success(false)
                ..endOfStream();
            },
          ),
        );

        final states = await platform.vpnStateStream.toList();
        expect(states, [VpnState.disconnected]);
      });

      test('emits unknown when platform sends non-boolean', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockStreamHandler(
          eventChannel,
          MockStreamHandler.inline(
            onListen: (Object? arguments, MockStreamHandlerEventSink events) {
              events
                ..success('invalid')
                ..endOfStream();
            },
          ),
        );

        final states = await platform.vpnStateStream.toList();
        expect(states, [VpnState.unknown]);
      });

      test('emits multiple state changes', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockStreamHandler(
          eventChannel,
          MockStreamHandler.inline(
            onListen: (Object? arguments, MockStreamHandlerEventSink events) {
              events
                ..success(false)
                ..success(true)
                ..success(false)
                ..endOfStream();
            },
          ),
        );

        final states = await platform.vpnStateStream.toList();
        expect(states, [
          VpnState.disconnected,
          VpnState.connected,
          VpnState.disconnected,
        ]);
      });

      test('handles stream errors without crashing', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockStreamHandler(
          eventChannel,
          MockStreamHandler.inline(
            onListen: (Object? arguments, MockStreamHandlerEventSink events) {
              events
                ..error(code: 'ERROR', message: 'Stream error')
                ..endOfStream();
            },
          ),
        );

        // The stream should complete without emitting values when error occurs
        // handleError prevents the error from propagating but doesn't emit a value
        final states = await platform.vpnStateStream.toList();
        expect(states, isEmpty);
      });

      test('continues emitting after handling error', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockStreamHandler(
          eventChannel,
          MockStreamHandler.inline(
            onListen: (Object? arguments, MockStreamHandlerEventSink events) {
              events
                ..success(true)
                ..error(code: 'ERROR', message: 'Stream error')
                ..success(false)
                ..endOfStream();
            },
          ),
        );

        final states = await platform.vpnStateStream.toList();
        expect(states, [VpnState.connected, VpnState.disconnected]);
      });
    });
  });
}
