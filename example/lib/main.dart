import 'package:flutter/material.dart';
import 'package:flutter_device_state/flutter_device_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Device State Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DeviceStatePage(),
    );
  }
}

class DeviceStatePage extends StatefulWidget {
  const DeviceStatePage({super.key});

  @override
  State<DeviceStatePage> createState() => _DeviceStatePageState();
}

class _DeviceStatePageState extends State<DeviceStatePage> {
  final _deviceState = FlutterDeviceState();

  // VPN state
  VpnState _vpnState = VpnState.unknown;

  // 🆕 Security state
  bool _isDeveloperMode = false;
  bool _hasScreenLock = false;
  bool _isEmulator = false;
  SecurityState? _securityState;

  @override
  void initState() {
    super.initState();
    _checkAllStates();
    _listenToVpnChanges();
  }

  Future<void> _checkAllStates() async {
    // Check VPN
    final vpnState = await _deviceState.vpn.checkStatus();

    // 🆕 Check security features
    final isDeveloperMode = await _deviceState.security
        .isDeveloperModeEnabled();
    final hasScreenLock = await _deviceState.security.hasScreenLock();
    final isEmulator = await _deviceState.security.isEmulator();
    final securityState = await _deviceState.security.getSecurityState();

    setState(() {
      _vpnState = vpnState;
      _isDeveloperMode = isDeveloperMode;
      _hasScreenLock = hasScreenLock;
      _isEmulator = isEmulator;
      _securityState = securityState;
    });
  }

  void _listenToVpnChanges() {
    _deviceState.vpn.stateStream.listen((state) {
      setState(() {
        _vpnState = state;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device State Monitor'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _checkAllStates,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // VPN Status Card
              _buildVpnCard(),
              const SizedBox(height: 16),

              // 🆕 Security Status Card
              _buildSecurityCard(),
              const SizedBox(height: 16),

              // 🆕 Security Details Cards
              _buildDeveloperModeCard(),
              const SizedBox(height: 12),
              _buildScreenLockCard(),
              const SizedBox(height: 12),
              _buildEmulatorCard(),
              const SizedBox(height: 24),

              // Refresh Button
              ElevatedButton.icon(
                onPressed: _checkAllStates,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh All'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVpnCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _vpnState.isConnected
                      ? Icons.vpn_lock
                      : Icons.vpn_lock_outlined,
                  color: _vpnState.isConnected ? Colors.green : Colors.grey,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'VPN Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _vpnState.description,
                        style: TextStyle(
                          color: _vpnState.isConnected
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🆕 Security Overview Card
  Widget _buildSecurityCard() {
    final state = _securityState;
    if (state == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    Color levelColor;
    IconData levelIcon;

    switch (state.level) {
      case SecurityLevel.secure:
        levelColor = Colors.green;
        levelIcon = Icons.shield;
        break;
      case SecurityLevel.warning:
        levelColor = Colors.orange;
        levelIcon = Icons.warning;
        break;
      case SecurityLevel.compromised:
        levelColor = Colors.red;
        levelIcon = Icons.dangerous;
        break;
      case SecurityLevel.unknown:
        levelColor = Colors.grey;
        levelIcon = Icons.help;
        break;
    }

    return Card(
      elevation: 4,
      color: levelColor.withValues(alpha: 25),

      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(levelIcon, color: levelColor, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Security Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        state.level.description,
                        style: TextStyle(color: levelColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (state.issues.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const Text(
                'Issues Detected:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...state.issues.map(
                (issue) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, size: 16, color: levelColor),
                      const SizedBox(width: 8),
                      Expanded(child: Text(issue)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 🆕 Developer Mode Card
  Widget _buildDeveloperModeCard() {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.developer_mode,
          color: _isDeveloperMode ? Colors.orange : Colors.green,
        ),
        title: const Text('Developer Mode'),
        subtitle: Text(_isDeveloperMode ? 'Enabled' : 'Disabled'),
        trailing: Icon(
          _isDeveloperMode ? Icons.warning : Icons.check_circle,
          color: _isDeveloperMode ? Colors.orange : Colors.green,
        ),
      ),
    );
  }

  // 🆕 Screen Lock Card
  Widget _buildScreenLockCard() {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.lock,
          color: _hasScreenLock ? Colors.green : Colors.red,
        ),
        title: const Text('Screen Lock'),
        subtitle: Text(_hasScreenLock ? 'Enabled' : 'Not Set'),
        trailing: Icon(
          _hasScreenLock ? Icons.check_circle : Icons.error,
          color: _hasScreenLock ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  // 🆕 Emulator Card
  Widget _buildEmulatorCard() {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.phone_android,
          color: _isEmulator ? Colors.orange : Colors.green,
        ),
        title: const Text('Device Type'),
        subtitle: Text(_isEmulator ? 'Emulator' : 'Physical Device'),
        trailing: Icon(
          _isEmulator ? Icons.warning : Icons.check_circle,
          color: _isEmulator ? Colors.orange : Colors.green,
        ),
      ),
    );
  }
}
