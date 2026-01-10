# Flutter Device State

<div align="center">

[![pub package](https://img.shields.io/pub/v/flutter_device_state.svg)](https://pub.dev/packages/flutter_device_state)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20macos-blue.svg)](https://pub.dev/packages/flutter_device_state)

**A comprehensive Flutter plugin for detecting device security states and VPN connections**

Detect VPN connections, developer mode, screen locks, and emulators across Android, iOS, and macOS with a simple, unified API.

</div>

---

## 📋 Overview

Flutter Device State helps you monitor critical device security features and network states in real-time. Essential for apps requiring enhanced security awareness, fraud prevention, banking apps, or compliance with security policies.

**Key Benefits:**
- 🔒 **Security-First** - Detect compromised device states before they become problems
- 🚀 **Simple API** - Intuitive methods that work out of the box
- 📱 **Cross-Platform** - Consistent API across Android, iOS, and macOS
- ⚡ **Real-Time** - Stream-based VPN monitoring for instant updates
- 🎯 **Production-Ready** - Thoroughly tested and battle-tested

---

## ✨ Features

| Feature | Android | iOS | macOS | Description |
|---------|:-------:|:---:|:-----:|-------------|
| **VPN Detection** | ✅ | ✅ | ✅ | Check if VPN is active + real-time monitoring stream |
| **Developer Mode** | ✅ | ⚠️ | ⚠️ | Detect if developer options/USB debugging enabled |
| **Screen Lock** | ✅ | ✅ | ✅ | Check for PIN, pattern, password, or biometric lock |
| **Emulator Detection** | ✅ | ✅ | ✅ | Identify if running on emulator/simulator |
| **Security Analysis** | ✅ | ✅ | ✅ | Comprehensive security state with risk levels |

⚠️ *iOS/macOS have limited developer mode detection due to platform restrictions*

**Minimum Requirements:**
- Android: API 21 (Android 5.0)
- iOS: 11.0
- macOS: 10.13

---

## 📦 Installation

```yaml
dependencies:
  flutter_device_state: ^1.0.0
```

```bash
flutter pub get
```

**No additional platform setup required!** ✨

---

## 🚀 Quick Start

```dart
import 'package:flutter_device_state/flutter_device_state.dart';

final deviceState = FlutterDeviceState();

// Check VPN
final vpnState = await deviceState.vpn.checkStatus();
print('VPN: ${vpnState.description}');

// Check security
final securityState = await deviceState.security.getSecurityState();
print('Security Level: ${securityState.level.description}');
print('Issues: ${securityState.issues}');
```

---

## 💡 Usage Examples

### 1️⃣ VPN Detection

<table>
<tr>
<td width="50%">

**One-Time Check**
```dart
// Detailed state
final vpnState = await deviceState.vpn.checkStatus();
if (vpnState.isConnected) {
  print('VPN is active');
}

// Simple boolean
final isActive = await deviceState.vpn.isActive();
```

</td>
<td width="50%">

**Real-Time Monitoring**
```dart
// Listen to changes
deviceState.vpn.stateStream.listen((state) {
  print('VPN: ${state.description}');
  
  if (state.isConnected) {
    showVpnWarning();
  }
});
```

</td>
</tr>
</table>

### 2️⃣ Security Detection

<table>
<tr>
<td width="50%">

**Individual Checks**
```dart
// Developer mode
final isDev = await deviceState.security
    .isDeveloperModeEnabled();

// Screen lock
final hasLock = await deviceState.security
    .hasScreenLock();

// Emulator
final isEmulator = await deviceState.security
    .isEmulator();
```

</td>
<td width="50%">

**Comprehensive Analysis**
```dart
final state = await deviceState.security
    .getSecurityState();

// Check security level
switch (state.level) {
  case SecurityLevel.secure:
    allowSensitiveOperations();
  case SecurityLevel.warning:
    showWarning(state.issues);
  case SecurityLevel.compromised:
    blockOperations(state.issues);
  default:
    handleUnknown();
}
```

</td>
</tr>
</table>

### 3️⃣ Complete Widget Example

```dart
class SecurityMonitor extends StatefulWidget {
  @override
  _SecurityMonitorState createState() => _SecurityMonitorState();
}

class _SecurityMonitorState extends State<SecurityMonitor> {
  final _deviceState = FlutterDeviceState();
  SecurityState? _securityState;
  VpnState _vpnState = VpnState.unknown;
  StreamSubscription<VpnState>? _vpnSubscription;

  @override
  void initState() {
    super.initState();
    _checkSecurity();
    _monitorVpn();
  }

  Future<void> _checkSecurity() async {
    final state = await _deviceState.security.getSecurityState();
    setState(() => _securityState = state);
    
    // Handle security issues
    if (state.level == SecurityLevel.compromised) {
      _showSecurityAlert(state.issues);
    }
  }

  void _monitorVpn() {
    _vpnSubscription = _deviceState.vpn.stateStream.listen((state) {
      setState(() => _vpnState = state);
      
      if (state.isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.vpn_lock, color: Colors.white),
                SizedBox(width: 8),
                Text('VPN detected - Some features may be limited'),
              ],
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  void _showSecurityAlert(List<String> issues) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Security Alert'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Security issues detected:'),
            SizedBox(height: 8),
            ...issues.map((issue) => Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 16),
                  SizedBox(width: 8),
                  Expanded(child: Text(issue)),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _vpnSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_securityState == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Security Status Card
        Card(
          color: _getColorForLevel(_securityState!.level),
          child: ListTile(
            leading: Icon(_getIconForLevel(_securityState!.level)),
            title: Text('Security: ${_securityState!.level.description}'),
            subtitle: Text('${_securityState!.issues.length} issues detected'),
          ),
        ),
        
        // VPN Status Card
        Card(
          child: ListTile(
            leading: Icon(
              _vpnState.isConnected ? Icons.vpn_lock : Icons.vpn_lock_outlined,
              color: _vpnState.isConnected ? Colors.orange : Colors.grey,
            ),
            title: Text('VPN Status'),
            subtitle: Text(_vpnState.description),
          ),
        ),
        
        // Individual Security Checks
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.developer_mode),
                title: Text('Developer Mode'),
                trailing: _buildStatusIcon(_securityState!.isDeveloperModeEnabled),
              ),
              ListTile(
                leading: Icon(Icons.lock),
                title: Text('Screen Lock'),
                trailing: _buildStatusIcon(_securityState!.hasScreenLock, inverse: true),
              ),
              ListTile(
                leading: Icon(Icons.phone_android),
                title: Text('Device Type'),
                trailing: _buildStatusIcon(_securityState!.isEmulator),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIcon(bool isActive, {bool inverse = false}) {
    final shouldWarn = inverse ? !isActive : isActive;
    return Icon(
      shouldWarn ? Icons.warning : Icons.check_circle,
      color: shouldWarn ? Colors.orange : Colors.green,
    );
  }

  Color _getColorForLevel(SecurityLevel level) {
    switch (level) {
      case SecurityLevel.secure: return Colors.green.shade100;
      case SecurityLevel.warning: return Colors.orange.shade100;
      case SecurityLevel.compromised: return Colors.red.shade100;
      default: return Colors.grey.shade100;
    }
  }

  IconData _getIconForLevel(SecurityLevel level) {
    switch (level) {
      case SecurityLevel.secure: return Icons.shield;
      case SecurityLevel.warning: return Icons.warning;
      case SecurityLevel.compromised: return Icons.dangerous;
      default: return Icons.help;
    }
  }
}
```

---

## 📚 API Reference

### Core Classes

| Class | Description |
|-------|-------------|
| `FlutterDeviceState` | Main entry point with `vpn` and `security` properties |
| `VpnDetector` | VPN detection methods and real-time stream |
| `SecurityDetector` | Device security check methods |

### VPN Detection API

| Method/Property | Return Type | Description |
|----------------|-------------|-------------|
| `checkStatus()` | `Future<VpnState>` | Get current VPN connection state |
| `isActive()` | `Future<bool>` | Simple boolean check if VPN is active |
| `stateStream` | `Stream<VpnState>` | Real-time stream of VPN state changes |

**VpnState:** `connected` • `disconnected` • `unknown`

**Extensions:** `isConnected` • `isDisconnected` • `isUnknown` • `description`

### Security Detection API

| Method | Return Type | Description |
|--------|-------------|-------------|
| `isDeveloperModeEnabled()` | `Future<bool>` | Check if developer options/USB debugging enabled |
| `hasScreenLock()` | `Future<bool>` | Check if device has PIN/pattern/password/biometric |
| `isEmulator()` | `Future<bool>` | Check if running on emulator/simulator |
| `getSecurityState()` | `Future<SecurityState>` | Comprehensive security analysis with risk level |

**SecurityState Properties:**

| Property | Type | Description |
|----------|------|-------------|
| `isDeveloperModeEnabled` | `bool` | Developer mode status |
| `hasScreenLock` | `bool` | Screen lock status |
| `isEmulator` | `bool` | Emulator/simulator status |
| `level` | `SecurityLevel` | Overall security risk level |
| `issues` | `List<String>` | Human-readable list of detected issues |
| `timestamp` | `DateTime` | When the security check was performed |

**SecurityLevel:** `secure` • `warning` • `compromised` • `unknown`

**Extensions:** `isSecure` • `hasWarning` • `isCompromised` • `isUnknown` • `description`

---

## 🤝 Contributing

We welcome contributions! Whether it's bug reports, feature requests, documentation improvements, or code contributions - all are appreciated.

### How to Contribute

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/interesting-feature`)
3. **Commit** your changes using [Conventional Commits](https://www.conventionalcommits.org/)
   - `feat:` New feature
   - `fix:` Bug fix
   - `docs:` Documentation
   - `test:` Tests
   - `refactor:` Code refactoring
4. **Push** to your branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Contribution Ideas

- 🔍 **Enhanced Detection** - Improve accuracy of security detectors
- 🌍 **Platform Support** - Add Windows/Linux support (if feasible)
- 📖 **Documentation** - Improve docs, add examples, fix typos
- 🧪 **Tests** - Increase test coverage
- 🐛 **Bug Fixes** - Fix any issues you encounter

### Development Guidelines

- Run `flutter analyze` before committing
- Add tests for new features
- Update documentation as needed
- Keep PRs focused on a single feature/fix

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

## 📞 Support

- 📖 [Documentation](https://pub.dev/packages/flutter_device_state)
- 🐛 [Report Issues](https://github.com/yourusername/flutter_device_state/issues)
- 💡 [Feature Requests](https://github.com/yourusername/flutter_device_state/issues)
- ⭐ [GitHub Repository](https://github.com/yourusername/flutter_device_state)

---

<div align="center">


If this package helps you build more secure apps, please ⭐ **star the repo** and **contribute**!

Your contributions make this package better for everyone. Let's build something amazing together! 🚀

</div>
