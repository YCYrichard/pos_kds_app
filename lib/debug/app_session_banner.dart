import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_session_state.dart';
import '../device_persistence/device_config_store.dart';
import 'device_config_editor_page.dart';

class AppSessionBanner extends StatelessWidget {
  const AppSessionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<AppSessionState>(
      builder: (context, session, child) {
        return Material(
          color: colorScheme.surfaceContainerHighest,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Debug Session',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final store = context.read<DeviceConfigStore>();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => DeviceConfigEditorPage(
                              deviceConfigStore: store,
                            ),
                          ),
                        );
                      },
                      child: const Text('Edit'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      label: 'Device',
                      value: session.deviceName,
                    ),
                    _InfoChip(
                      label: 'Installed',
                      value: session.installedRole.name,
                    ),
                    _InfoChip(
                      label: 'Runtime',
                      value: session.runtimeRole.name,
                      highlight: session.runtimeRole != session.installedRole,
                    ),
                    _InfoChip(
                      label: 'Sync',
                      value: session.resolvedSyncMode.name,
                    ),
                    _InfoChip(
                      label: 'Override',
                      value: session.canOverrideRole ? 'enabled' : 'disabled',
                    ),
                    _InfoChip(
                      label: 'Host',
                      value: session.hostDeviceId ?? 'none',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _InfoLine(
                  label: 'Device ID',
                  value: session.deviceId,
                ),
                const SizedBox(height: 4),
                _InfoLine(
                  label: 'Instance',
                  value: session.appInstanceId,
                ),
                const SizedBox(height: 4),
                _InfoLine(
                  label: 'Reason',
                  value: session.resolutionReason,
                ),
                if (session.takeoverSourceRole != null) ...[
                  const SizedBox(height: 4),
                  _InfoLine(
                    label: 'Takeover From',
                    value: session.takeoverSourceRole!.name,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final backgroundColor = highlight
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerLow;

    final foregroundColor = highlight
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlight
              ? colorScheme.primary.withValues(alpha: 0.35)
              : colorScheme.outlineVariant,
        ),
      ),
      child: DefaultTextStyle(
        style: theme.textTheme.bodySmall!.copyWith(
          color: foregroundColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: foregroundColor.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: value,
          ),
        ],
      ),
    );
  }
}
