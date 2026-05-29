import 'dart:convert';

import 'package:http/http.dart' as http;

import 'manual_host_config.dart';

class HostClient {
  HostClient({
    required this.config,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final ManualHostConfig config;
  final http.Client _httpClient;

  Future<bool> healthCheck() async {
    final Uri uri = Uri.parse('${config.baseUrl}/health');
    final http.Response response = await _httpClient.get(uri);
    return response.statusCode == 200;
  }

  Future<List<dynamic>> getRawMenuJson() async {
    final Uri uri = Uri.parse('${config.baseUrl}/menu');
    final http.Response response = await _httpClient.get(uri);
    _ensureOk(response);
    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<String> getMenuRaw() async {
    final Uri uri = Uri.parse('${config.baseUrl}/menu');
    final http.Response response = await _httpClient.get(uri);
    _ensureOk(response);
    return response.body;
  }

  Future<String> getActiveOrdersRaw() async {
    final Uri uri = Uri.parse('${config.baseUrl}/orders/active');
    final http.Response response = await _httpClient.get(uri);
    _ensureOk(response);
    return response.body;
  }

  Future<void> completeOrderItem(int itemId) async {
    final Uri uri = Uri.parse('${config.baseUrl}/order-items/$itemId/complete');
    final http.Response response = await _httpClient.post(uri);
    _ensureOk(response);
  }

  void _ensureOk(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw Exception(
        'Host request failed: ${response.statusCode} ${response.body}');
  }
}
