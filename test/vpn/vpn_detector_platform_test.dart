import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_device_state/flutter_device_state.dart';
import 'package:flutter_device_state/src/vpn/vpn_detector_platform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VpnDetectorPlatform', () {
    late VpnDetectorPlatform platform;
    final methodCallLog = <MethodCall>[];

    // Check if running on supported platform
    final isSupportedPlatform =
        !kIsWeb && !Platform.isWindows && !Platform.isLinux;

    setUp(() {
      platform = VpnDetectorPlatform();
      methodCallLog.clear();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter_device_state/vpn'),
        (MethodCall methodCall) async {
          methodCallLog.add(methodCall);
          return false;
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter_device_state/vpn'),
        null,
      );
    });

    group('checkVpnStatus', () {
      test('calls platform method on supported platforms', () async {
        await platform.checkVpnStatus();

        if (isSupportedPlatform) {
          expect(methodCallLog.length, greaterThan(0));
        } else {
          // On unsupported platforms, returns unknown without calling method
          expect(methodCallLog.length, 0);
        }
      });

      test('returns unknown on unsupported platforms', () async {
        final result = await platform.checkVpnStatus();

        if (!isSupportedPlatform) {
          expect(result, VpnState.unknown);
        }
      });

      test('returns connected when platform returns true', () async {
        if (!isSupportedPlatform) {
          return;
        }

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_device_state/vpn'),
          (MethodCall methodCall) async => true,
        );

        final result = await platform.checkVpnStatus();

        expect(result, VpnState.connected);
      });

      test('returns disconnected when platform returns false', () async {
        if (!isSupportedPlatform) {
          return;
        }

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_device_state/vpn'),
          (MethodCall methodCall) async => false,
        );

        final result = await platform.checkVpnStatus();

        expect(result, VpnState.disconnected);
      });

      test('returns unknown on platform exception', () async {
        if (!isSupportedPlatform) {
          final result = await platform.checkVpnStatus();
          expect(result, VpnState.unknown);
          return;
        }

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_device_state/vpn'),
          (MethodCall methodCall) async {
            throw PlatformException(code: 'ERROR');
          },
        );

        final result = await platform.checkVpnStatus();

        expect(result, VpnState.unknown);
      });

      test('returns unknown when platform returns null', () async {
        if (!isSupportedPlatform) {
          return;
        }

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_device_state/vpn'),
          (MethodCall methodCall) async => null,
        );

        final result = await platform.checkVpnStatus();

        expect(result, VpnState.unknown);
      });
    });

    group('Platform-specific behavior', () {
      test('Unsupported platforms return unknown', () async {
        if (!isSupportedPlatform) {
          final result = await platform.checkVpnStatus();
          expect(result, VpnState.unknown);
        }
      });

      test('Supported platforms can detect VPN', () async {
        if (isSupportedPlatform) {
          // Just verify method is callable
          final result = await platform.checkVpnStatus();
          expect(result, isA<VpnState>());
        }
      });
    });
  });
}
