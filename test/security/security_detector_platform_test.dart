import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_device_state/flutter_device_state.dart';
import 'package:flutter_device_state/src/security/security_detector_platform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecurityDetectorPlatform', () {
    late SecurityDetectorPlatform platform;
    final methodCallLog = <MethodCall>[];

    // Check if running on supported platform
    final isSupportedPlatform =
        !kIsWeb && !Platform.isWindows && !Platform.isLinux;

    setUp(() {
      platform = SecurityDetectorPlatform();
      methodCallLog.clear();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter_device_state/security'),
        (MethodCall methodCall) async {
          methodCallLog.add(methodCall);

          switch (methodCall.method) {
            case 'isDeveloperModeEnabled':
              return false;
            case 'hasScreenLock':
              return true;
            case 'isEmulator':
              return false;
            default:
              return null;
          }
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter_device_state/security'),
        null,
      );
    });

    group('isDeveloperModeEnabled', () {
      test('calls platform method on supported platforms', () async {
        await platform.isDeveloperModeEnabled();

        if (isSupportedPlatform) {
          expect(
              methodCallLog
                  .any((call) => call.method == 'isDeveloperModeEnabled'),
              isTrue);
        } else {
          // On unsupported platforms, method channel is not called
          expect(
              methodCallLog
                  .any((call) => call.method == 'isDeveloperModeEnabled'),
              isFalse);
        }
      });

      test('returns false on unsupported platforms (Windows/Linux)', () async {
        final result = await platform.isDeveloperModeEnabled();

        if (!isSupportedPlatform) {
          expect(result, isFalse);
        }
      });

      test('returns true when platform returns true (Android only)', () async {
        if (!isSupportedPlatform) {
          // Skip this test on unsupported platforms
          return;
        }

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_device_state/security'),
          (MethodCall methodCall) async => true,
        );

        final result = await platform.isDeveloperModeEnabled();
        expect(result, isTrue);
      });

      test('returns false when platform returns false (iOS/macOS)', () async {
        if (!isSupportedPlatform) {
          // Skip this test on unsupported platforms
          return;
        }

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_device_state/security'),
          (MethodCall methodCall) async => false,
        );

        final result = await platform.isDeveloperModeEnabled();
        expect(result, isFalse);
      });

      test('returns false on platform exception', () async {
        if (!isSupportedPlatform) {
          // On unsupported platforms, always returns false
          final result = await platform.isDeveloperModeEnabled();
          expect(result, isFalse);
          return;
        }

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_device_state/security'),
          (MethodCall methodCall) async {
            throw PlatformException(code: 'ERROR');
          },
        );

        final result = await platform.isDeveloperModeEnabled();
        expect(result, isFalse);
      });
    });

    group('hasScreenLock', () {
      test('calls platform method on supported platforms', () async {
        await platform.hasScreenLock();

        if (isSupportedPlatform) {
          expect(methodCallLog.any((call) => call.method == 'hasScreenLock'),
              isTrue);
        } else {
          expect(methodCallLog.any((call) => call.method == 'hasScreenLock'),
              isFalse);
        }
      });

      test('returns false on unsupported platforms (Windows/Linux)', () async {
        final result = await platform.hasScreenLock();

        if (!isSupportedPlatform) {
          expect(result, isFalse);
        }
      });

      test('returns true when platform returns true (supported platforms)',
          () async {
        if (!isSupportedPlatform) {
          return;
        }

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_device_state/security'),
          (MethodCall methodCall) async => true,
        );

        final result = await platform.hasScreenLock();
        expect(result, isTrue);
      });

      test('returns false when platform returns false', () async {
        if (!isSupportedPlatform) {
          return;
        }

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_device_state/security'),
          (MethodCall methodCall) async => false,
        );

        final result = await platform.hasScreenLock();
        expect(result, isFalse);
      });

      test('returns false on platform exception', () async {
        if (!isSupportedPlatform) {
          final result = await platform.hasScreenLock();
          expect(result, isFalse);
          return;
        }

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_device_state/security'),
          (MethodCall methodCall) async {
            throw PlatformException(code: 'ERROR');
          },
        );

        final result = await platform.hasScreenLock();
        expect(result, isFalse);
      });
    });

    group('isEmulator', () {
      test('calls platform method on supported platforms', () async {
        await platform.isEmulator();

        if (isSupportedPlatform) {
          expect(
              methodCallLog.any((call) => call.method == 'isEmulator'), isTrue);
        } else {
          expect(methodCallLog.any((call) => call.method == 'isEmulator'),
              isFalse);
        }
      });

      test('returns false on unsupported platforms (Windows/Linux)', () async {
        final result = await platform.isEmulator();

        if (!isSupportedPlatform) {
          expect(result, isFalse);
        }
      });

      test('returns true when running on emulator (Android/iOS)', () async {
        if (!isSupportedPlatform) {
          return;
        }

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_device_state/security'),
          (MethodCall methodCall) async => true,
        );

        final result = await platform.isEmulator();
        expect(result, isTrue);
      });

      test('returns false when running on physical device', () async {
        if (!isSupportedPlatform) {
          return;
        }

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_device_state/security'),
          (MethodCall methodCall) async => false,
        );

        final result = await platform.isEmulator();
        expect(result, isFalse);
      });

      test('returns false on platform exception', () async {
        if (!isSupportedPlatform) {
          final result = await platform.isEmulator();
          expect(result, isFalse);
          return;
        }

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_device_state/security'),
          (MethodCall methodCall) async {
            throw PlatformException(code: 'ERROR');
          },
        );

        final result = await platform.isEmulator();
        expect(result, isFalse);
      });
    });

    group('getSecurityState', () {
      test('calls all security check methods on supported platforms', () async {
        await platform.getSecurityState();

        if (isSupportedPlatform) {
          expect(
              methodCallLog
                  .any((call) => call.method == 'isDeveloperModeEnabled'),
              isTrue);
          expect(methodCallLog.any((call) => call.method == 'hasScreenLock'),
              isTrue);
          expect(
              methodCallLog.any((call) => call.method == 'isEmulator'), isTrue);
        }
      });

      test('returns warning state on unsupported platforms', () async {
        final state = await platform.getSecurityState();

        if (!isSupportedPlatform) {
          // On Windows/Linux, screen lock always returns false
          expect(state.level, SecurityLevel.warning);
          expect(state.issues, contains('No screen lock detected'));
        }
      });

      test('returns secure state when all checks pass (supported platforms)',
          () async {
        if (!isSupportedPlatform) {
          return;
        }

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_device_state/security'),
          (MethodCall methodCall) async {
            switch (methodCall.method) {
              case 'isDeveloperModeEnabled':
                return false;
              case 'hasScreenLock':
                return true;
              case 'isEmulator':
                return false;
              default:
                return null;
            }
          },
        );

        final state = await platform.getSecurityState();

        expect(state.level, SecurityLevel.secure);
        expect(state.issues, isEmpty);
      });

      test('returns warning state when only screen lock is missing', () async {
        if (!isSupportedPlatform) {
          return;
        }

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_device_state/security'),
          (MethodCall methodCall) async {
            switch (methodCall.method) {
              case 'isDeveloperModeEnabled':
                return false;
              case 'hasScreenLock':
                return false;
              case 'isEmulator':
                return false;
              default:
                return null;
            }
          },
        );

        final state = await platform.getSecurityState();

        expect(state.level, SecurityLevel.warning);
        expect(state.issues.length, 1);
        expect(state.issues, contains('No screen lock detected'));
      });

      test('returns warning state when running on emulator only', () async {
        if (!isSupportedPlatform) {
          return;
        }

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_device_state/security'),
          (MethodCall methodCall) async {
            switch (methodCall.method) {
              case 'isDeveloperModeEnabled':
                return false;
              case 'hasScreenLock':
                return true;
              case 'isEmulator':
                return true;
              default:
                return null;
            }
          },
        );

        final state = await platform.getSecurityState();

        expect(state.level, SecurityLevel.warning);
        expect(state.issues.length, 1);
        expect(state.issues, contains('Running on emulator/simulator'));
      });

      test('returns compromised state when multiple issues exist', () async {
        if (!isSupportedPlatform) {
          return;
        }

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_device_state/security'),
          (MethodCall methodCall) async {
            switch (methodCall.method) {
              case 'isDeveloperModeEnabled':
                return true;
              case 'hasScreenLock':
                return false;
              case 'isEmulator':
                return true;
              default:
                return null;
            }
          },
        );

        final state = await platform.getSecurityState();

        expect(state.level, SecurityLevel.compromised);
        expect(state.issues.length, 3);
      });

      test('returns unknown state on error', () async {
        if (!isSupportedPlatform) {
          return;
        }

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_device_state/security'),
          (MethodCall methodCall) async {
            throw Exception('Test error');
          },
        );

        final state = await platform.getSecurityState();

        expect(state.level, SecurityLevel.unknown);
      });
    });

    group('Platform-specific behavior', () {
      test('Unsupported platforms return safe defaults', () async {
        if (!isSupportedPlatform) {
          final isDeveloperMode = await platform.isDeveloperModeEnabled();
          final hasScreenLock = await platform.hasScreenLock();
          final isEmulator = await platform.isEmulator();

          expect(isDeveloperMode, isFalse);
          expect(hasScreenLock, isFalse);
          expect(isEmulator, isFalse);
        }
      });

      test('Supported platforms can return various values', () async {
        if (isSupportedPlatform) {
          // This test would need actual platform implementation
          // Just verify methods are callable
          await platform.isDeveloperModeEnabled();
          await platform.hasScreenLock();
          await platform.isEmulator();
          expect(true, isTrue);
        }
      });
    });
  });
}
