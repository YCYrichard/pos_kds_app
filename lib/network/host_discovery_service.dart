// lib/core/network/host_discovery_service.dart

import 'dart:convert';

import 'package:http/http.dart' as http;

class DiscoveredHost {
  final String baseUrl;
  final String? deviceId;
  final String? storeId;
  final String? storeName;
  final String? role;

  const DiscoveredHost({
    required this.baseUrl,
    this.deviceId,
    this.storeId,
    this.storeName,
    this.role,
  });

  factory DiscoveredHost.fromJson({
    required String baseUrl,
    required Map<String, dynamic> json,
  }) {
    return DiscoveredHost(
      baseUrl: baseUrl,
      deviceId: json['device_id'] as String?,
      storeId: json['store_id'] as String?,
      storeName: json['store_name'] as String?,
      role: json['role'] as String?,
    );
  }
}

class HostDiscoveryService {
  HostDiscoveryService({
    http.Client? httpClient,
    this.port = 8080,
  }) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  final int port;

  Future<List<DiscoveredHost>> scanSubnet(String subnetPrefix) async {
    final futures = <Future<DiscoveredHost?>>[];

    for (int i = 1; i <= 254; i++) {
      final host = '$subnetPrefix.$i';
      futures.add(_probeHost(host));
    }

    final results = await Future.wait(futures);
    return results.whereType<DiscoveredHost>().toList();
  }

  Future<DiscoveredHost?> _probeHost(String host) async {
    final baseUrl = 'http://$host:$port';
    final uri = Uri.parse('$baseUrl/host-info');

    try {
      final response =
          await _httpClient.get(uri).timeout(const Duration(milliseconds: 500));

      if (response.statusCode != 200) {
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return DiscoveredHost.fromJson(
        baseUrl: baseUrl,
        json: decoded,
      );
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
