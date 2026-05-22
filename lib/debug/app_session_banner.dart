import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app_bootstrap_context.dart';
import '../app_role.dart';
import '../sync_mode.dart';

class AppSessionBanner extends StatelessWidget {
  const AppSessionBanner({
    super.key,
    required this.contextData,
  });

  final AppBootstrapContext contextData;

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant,
            ),
          ),
        ),
        child: DefaultTextStyle(
          style: theme.textTheme.bodySmall!.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _MetaText(
                label: 'device',
                value: contextData.deviceConfig.deviceName,
              ),
              _MetaText(
                label: 'deviceId',
                value: contextData.deviceConfig.deviceId,
              ),
              _MetaText(
                label: 'installedRole',
                value: _roleText(contextData.deviceConfig.installedRole),
              ),
              _MetaText(
                label: 'runtimeRole',
                value: _roleText(contextData.runtimeRole),
              ),
              _MetaText(
                label: 'syncMode',
                value: _syncModeText(contextData.resolvedSyncMode),
              ),
              _MetaText(
                label: 'instance',
                value: contextData.appInstanceId,
              ),
              if (contextData.hostDeviceId != null &&
                  contextData.hostDeviceId!.isNotEmpty)
                _MetaText(
                  label: 'host',
                  value: contextData.hostDeviceId!,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _roleText(AppRole role) {
    return role.name;
  }

  String _syncModeText(SyncMode mode) {
    return mode.name;
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text('$label=$value');
  }
}
