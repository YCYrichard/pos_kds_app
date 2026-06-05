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

  @override
  Widget build(BuildContext context) {
    return Consumer<BootstrapController>(
      builder: (context, controller, _) {
        final record = controller.bootstrapRecord;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Store bootstrap'),
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
