import 'package:flutter/material.dart';

import 'app_role.dart';

class BootstrapGuardMismatchApp extends StatelessWidget {
  const BootstrapGuardMismatchApp({
    super.key,
    required this.expectedRole,
    required this.persistedRole,
    required this.deviceId,
    required this.deviceName,
  });

  final AppRole expectedRole;
  final AppRole persistedRole;
  final String deviceId;
  final String deviceName;

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
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Device Role Mismatch'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: DefaultTextStyle(
                    style: Theme.of(context).textTheme.bodyLarge ??
                        const TextStyle(fontSize: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This app installation is already bound to a different installed role.',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        Text('Device name: $deviceName'),
                        const SizedBox(height: 8),
                        Text('Device ID: $deviceId'),
                        const SizedBox(height: 8),
                        Text('Entry role: ${expectedRole.name}'),
                        const SizedBox(height: 8),
                        Text('Persisted installed role: ${persistedRole.name}'),
                        const SizedBox(height: 16),
                        const Text(
                          'Use the matching app entry for this installation, or clear the local device config before rebinding the device.',
                        ),
                      ],
                    ),
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
