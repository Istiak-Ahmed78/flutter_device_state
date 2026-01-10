import 'package:flutter_device_state/flutter_device_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SecurityLevel', () {
    test('has correct enum values', () {
      expect(SecurityLevel.values.length, 4);
      expect(SecurityLevel.values, contains(SecurityLevel.secure));
      expect(SecurityLevel.values, contains(SecurityLevel.warning));
      expect(SecurityLevel.values, contains(SecurityLevel.compromised));
      expect(SecurityLevel.values, contains(SecurityLevel.unknown));
    });

    group('description', () {
      test('returns correct description for secure', () {
        expect(SecurityLevel.secure.description, 'Device is secure');
      });

      test('returns correct description for warning', () {
        expect(
            SecurityLevel.warning.description, 'Device has security warnings');
      });

      test('returns correct description for compromised', () {
        expect(SecurityLevel.compromised.description,
            'Device security is compromised');
      });

      test('returns correct description for unknown', () {
        expect(SecurityLevel.unknown.description, 'Security level is unknown');
      });
    });

    group('convenience getters', () {
      test('isSecure returns true only for secure level', () {
        expect(SecurityLevel.secure.isSecure, isTrue);
        expect(SecurityLevel.warning.isSecure, isFalse);
        expect(SecurityLevel.compromised.isSecure, isFalse);
        expect(SecurityLevel.unknown.isSecure, isFalse);
      });

      test('hasWarning returns true only for warning level', () {
        expect(SecurityLevel.warning.hasWarning, isTrue);
        expect(SecurityLevel.secure.hasWarning, isFalse);
        expect(SecurityLevel.compromised.hasWarning, isFalse);
        expect(SecurityLevel.unknown.hasWarning, isFalse);
      });

      test('isCompromised returns true only for compromised level', () {
        expect(SecurityLevel.compromised.isCompromised, isTrue);
        expect(SecurityLevel.secure.isCompromised, isFalse);
        expect(SecurityLevel.warning.isCompromised, isFalse);
        expect(SecurityLevel.unknown.isCompromised, isFalse);
      });

      test('isUnknown returns true only for unknown level', () {
        expect(SecurityLevel.unknown.isUnknown, isTrue);
        expect(SecurityLevel.secure.isUnknown, isFalse);
        expect(SecurityLevel.warning.isUnknown, isFalse);
        expect(SecurityLevel.compromised.isUnknown, isFalse);
      });
    });
  });

  group('SecurityState', () {
    test('creates state with all parameters', () {
      final state = SecurityState(
        isDeveloperModeEnabled: true,
        hasScreenLock: false,
        isEmulator: true,
        level: SecurityLevel.compromised,
        issues: ['Developer mode enabled', 'No screen lock'],
        timestamp: DateTime(2024),
      );

      expect(state.isDeveloperModeEnabled, isTrue);
      expect(state.hasScreenLock, isFalse);
      expect(state.isEmulator, isTrue);
      expect(state.level, SecurityLevel.compromised);
      expect(state.issues.length, 2);
    });

    group('fromChecks factory', () {
      test('creates secure state when all checks pass', () {
        final state = SecurityState.fromChecks(
          isDeveloperModeEnabled: false,
          hasScreenLock: true,
          isEmulator: false,
        );

        expect(state.level, SecurityLevel.secure);
        expect(state.issues, isEmpty);
        expect(state.isDeveloperModeEnabled, isFalse);
        expect(state.hasScreenLock, isTrue);
        expect(state.isEmulator, isFalse);
      });

      test('creates warning state when only screen lock is missing', () {
        final state = SecurityState.fromChecks(
          isDeveloperModeEnabled: false,
          hasScreenLock: false,
          isEmulator: false,
        );

        expect(state.level, SecurityLevel.warning);
        expect(state.issues, contains('No screen lock detected'));
        expect(state.issues.length, 1);
      });

      test('creates warning state when developer mode is enabled', () {
        final state = SecurityState.fromChecks(
          isDeveloperModeEnabled: true,
          hasScreenLock: true,
          isEmulator: false,
        );

        expect(state.level, SecurityLevel.warning);
        expect(state.issues, contains('Developer mode is enabled'));
      });

      test('creates compromised state when multiple issues exist', () {
        final state = SecurityState.fromChecks(
          isDeveloperModeEnabled: true,
          hasScreenLock: false,
          isEmulator: false,
        );

        expect(state.level, SecurityLevel.compromised);
        expect(state.issues.length, 2);
        expect(state.issues, contains('Developer mode is enabled'));
        expect(state.issues, contains('No screen lock detected'));
      });

      test(
          'creates compromised state when running on emulator with other issues',
          () {
        final state = SecurityState.fromChecks(
          isDeveloperModeEnabled: true,
          hasScreenLock: true,
          isEmulator: true,
        );

        expect(state.level, SecurityLevel.compromised);
        expect(state.issues, contains('Developer mode is enabled'));
        expect(state.issues, contains('Running on emulator/simulator'));
      });

      test('detects all three issues', () {
        final state = SecurityState.fromChecks(
          isDeveloperModeEnabled: true,
          hasScreenLock: false,
          isEmulator: true,
        );

        expect(state.level, SecurityLevel.compromised);
        expect(state.issues.length, 3);
        expect(state.issues, contains('Developer mode is enabled'));
        expect(state.issues, contains('No screen lock detected'));
        expect(state.issues, contains('Running on emulator/simulator'));
      });
    });

    group('unknown factory', () {
      test('creates unknown state', () {
        final state = SecurityState.unknown();

        expect(state.level, SecurityLevel.unknown);
        expect(state.isDeveloperModeEnabled, isFalse);
        expect(state.hasScreenLock, isFalse);
        expect(state.isEmulator, isFalse);
        expect(state.issues, contains('Unable to determine security state'));
      });
    });

    group('toString', () {
      test('returns formatted string representation', () {
        final state = SecurityState.fromChecks(
          isDeveloperModeEnabled: true,
          hasScreenLock: false,
          isEmulator: true,
        );

        final string = state.toString();

        expect(string, contains('SecurityState'));
        expect(string, contains('level: ${SecurityLevel.compromised}'));
        expect(string, contains('developerMode: true'));
        expect(string, contains('screenLock: false'));
        expect(string, contains('emulator: true'));
        expect(string, contains('issues: 3'));
      });
    });

    group('equality', () {
      test('states with same values are equal', () {
        final state1 = SecurityState.fromChecks(
          isDeveloperModeEnabled: true,
          hasScreenLock: false,
          isEmulator: true,
        );

        final state2 = SecurityState.fromChecks(
          isDeveloperModeEnabled: true,
          hasScreenLock: false,
          isEmulator: true,
        );

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('states with different values are not equal', () {
        final state1 = SecurityState.fromChecks(
          isDeveloperModeEnabled: true,
          hasScreenLock: false,
          isEmulator: true,
        );

        final state2 = SecurityState.fromChecks(
          isDeveloperModeEnabled: false,
          hasScreenLock: true,
          isEmulator: false,
        );

        expect(state1, isNot(equals(state2)));
      });
    });
  });
}
