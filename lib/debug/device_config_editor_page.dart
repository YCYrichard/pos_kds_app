import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_session_state.dart';
import '../device_persistence/device_config_store.dart';
import '../device_persistence/device_record.dart';

class DeviceConfigEditorPage extends StatefulWidget {
  const DeviceConfigEditorPage({
    super.key,
    required this.deviceConfigStore,
  });

  final DeviceConfigStore deviceConfigStore;

  @override
  State<DeviceConfigEditorPage> createState() => _DeviceConfigEditorPageState();
}

class _DeviceConfigEditorPageState extends State<DeviceConfigEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _deviceNameController = TextEditingController();
  final _hostDeviceIdController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _message;
  DeviceRecord? _record;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _deviceNameController.dispose();
    _hostDeviceIdController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final record = await widget.deviceConfigStore.loadExisting();

    if (!mounted) return;

    setState(() {
      _record = record;
      _isLoading = false;
      _deviceNameController.text = record?.deviceName ?? '';
      _hostDeviceIdController.text = record?.hostDeviceId ?? '';
    });
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _message = null;
    });

    try {
      final updated = await widget.deviceConfigStore.updateIdentityFields(
        deviceName: _deviceNameController.text,
        hostDeviceId: _hostDeviceIdController.text,
      );

      if (!mounted) return;

      context.read<AppSessionState>().updatePersistentIdentity(
            deviceName: updated.deviceName,
            hostDeviceId: updated.hostDeviceId,
          );

      setState(() {
        _record = updated;
        _isSaving = false;
        _message =
            'Saved. Current debug session panel refreshed, including Host and Sync.';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _message = 'Failed to save device config: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Config Editor'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _record == null
              ? const Center(
                  child:
                      Text('No device config found. Start the app once first.'),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: ListView(
                              shrinkWrap: true,
                              children: [
                                Text(
                                  'Persistent Device Config',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text('Device ID: ${_record!.deviceId}'),
                                const SizedBox(height: 8),
                                Text(
                                  'Installed role: ${_record!.installedRole.name}',
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Default sync mode: ${_record!.defaultSyncMode.name}',
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _deviceNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Device name',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    final text = value?.trim() ?? '';
                                    if (text.isEmpty) {
                                      return 'Device name is required.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _hostDeviceIdController,
                                  decoration: const InputDecoration(
                                    labelText: 'Host device ID',
                                    hintText: 'Optional',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                FilledButton(
                                  onPressed: _isSaving ? null : _save,
                                  child: Text(
                                    _isSaving
                                        ? 'Saving...'
                                        : 'Save device config',
                                  ),
                                ),
                                if (_message != null) ...[
                                  const SizedBox(height: 16),
                                  Text(_message!),
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
