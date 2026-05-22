import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app_bootstrap_context.dart';

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
            Text(
              'Debug Session',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  label: 'Device',
                  value: contextData.deviceConfig.deviceName,
                ),
                _InfoChip(
                  label: 'Installed',
                  value: contextData.deviceConfig.installedRole.name,
                ),
                _InfoChip(
                  label: 'Runtime',
                  value: contextData.runtimeRole.name,
                  highlight: contextData.runtimeRole !=
                      contextData.deviceConfig.installedRole,
                ),
                _InfoChip(
                  label: 'Sync',
                  value: contextData.resolvedSyncMode.name,
                ),
                _InfoChip(
                  label: 'Override',
                  value: contextData.canOverrideRole ? 'enabled' : 'disabled',
                ),
                _InfoChip(
                  label: 'Host',
                  value: contextData.hostDeviceId ?? 'none',
                ),
              ],
            ),
            const SizedBox(height: 10),
            _InfoLine(
              label: 'Device ID',
              value: contextData.deviceConfig.deviceId,
            ),
            const SizedBox(height: 4),
            _InfoLine(
              label: 'Instance',
              value: contextData.appInstanceId,
            ),
            const SizedBox(height: 4),
            _InfoLine(
              label: 'Reason',
              value: contextData.resolutionReason,
            ),
            if (contextData.takeoverSourceRole != null) ...[
              const SizedBox(height: 4),
              _InfoLine(
                label: 'Takeover From',
                value: contextData.takeoverSourceRole!.name,
              ),
            ],
          ],
        ),
      ),
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
