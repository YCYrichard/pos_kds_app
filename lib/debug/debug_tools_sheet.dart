import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import '../app_bootstrap_context.dart';
import '../app_session_state.dart';
import '../data/db/app_database.dart';

class DebugToolsSheet extends StatefulWidget {
  const DebugToolsSheet({super.key});

  @override
  State<DebugToolsSheet> createState() => _DebugToolsSheetState();
}

class _DebugToolsSheetState extends State<DebugToolsSheet> {
  bool _busy = false;
  bool? _healthOk;
  int? _remoteActiveOrdersCount;
  int? _remoteActiveOrderItemsCount;
  int? _localActiveOrdersCount;
  int? _localOrderItemsCount;
  DateTime? _lastCheckedAt;
  String? _lastAction;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _refreshLocalCounts();
  }

  Future<void> _runAction(
    Future<void> Function(AppBootstrapContext bootstrapContext) action, {
    required String label,
  }) async {
    if (_busy) return;

    final bootstrapContext = context.read<AppBootstrapContext>();

    setState(() {
      _busy = true;
      _lastError = null;
      _lastAction = '$label...';
    });

    try {
      await action(bootstrapContext);
      if (!mounted) return;
      setState(() {
        _lastCheckedAt = DateTime.now();
        _lastAction = '$label done';
      });
    } catch (e, st) {
      debugPrint('DebugToolsSheet action error: $e');
      debugPrint('$st');
      if (!mounted) return;
      setState(() {
        _lastCheckedAt = DateTime.now();
        _lastError = e.toString();
        _lastAction = '$label failed';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _checkHealth(AppBootstrapContext bootstrapContext) async {
    final client = bootstrapContext.networkSession.hostClient;
    if (client == null) {
      setState(() {
        _healthOk = null;
        _lastAction = 'No host client available';
      });
      return;
    }

    final ok = await client.healthCheck();
    setState(() {
      _healthOk = ok;
    });
  }

  Future<void> _pullMenu(AppBootstrapContext bootstrapContext) async {
    final service = bootstrapContext.networkSession.menuSyncService;
    if (service == null) {
      setState(() {
        _lastAction = 'No menu sync service available';
      });
      return;
    }
    await service.syncOnce();
  }

  Future<void> _checkRemoteActiveOrders(
    AppBootstrapContext bootstrapContext,
  ) async {
    final client = bootstrapContext.networkSession.hostClient;
    if (client == null) {
      setState(() {
        _remoteActiveOrdersCount = null;
        _remoteActiveOrderItemsCount = null;
        _lastAction = 'No host client available';
      });
      return;
    }

    final bundles = await client.getActiveOrderBundles();
    final itemCount = bundles.fold<int>(
      0,
      (sum, bundle) => sum + bundle.items.length,
    );

    setState(() {
      _remoteActiveOrdersCount = bundles.length;
      _remoteActiveOrderItemsCount = itemCount;
    });
  }

  Future<void> _pullActiveOrders(AppBootstrapContext bootstrapContext) async {
    final service = bootstrapContext.networkSession.orderMirrorSyncService;
    if (service == null) {
      setState(() {
        _lastAction = 'No order mirror sync service available';
      });
      return;
    }

    await service.syncActiveOrdersOnce();
    await _checkRemoteActiveOrders(bootstrapContext);
    await _refreshLocalCounts();
  }

  Future<void> _refreshLocalCounts() async {
    final db = await AppDatabase.database;

    final activeOrders = Sqflite.firstIntValue(
      await db.rawQuery(
        "SELECT COUNT(*) FROM orders WHERE status != 'completed'",
      ),
    );

    final orderItems = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM order_items"),
    );

    if (!mounted) return;
    setState(() {
      _localActiveOrdersCount = activeOrders ?? 0;
      _localOrderItemsCount = orderItems ?? 0;
      _lastCheckedAt = DateTime.now();
      _lastAction = 'Local DB counts refreshed';
    });
  }

  Future<void> _copyDiagnostics() async {
    final session = context.read<AppSessionState>();
    final bootstrapContext = context.read<AppBootstrapContext>();
    final networkSession = bootstrapContext.networkSession;
    final hostConfig = networkSession.hostConfig;

    final text = _buildDiagnosticsText(
      session: session,
      bootstrapContext: bootstrapContext,
      host: hostConfig?.host ?? 'none',
      baseUrl: hostConfig?.baseUrl ?? 'none',
      mode: networkSession.mode,
    );

    await Clipboard.setData(ClipboardData(text: text));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Diagnostics copied to clipboard'),
      ),
    );
  }

  String _buildDiagnosticsText({
    required AppSessionState session,
    required AppBootstrapContext bootstrapContext,
    required String host,
    required String baseUrl,
    required String mode,
  }) {
    final lines = <String>[
      'Debug Tools Diagnostics',
      'Device: ${session.deviceName}',
      'Device ID: ${session.deviceId}',
      'Installed role: ${session.installedRole.name}',
      'Runtime role: ${session.runtimeRole.name}',
      'Resolved sync: ${session.resolvedSyncMode.name}',
      'Host device ID: ${session.hostDeviceId ?? 'none'}',
      'Instance: ${session.appInstanceId}',
      'Reason: ${session.resolutionReason}',
      'Takeover from: ${session.takeoverSourceRole?.name ?? 'none'}',
      'Mode: $mode',
      'Host: $host',
      'Base URL: $baseUrl',
      'Health: ${_healthOk == null ? 'not checked' : (_healthOk! ? 'ok' : 'failed')}',
      'Remote active orders: ${_remoteActiveOrdersCount?.toString() ?? 'unknown'}',
      'Remote active items: ${_remoteActiveOrderItemsCount?.toString() ?? 'unknown'}',
      'Local active orders: ${_localActiveOrdersCount?.toString() ?? 'unknown'}',
      'Local order items: ${_localOrderItemsCount?.toString() ?? 'unknown'}',
      'Menu sync service: ${bootstrapContext.networkSession.menuSyncService == null ? 'unavailable' : 'available'}',
      'Order mirror sync: ${bootstrapContext.networkSession.orderMirrorSyncService == null ? 'unavailable' : 'available'}',
      'Host client: ${bootstrapContext.networkSession.hostClient == null ? 'unavailable' : 'available'}',
      'Last checked: ${_lastCheckedAt == null ? 'unknown' : _formatDateTime(_lastCheckedAt!)}',
      'Last action: ${_lastAction ?? 'none'}',
      'Last error: ${_lastError ?? 'none'}',
    ];

    return lines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final session = context.watch<AppSessionState>();
    final bootstrapContext = context.read<AppBootstrapContext>();
    final networkSession = bootstrapContext.networkSession;
    final hostConfig = networkSession.hostConfig;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.88,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: const Text('Debug Tools'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: _busy
                  ? null
                  : () => _runAction(
                        (_) => _refreshLocalCounts(),
                        label: 'Refresh local counts',
                      ),
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh local counts',
            ),
            IconButton(
              onPressed: _busy ? null : _copyDiagnostics,
              icon: const Icon(Icons.copy_all_outlined),
              tooltip: 'Copy diagnostics',
            ),
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.close),
              tooltip: 'Close',
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionCard(
              title: 'Session',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoLine(label: 'Device', value: session.deviceName),
                  _InfoLine(label: 'Device ID', value: session.deviceId),
                  _InfoLine(
                    label: 'Installed role',
                    value: session.installedRole.name,
                  ),
                  _InfoLine(
                    label: 'Runtime role',
                    value: session.runtimeRole.name,
                  ),
                  _InfoLine(
                    label: 'Resolved sync',
                    value: session.resolvedSyncMode.name,
                  ),
                  _InfoLine(
                    label: 'Host device ID',
                    value: session.hostDeviceId ?? 'none',
                  ),
                  _InfoLine(
                    label: 'Instance',
                    value: session.appInstanceId,
                  ),
                  _InfoLine(
                    label: 'Reason',
                    value: session.resolutionReason,
                  ),
                  if (session.takeoverSourceRole != null)
                    _InfoLine(
                      label: 'Takeover from',
                      value: session.takeoverSourceRole!.name,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Network',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoLine(label: 'Mode', value: networkSession.mode),
                  _InfoLine(
                    label: 'Host',
                    value: hostConfig?.host ?? 'none',
                  ),
                  _InfoLine(
                    label: 'Base URL',
                    value: hostConfig?.baseUrl ?? 'none',
                  ),
                  _InfoLine(
                    label: 'Health',
                    value: _healthOk == null
                        ? 'not checked'
                        : (_healthOk! ? 'ok' : 'failed'),
                  ),
                  if (_lastCheckedAt != null)
                    _InfoLine(
                      label: 'Last checked',
                      value: _formatDateTime(_lastCheckedAt!),
                    ),
                  if (_lastAction != null)
                    _InfoLine(
                      label: 'Last action',
                      value: _lastAction!,
                    ),
                  if (_lastError != null)
                    _InfoLine(
                      label: 'Last error',
                      value: _lastError!,
                      error: true,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Sync Tools',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: _busy
                            ? null
                            : () => _runAction(
                                  _checkHealth,
                                  label: 'Health check',
                                ),
                        icon: const Icon(Icons.favorite_border),
                        label: const Text('Check health'),
                      ),
                      FilledButton.icon(
                        onPressed: _busy
                            ? null
                            : () => _runAction(
                                  _pullMenu,
                                  label: 'Pull menu',
                                ),
                        icon: const Icon(Icons.menu_book_outlined),
                        label: const Text('Pull menu'),
                      ),
                      FilledButton.icon(
                        onPressed: _busy
                            ? null
                            : () => _runAction(
                                  _checkRemoteActiveOrders,
                                  label: 'Check remote active orders',
                                ),
                        icon: const Icon(Icons.cloud_outlined),
                        label: const Text('Check remote orders'),
                      ),
                      FilledButton.icon(
                        onPressed: _busy
                            ? null
                            : () => _runAction(
                                  _pullActiveOrders,
                                  label: 'Pull active orders',
                                ),
                        icon: const Icon(Icons.sync),
                        label: const Text('Pull active orders'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _busy
                            ? null
                            : () => _runAction(
                                  (_) => _refreshLocalCounts(),
                                  label: 'Refresh local counts',
                                ),
                        icon: const Icon(Icons.storage_outlined),
                        label: const Text('Refresh local DB'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InfoLine(
                    label: 'Remote active orders',
                    value: _remoteActiveOrdersCount?.toString() ?? 'unknown',
                  ),
                  _InfoLine(
                    label: 'Remote active items',
                    value:
                        _remoteActiveOrderItemsCount?.toString() ?? 'unknown',
                  ),
                  _InfoLine(
                    label: 'Local active orders',
                    value: _localActiveOrdersCount?.toString() ?? 'unknown',
                  ),
                  _InfoLine(
                    label: 'Local order items',
                    value: _localOrderItemsCount?.toString() ?? 'unknown',
                  ),
                  _InfoLine(
                    label: 'Menu sync service',
                    value: networkSession.menuSyncService == null
                        ? 'unavailable'
                        : 'available',
                  ),
                  _InfoLine(
                    label: 'Order mirror sync',
                    value: networkSession.orderMirrorSyncService == null
                        ? 'unavailable'
                        : 'available',
                  ),
                  _InfoLine(
                    label: 'Host client',
                    value: networkSession.hostClient == null
                        ? 'unavailable'
                        : 'available',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Notes',
              child: Text(
                'Use this panel to verify host connectivity, compare remote and local order counts, '
                'trigger manual sync, and copy diagnostics without opening Logcat.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: theme.textTheme.bodyMedium ?? const TextStyle(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
    this.error = false,
  });

  final String label;
  final String value;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final valueColor = error ? colorScheme.error : colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
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
              style: TextStyle(
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
