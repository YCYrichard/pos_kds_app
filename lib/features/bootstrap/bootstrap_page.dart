import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bootstrap_controller.dart';

class BootstrapPage extends StatefulWidget {
  const BootstrapPage({super.key});

  @override
  State<BootstrapPage> createState() => _BootstrapPageState();
}

class _BootstrapPageState extends State<BootstrapPage> {
  final TextEditingController _storeNameController = TextEditingController();

  @override
  void dispose() {
    _storeNameController.dispose();
    super.dispose();
  }

  Future<void> _openDiagnosticsPage(BuildContext pageContext) async {
    final controller = pageContext.read<BootstrapController>();

    await Navigator.of(pageContext).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return ChangeNotifierProvider<BootstrapController>.value(
            value: controller,
            child: const _BootstrapDiagnosticsPage(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BootstrapController>(
      builder: (context, controller, _) {
        final record = controller.bootstrapRecord;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Store bootstrap'),
            actions: [
              IconButton(
                onPressed: () => _openDiagnosticsPage(context),
                icon: const Icon(Icons.bug_report_outlined),
                tooltip: 'Open diagnostics',
              ),
            ],
          ),
          body: SafeArea(
            child: controller.initializing
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Device ID: ${record?.deviceId ?? '-'}'),
                              const SizedBox(height: 8),
                              Text(
                                'Installed role: ${record?.installedRole.name ?? '-'}',
                              ),
                              const SizedBox(height: 8),
                              Text('Store ID: ${record?.storeId ?? '-'}'),
                              const SizedBox(height: 8),
                              Text('Store name: ${record?.storeName ?? '-'}'),
                              const SizedBox(height: 8),
                              Text('Host URL: ${record?.hostUrl ?? '-'}'),
                              const SizedBox(height: 8),
                              Text(
                                'Host device ID: ${record?.hostDeviceId ?? '-'}',
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Local IPv4: ${controller.localIpv4 ?? '-'}',
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Subnet: ${controller.subnetPrefix ?? '-'}',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (controller.message != null)
                        Card(
                          color: Colors.blueGrey.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(controller.message!),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Create new store',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _storeNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Store name',
                                ),
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: controller.creatingStore
                                    ? null
                                    : () async {
                                        await controller.createNewStore(
                                          storeName: _storeNameController.text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : _storeNameController.text
                                                  .trim(),
                                        );
                                      },
                                icon: controller.creatingStore
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.add_business_outlined),
                                label: const Text('Create new store'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Discover stores on LAN',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: controller.discovering
                                        ? null
                                        : () async {
                                            await controller.discoverStores();
                                          },
                                    icon: controller.discovering
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.wifi_find_outlined),
                                    label: const Text('Scan local network'),
                                  ),
                                  TextButton.icon(
                                    onPressed: () async {
                                      await controller.refreshNetworkInfo();
                                    },
                                    icon: const Icon(Icons.refresh_outlined),
                                    label: const Text('Refresh network info'),
                                  ),
                                  TextButton.icon(
                                    onPressed: () =>
                                        _openDiagnosticsPage(context),
                                    icon: const Icon(Icons.bug_report_outlined),
                                    label: const Text('Open diagnostics'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (controller.discoveredHosts.isEmpty)
                                const Text('No discovered stores yet.')
                              else
                                ...controller.discoveredHosts.map(
                                  (host) => Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: ListTile(
                                      title: Text(
                                        host.storeName?.isNotEmpty == true
                                            ? host.storeName!
                                            : (host.storeId ?? host.baseUrl),
                                      ),
                                      subtitle: Text(
                                        '${host.baseUrl}\nStore ID: ${host.storeId ?? '-'}',
                                      ),
                                      isThreeLine: true,
                                      trailing: FilledButton(
                                        onPressed: controller.joining
                                            ? null
                                            : () async {
                                                await controller
                                                    .joinDiscoveredHost(host);
                                              },
                                        child: const Text('Join'),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _BootstrapDiagnosticsPage extends StatelessWidget {
  const _BootstrapDiagnosticsPage();

  @override
  Widget build(BuildContext context) {
    return Consumer<BootstrapController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Bootstrap diagnostics'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _DiagCard(
                title: 'Network info',
                children: [
                  _DiagLine('Local IPv4', controller.localIpv4 ?? 'unknown'),
                  _DiagLine(
                      'Subnet prefix', controller.subnetPrefix ?? 'unknown'),
                  _DiagLine(
                      'Discovery port', controller.discoveryPort.toString()),
                  _DiagLine(
                    'Last discovery at',
                    controller.lastDiscoveryAt?.toLocal().toString() ?? 'never',
                  ),
                  _DiagLine('Last message', controller.message ?? 'none'),
                  _DiagLine(
                    'Last discovery error',
                    controller.lastDiscoveryError ?? 'none',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _DiagCard(
                title: 'Discovery results',
                children: [
                  _DiagLine(
                    'Discovered hosts',
                    controller.discoveredHosts.length.toString(),
                  ),
                  if (controller.discoveredHosts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('No discovered hosts yet.'),
                    )
                  else
                    ...controller.discoveredHosts.map(
                      (host) => Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          '${host.baseUrl}\n'
                          'store=${host.storeName ?? host.storeId ?? 'unknown'}\n'
                          'device=${host.deviceId ?? 'unknown'}\n'
                          'role=${host.role ?? 'unknown'}',
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: controller.discovering
                    ? null
                    : () async {
                        await controller.discoverStores();
                      },
                icon: const Icon(Icons.wifi_find_outlined),
                label: const Text('Run discovery again'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DiagCard extends StatelessWidget {
  const _DiagCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DiagLine extends StatelessWidget {
  const _DiagLine(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text('$label: $value'),
    );
  }
}
