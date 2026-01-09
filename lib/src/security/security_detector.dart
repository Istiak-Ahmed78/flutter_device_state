import 'security_detector_platform.dart';
import 'security_state.dart';

/// Security detector for checking device security features
class SecurityDetector {
  /// Create a SecurityDetector with optional custom platform implementation
  SecurityDetector({SecurityDetectorPlatform? platform})
      : _platform = platform ?? SecurityDetectorPlatform();
  final SecurityDetectorPlatform _platform;

  /// Check if developer mode is enabled
  ///
  /// Returns `true` if developer options are enabled (Android) or
  /// if device is in development mode (iOS).
  ///
  /// Example:
  /// ```dart
  /// final isDevMode = await securityDetector.isDeveloperModeEnabled();
  /// if (isDevMode) {
  ///   print('Warning: Developer mode is enabled');
  /// }
  /// ```
  Future<bool> isDeveloperModeEnabled() async =>
      _platform.isDeveloperModeEnabled();

  /// Check if device has screen lock enabled
  ///
  /// Returns `true` if device has PIN, pattern, password, or biometric
  /// authentication enabled.
  ///
  /// Example:
  /// ```dart
  /// final hasLock = await securityDetector.hasScreenLock();
  /// if (!hasLock) {
  ///   print('Warning: No screen lock detected');
  /// }
  /// ```
  Future<bool> hasScreenLock() async => _platform.hasScreenLock();

  /// Check if running on emulator/simulator
  ///
  /// Returns `true` if app is running on Android emulator or iOS simulator.
  ///
  /// Example:
  /// ```dart
  /// final isEmulator = await securityDetector.isEmulator();
  /// if (isEmulator) {
  ///   print('Running on emulator');
  /// }
  /// ```
  Future<bool> isEmulator() async => _platform.isEmulator();

  /// Get comprehensive security state
  ///
  /// Performs all security checks and returns a [SecurityState] object
  /// with overall security level and detected issues.
  ///
  /// Example:
  /// ```dart
  /// final state = await securityDetector.getSecurityState();
  /// print('Security Level: ${state.level}');
  /// print('Issues: ${state.issues}');
  ///
  /// if (state.isCompromised) {
  ///   showSecurityWarning();
  /// }
  /// ```
  Future<SecurityState> getSecurityState() async =>
      _platform.getSecurityState();
}
