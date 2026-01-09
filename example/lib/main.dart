import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_device_state/flutter_device_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _vpnDetector = VpnDetector();
  VpnState _vpnState = VpnState.unknown;
  StreamSubscription<VpnState>? _vpnSubscription;

  @override
  void initState() {
    super.initState();
    _checkVpnStatus();
    _listenToVpnChanges();
  }

  @override
  void dispose() {
    _vpnSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkVpnStatus() async {
    try {
      final state = await _vpnDetector.checkVpnStatus();
      if (mounted) {
        setState(() {
          _vpnState = state;
        });
      }
    } on Exception catch (e) {
      debugPrint('Error checking VPN status: $e');
    }
  }

  void _listenToVpnChanges() {
    _vpnSubscription = _vpnDetector.vpnStateStream.listen(
      (state) {
        if (mounted) {
          setState(() {
            _vpnState = state;
          });
        }
      },
      onError: (error) {
        debugPrint('Error in VPN stream: $error');
      },
    );
  }

  Color _getStatusColor() {
    switch (_vpnState) {
      case VpnState.connected:
        return Colors.green;
      case VpnState.disconnected:
        return Colors.red;
      case VpnState.unknown:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon() {
    switch (_vpnState) {
      case VpnState.connected:
        return Icons.vpn_lock;
      case VpnState.disconnected:
        return Icons.vpn_lock_outlined;
      case VpnState.unknown:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Device State Example'),
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Status Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: _getStatusColor().withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: _getStatusColor(), width: 3),
                    ),
                    child: Icon(
                      _getStatusIcon(),
                      size: 60,
                      color: _getStatusColor(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Status Text
                  Text(
                    'VPN Status',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _vpnState.description,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Status Card
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildInfoRow('Connected', _vpnState.isConnected),
                          const Divider(),
                          _buildInfoRow(
                            'Disconnected',
                            _vpnState.isDisconnected,
                          ),
                          const Divider(),
                          _buildInfoRow('Unknown', _vpnState.isUnknown),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Refresh Button
                  ElevatedButton.icon(
                    onPressed: _checkVpnStatus,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Check Again'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info Text
                  Text(
                    'Real-time monitoring is active',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }
}
