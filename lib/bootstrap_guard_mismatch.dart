import 'package:flutter/material.dart';

import 'app_role.dart';
import 'device_persistence/device_config_store.dart';

class BootstrapGuardMismatchApp extends StatelessWidget {
  const BootstrapGuardMismatchApp({
    super.key,
    required this.expectedRole,
    required this.persistedRole,
    required this.deviceId,
    required this.deviceName,
    required this.deviceConfigStore,
  });

  final AppRole expectedRole;
  final AppRole persistedRole;
  final String deviceId;
  final String deviceName;
  final DeviceConfigStore deviceConfigStore;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bootstrap Guard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC97D60),
        ),
        useMaterial3: true,
      ),
      home: _BootstrapGuardMismatchPage(
        expectedRole: expectedRole,
        persistedRole: persistedRole,
        deviceId: deviceId,
        deviceName: deviceName,
        deviceConfigStore: deviceConfigStore,
      ),
    );
  }
}

class _BootstrapGuardMismatchPage extends StatefulWidget {
  const _BootstrapGuardMismatchPage({
    required this.expectedRole,
    required this.persistedRole,
    required this.deviceId,
    required this.deviceName,
    required this.deviceConfigStore,
  });

  final AppRole expectedRole;
  final AppRole persistedRole;
  final String deviceId;
  final String deviceName;
  final DeviceConfigStore deviceConfigStore;

  @override
  State<_BootstrapGuardMismatchPage> createState() =>
      _BootstrapGuardMismatchPageState();
}

class _BootstrapGuardMismatchPageState
    extends State<_BootstrapGuardMismatchPage> {
  bool _isResetting = false;
  String? _resultMessage;
  String? _configFilePath;

  @override
  void initState() {
    super.initState();
    _loadConfigPath();
  }

  Future<void> _loadConfigPath() async {
    final path = await widget.deviceConfigStore.getConfigFilePath();
    if (!mounted) return;
    setState(() {
      _configFilePath = path;
    });
  }

  Future<void> _resetBinding() async {
    setState(() {
      _isResetting = true;
      _resultMessage = null;
    });

    try {
      await widget.deviceConfigStore.clear();

      if (!mounted) return;

      setState(() {
        _isResetting = false;
        _resultMessage =
            'Device config cleared. Please close and relaunch the app to bind this installation again.';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isResetting = false;
        _resultMessage = 'Failed to clear device config: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Role Mismatch'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: DefaultTextStyle(
                  style: theme.textTheme.bodyLarge ??
                      const TextStyle(fontSize: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This app installation is already bound to a different installed role.',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Device name: ${widget.deviceName}'),
                      const SizedBox(height: 8),
                      Text('Device ID: ${widget.deviceId}'),
                      const SizedBox(height: 8),
                      Text('Entry role: ${widget.expectedRole.name}'),
                      const SizedBox(height: 8),
                      Text(
                        'Persisted installed role: ${widget.persistedRole.name}',
                      ),
                      if (_configFilePath != null) ...[
                        const SizedBox(height: 8),
                        Text('Config file: $_configFilePath'),
                      ],
                      const SizedBox(height: 16),
                      const Text(
                        'You can clear the current device binding and relaunch the app to create a new local device config for this installation.',
                      ),
                      const SizedBox(height: 20),
                      FilledButton.tonal(
                        onPressed: _isResetting ? null : _resetBinding,
                        child: Text(
                          _isResetting
                              ? 'Clearing device config...'
                              : 'Clear device config',
                        ),
                      ),
                      if (_resultMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _resultMessage!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
