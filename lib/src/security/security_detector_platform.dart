import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'security_state.dart';

class SecurityDetectorPlatform {
  static const MethodChannel _methodChannel =
      MethodChannel('flutter_device_state/security');

  /// Check if developer mode is enabled
  Future<bool> isDeveloperModeEnabled() async {
    // Web doesn't support developer mode detection
    if (kIsWeb) {
      debugPrint(
          'SecurityDetectorPlatform: Web platform - developer mode detection not supported');
      return false;
    }

    // Only Android and iOS are supported
    if (!Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS) {
      debugPrint(
          'SecurityDetectorPlatform: ${Platform.operatingSystem} - developer mode detection not supported');
      return false;
    }

    try {
      debugPrint(
          'SecurityDetectorPlatform: Checking developer mode on ${Platform.operatingSystem}');
      final result =
          await _methodChannel.invokeMethod<bool>('isDeveloperModeEnabled');

      if (result == null) {
        debugPrint(
            'SecurityDetectorPlatform: Received null response for developer mode');
        return false;
      }

      debugPrint(
          'SecurityDetectorPlatform: Developer mode is ${result ? "enabled" : "disabled"}');
      return result;
    } on PlatformException catch (e) {
      debugPrint(
          'SecurityDetectorPlatform: PlatformException - ${e.code}: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('SecurityDetectorPlatform: Unexpected error - $e');
      return false;
    }
  }

  /// Check if device has screen lock enabled
  Future<bool> hasScreenLock() async {
    // Web doesn't support screen lock detection
    if (kIsWeb) {
      debugPrint(
          'SecurityDetectorPlatform: Web platform - screen lock detection not supported');
      return false;
    }

    // Only Android and iOS are supported
    if (!Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS) {
      debugPrint(
          'SecurityDetectorPlatform: ${Platform.operatingSystem} - screen lock detection not supported');
      return false;
    }

    try {
      debugPrint(
          'SecurityDetectorPlatform: Checking screen lock on ${Platform.operatingSystem}');
      final result = await _methodChannel.invokeMethod<bool>('hasScreenLock');

      if (result == null) {
        debugPrint(
            'SecurityDetectorPlatform: Received null response for screen lock');
        return false;
      }

      debugPrint(
          'SecurityDetectorPlatform: Screen lock is ${result ? "enabled" : "disabled"}');
      return result;
    } on PlatformException catch (e) {
      debugPrint(
          'SecurityDetectorPlatform: PlatformException - ${e.code}: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('SecurityDetectorPlatform: Unexpected error - $e');
      return false;
    }
  }

  /// Check if running on emulator/simulator
  Future<bool> isEmulator() async {
    // Web doesn't support emulator detection
    if (kIsWeb) {
      debugPrint(
          'SecurityDetectorPlatform: Web platform - emulator detection not supported');
      return false;
    }

    // Only Android and iOS are supported
    if (!Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS) {
      debugPrint(
          'SecurityDetectorPlatform: ${Platform.operatingSystem} - emulator detection not supported');
      return false;
    }

    try {
      debugPrint(
          'SecurityDetectorPlatform: Checking if emulator on ${Platform.operatingSystem}');
      final result = await _methodChannel.invokeMethod<bool>('isEmulator');

      if (result == null) {
        debugPrint(
            'SecurityDetectorPlatform: Received null response for emulator check');
        return false;
      }

      debugPrint('SecurityDetectorPlatform: Is emulator: $result');
      return result;
    } on PlatformException catch (e) {
      debugPrint(
          'SecurityDetectorPlatform: PlatformException - ${e.code}: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('SecurityDetectorPlatform: Unexpected error - $e');
      return false;
    }
  }

  /// Get comprehensive security state
  Future<SecurityState> getSecurityState() async {
    try {
      debugPrint(
          'SecurityDetectorPlatform: Getting comprehensive security state');

      // Run all checks in parallel
      final results = await Future.wait([
        isDeveloperModeEnabled(),
        hasScreenLock(),
        isEmulator(),
      ]);

      final state = SecurityState.fromChecks(
        isDeveloperModeEnabled: results[0],
        hasScreenLock: results[1],
        isEmulator: results[2],
      );

      debugPrint('SecurityDetectorPlatform: Security state - ${state.level}');
      return state;
    } catch (e) {
      debugPrint('SecurityDetectorPlatform: Error getting security state - $e');
      return SecurityState.unknown();
    }
  }
}
