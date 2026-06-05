// lib/core/network/bootstrap_service.dart

import 'dart:convert';

import 'package:http/http.dart' as http;

class BootstrapStoreInfo {
  final String storeId;
  final String? storeName;
  final String? hostDeviceId;
  final String hostUrl;

  const BootstrapStoreInfo({
    required this.storeId,
    required this.storeName,
    required this.hostDeviceId,
    required this.hostUrl,
  });

  factory BootstrapStoreInfo.fromJson(Map<String, dynamic> json) {
    return BootstrapStoreInfo(
      storeId: json['store_id'] as String,
      storeName: json['store_name'] as String?,
      hostDeviceId: json['device_id'] as String?,
      hostUrl: json['host_url'] as String,
    );
  }
}

class BootstrapService {
  BootstrapService({
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Future<BootstrapStoreInfo> fetchStoreInfo(String baseUrl) async {
    final uri = Uri.parse('$baseUrl/host-info');
    final response = await _httpClient.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch host info: ${response.statusCode} ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected host info payload: ${response.body}');
    }

    return BootstrapStoreInfo.fromJson(decoded);
  }

  Future<BootstrapStoreInfo> joinStore({
    required String baseUrl,
    required String deviceId,
    String? displayName,
  }) async {
    final uri = Uri.parse('$baseUrl/bootstrap/join');
    final response = await _httpClient.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'device_id': deviceId,
        'display_name': displayName,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to join store: ${response.statusCode} ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected join payload: ${response.body}');
    }

    return BootstrapStoreInfo.fromJson(decoded);
  }

  void dispose() {
    _httpClient.close();
  }
}
