import 'package:flutter_device_state/flutter_device_state.dart';
import 'package:flutter_device_state/src/security/security_detector_platform.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock platform for testing
class MockSecurityDetectorPlatform extends SecurityDetectorPlatform {
  bool mockDeveloperMode = false;
  bool mockScreenLock = true;
  bool mockEmulator = false;

  @override
  Future<bool> isDeveloperModeEnabled() async => mockDeveloperMode;

  @override
  Future<bool> hasScreenLock() async => mockScreenLock;

  @override
  Future<bool> isEmulator() async => mockEmulator;

  @override
  Future<SecurityState> getSecurityState() async => SecurityState.fromChecks(
        isDeveloperModeEnabled: mockDeveloperMode,
        hasScreenLock: mockScreenLock,
        isEmulator: mockEmulator,
      );
}

void main() {
  group('SecurityDetector', () {
    late MockSecurityDetectorPlatform mockPlatform;
    late SecurityDetector securityDetector;

    setUp(() {
      mockPlatform = MockSecurityDetectorPlatform();
      securityDetector = SecurityDetector(platform: mockPlatform);
    });

    group('isDeveloperModeEnabled', () {
      test('returns true when developer mode is enabled', () async {
        mockPlatform.mockDeveloperMode = true;

        final result = await securityDetector.isDeveloperModeEnabled();

        expect(result, isTrue);
      });

      test('returns false when developer mode is disabled', () async {
        mockPlatform.mockDeveloperMode = false;

        final result = await securityDetector.isDeveloperModeEnabled();

        expect(result, isFalse);
      });
    });

    group('hasScreenLock', () {
      test('returns true when screen lock is enabled', () async {
        mockPlatform.mockScreenLock = true;

        final result = await securityDetector.hasScreenLock();

        expect(result, isTrue);
      });

      test('returns false when screen lock is disabled', () async {
        mockPlatform.mockScreenLock = false;

        final result = await securityDetector.hasScreenLock();

        expect(result, isFalse);
      });
    });

    group('isEmulator', () {
      test('returns true when running on emulator', () async {
        mockPlatform.mockEmulator = true;

        final result = await securityDetector.isEmulator();

        expect(result, isTrue);
      });

      test('returns false when running on physical device', () async {
        mockPlatform.mockEmulator = false;

        final result = await securityDetector.isEmulator();

        expect(result, isFalse);
      });
    });

    group('getSecurityState', () {
      test('returns secure state when all checks pass', () async {
        mockPlatform
          ..mockDeveloperMode = false
          ..mockScreenLock = true
          ..mockEmulator = false;

        final state = await securityDetector.getSecurityState();

        expect(state.level, SecurityLevel.secure);
        expect(state.issues, isEmpty);
      });

      test('returns warning state with single issue', () async {
        mockPlatform
          ..mockDeveloperMode = true
          ..mockScreenLock = true
          ..mockEmulator = false;

        final state = await securityDetector.getSecurityState();

        expect(state.level, SecurityLevel.warning);
        expect(state.issues.length, 1);
        expect(state.issues, contains('Developer mode is enabled'));
      });

      test('returns compromised state with multiple issues', () async {
        mockPlatform
          ..mockDeveloperMode = true
          ..mockScreenLock = false
          ..mockEmulator = true;

        final state = await securityDetector.getSecurityState();

        expect(state.level, SecurityLevel.compromised);
        expect(state.issues.length, 3);
      });

      test('includes correct security check results', () async {
        mockPlatform
          ..mockDeveloperMode = true
          ..mockScreenLock = false
          ..mockEmulator = true;

        final state = await securityDetector.getSecurityState();

        expect(state.isDeveloperModeEnabled, isTrue);
        expect(state.hasScreenLock, isFalse);
        expect(state.isEmulator, isTrue);
      });
    });
  });
}
