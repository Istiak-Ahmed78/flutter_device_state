/// Security level of the device
enum SecurityLevel {
  /// Device passes all security checks
  secure,

  /// Device has some security concerns
  warning,

  /// Device has critical security issues
  compromised,

  /// Unable to determine security level
  unknown,
}

extension SecurityLevelExtension on SecurityLevel {
  String get description {
    switch (this) {
      case SecurityLevel.secure:
        return 'Device is secure';
      case SecurityLevel.warning:
        return 'Device has security warnings';
      case SecurityLevel.compromised:
        return 'Device security is compromised';
      case SecurityLevel.unknown:
        return 'Security level is unknown';
    }
  }

  bool get isSecure => this == SecurityLevel.secure;
  bool get hasWarning => this == SecurityLevel.warning;
  bool get isCompromised => this == SecurityLevel.compromised;
  bool get isUnknown => this == SecurityLevel.unknown;
}

/// Comprehensive security state of the device
class SecurityState {
  const SecurityState({
    required this.isDeveloperModeEnabled,
    required this.hasScreenLock,
    required this.isEmulator,
    required this.level,
    required this.issues,
    required this.timestamp,
  });

  /// Create SecurityState from individual checks
  factory SecurityState.fromChecks({
    required bool isDeveloperModeEnabled,
    required bool hasScreenLock,
    required bool isEmulator,
  }) {
    final issues = <String>[];

    if (isDeveloperModeEnabled) {
      issues.add('Developer mode is enabled');
    }

    if (!hasScreenLock) {
      issues.add('No screen lock detected');
    }

    if (isEmulator) {
      issues.add('Running on emulator/simulator');
    }

    // Determine security level
    SecurityLevel level;
    if (issues.isEmpty) {
      level = SecurityLevel.secure;
    } else if (issues.length == 1 && !hasScreenLock) {
      level = SecurityLevel.warning;
    } else if (issues.length >= 2) {
      level = SecurityLevel.compromised;
    } else {
      level = SecurityLevel.warning;
    }

    return SecurityState(
      isDeveloperModeEnabled: isDeveloperModeEnabled,
      hasScreenLock: hasScreenLock,
      isEmulator: isEmulator,
      level: level,
      issues: issues,
      timestamp: DateTime.now(),
    );
  }

  /// Create unknown state (when checks fail)
  factory SecurityState.unknown() => SecurityState(
        isDeveloperModeEnabled: false,
        hasScreenLock: false,
        isEmulator: false,
        level: SecurityLevel.unknown,
        issues: ['Unable to determine security state'],
        timestamp: DateTime.now(),
      );

  /// Whether developer mode is enabled
  final bool isDeveloperModeEnabled;

  /// Whether device has screen lock (PIN, pattern, biometric)
  final bool hasScreenLock;

  /// Whether running on an emulator/simulator
  final bool isEmulator;

  /// Overall security level
  final SecurityLevel level;

  /// List of detected security issues
  final List<String> issues;

  /// Timestamp when state was checked
  final DateTime timestamp;

  @override
  String toString() => 'SecurityState('
      'level: $level, '
      'developerMode: $isDeveloperModeEnabled, '
      'screenLock: $hasScreenLock, '
      'emulator: $isEmulator, '
      'issues: ${issues.length}'
      ')';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is SecurityState &&
        other.isDeveloperModeEnabled == isDeveloperModeEnabled &&
        other.hasScreenLock == hasScreenLock &&
        other.isEmulator == isEmulator &&
        other.level == level;
  }

  @override
  int get hashCode =>
      isDeveloperModeEnabled.hashCode ^
      hasScreenLock.hashCode ^
      isEmulator.hashCode ^
      level.hashCode;
}
