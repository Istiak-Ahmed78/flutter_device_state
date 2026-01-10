/// Represents the current VPN connection state
enum VpnState {
  /// VPN is connected and active
  connected,

  /// VPN is disconnected
  disconnected,

  /// VPN state is unknown or cannot be determined
  unknown,
}

/// Extension methods for VpnState
extension VpnStateExtension on VpnState {
  /// Returns true if VPN is connected
  bool get isConnected => this == VpnState.connected;

  /// Returns true if VPN is disconnected
  bool get isDisconnected => this == VpnState.disconnected;

  /// Returns true if VPN state is unknown
  bool get isUnknown => this == VpnState.unknown;

  /// Returns a human-readable description
  String get description {
    switch (this) {
      case VpnState.connected:
        return 'VPN is connected';
      case VpnState.disconnected:
        return 'VPN is disconnected';
      case VpnState.unknown:
        return 'VPN state is unknown';
    }
  }
}
