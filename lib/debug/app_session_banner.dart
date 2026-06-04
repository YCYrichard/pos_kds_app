import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_role.dart';
import '../app_session_state.dart';
import '../device_persistence/device_config_store.dart';
import 'debug_tools_sheet.dart';
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

    return SafeArea(
      top: true,
      bottom: false,
      child: Consumer<AppSessionState>(
        builder: (context, session, child) {
          return Material(
            color: colorScheme.surfaceContainerHighest,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _MiniChip(
                            label: 'Device',
                            value: session.deviceName,
                          ),
                          const SizedBox(width: 8),
                          _MiniChip(
                            label: 'Runtime',
                            value: session.runtimeRole.name,
                            highlight:
                                session.runtimeRole != session.installedRole,
                          ),
                          const SizedBox(width: 8),
                          _MiniChip(
                            label: 'Sync',
                            value: session.resolvedSyncMode.name,
                          ),
                          const SizedBox(width: 8),
                          _MiniChip(
                            label: 'Host',
                            value: session.hostDeviceId ?? 'none',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _BannerActionButton(
                    label: 'Edit',
                    onPressed: () {
                      final store = context.read<DeviceConfigStore>();
                      showModalBottomSheet<void>(
                        context: context,
                        useSafeArea: true,
                        isScrollControlled: true,
                        showDragHandle: true,
                        builder: (sheetContext) {
                          return SizedBox(
                            height:
                                MediaQuery.of(sheetContext).size.height * 0.9,
                            child: DeviceConfigEditorPage(
                              deviceConfigStore: store,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  PopupMenuButton<AppRole>(
                    tooltip: 'Switch runtime role',
                    onSelected: (role) {
                      context.read<AppSessionState>().updateRuntimeRole(role);
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: AppRole.frontdesk,
                        child: Text('Frontdesk'),
                      ),
                      PopupMenuItem(
                        value: AppRole.kitchen,
                        child: Text('Kitchen'),
                      ),
                      PopupMenuItem(
                        value: AppRole.backoffice,
                        child: Text('Backoffice'),
                      ),
                      PopupMenuItem(
                        value: AppRole.combined,
                        child: Text('Combined'),
                      ),
                    ],
                    child: const _BannerActionButton(
                      label: 'Role',
                      icon: Icons.swap_horiz,
                    ),
                  ),
                  const SizedBox(width: 4),
                  _BannerActionButton(
                    label: 'Tools',
                    icon: Icons.bug_report_outlined,
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        useSafeArea: true,
                        isScrollControlled: true,
                        showDragHandle: true,
                        builder: (sheetContext) {
                          return const DebugToolsSheet();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: highlight
              ? colorScheme.primary.withValues(alpha: 0.35)
              : colorScheme.outlineVariant,
        ),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: theme.textTheme.labelMedium?.copyWith(
                color: foregroundColor.withValues(alpha: 0.82),
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value,
              style: theme.textTheme.labelMedium?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      ),
    );
  }
}

class _BannerActionButton extends StatelessWidget {
  const _BannerActionButton({
    required this.label,
    this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
