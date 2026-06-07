import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pos_kds_app/data/repositories/order_repository.dart';

import 'host_api_models.dart';
import 'manual_host_config.dart';

class HostClient {
  HostClient({
    required this.config,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final ManualHostConfig config;
  final http.Client _httpClient;

  Uri _buildUri(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    return Uri(
      scheme: 'http',
      host: config.host,
      port: config.port,
      path: path,
      queryParameters: queryParameters,
    );
  }

  Future<bool> healthCheck() async {
    final Uri uri = _buildUri('/health');
    debugPrint('HostClient.healthCheck GET $uri');

    final http.Response response =
        await _httpClient.get(uri).timeout(const Duration(seconds: 8));

    debugPrint(
      'HostClient.healthCheck status=${response.statusCode} body=${response.body}',
    );

    return response.statusCode == 200;
  }

  Future<List<dynamic>> getRawMenuJson() async {
    final Uri uri = _buildUri('/menu');
    debugPrint('HostClient.getRawMenuJson GET $uri');

    final http.Response response =
        await _httpClient.get(uri).timeout(const Duration(seconds: 8));

    debugPrint(
      'HostClient.getRawMenuJson status=${response.statusCode} body=${response.body}',
    );

    _ensureOk(response);
    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<String> getMenuRaw() async {
    final Uri uri = _buildUri('/menu');
    debugPrint('HostClient.getMenuRaw GET $uri');

    final http.Response response =
        await _httpClient.get(uri).timeout(const Duration(seconds: 8));

    debugPrint(
      'HostClient.getMenuRaw status=${response.statusCode} body=${response.body}',
    );

    _ensureOk(response);
    return response.body;
  }

  Future<String> getActiveOrdersRaw() async {
    final Uri uri = _buildUri('/orders/active');
    debugPrint('HostClient.getActiveOrdersRaw GET $uri');

    final http.Response response =
        await _httpClient.get(uri).timeout(const Duration(seconds: 8));

    debugPrint(
      'HostClient.getActiveOrdersRaw status=${response.statusCode} body=${response.body}',
    );

    _ensureOk(response);
    return response.body;
  }

  Future<List<OrderBundle>> getActiveOrderBundles() async {
    final String raw = await getActiveOrdersRaw();
    return decodeActiveBundles(raw);
  }

  Future<void> submitOrder({
    required Map<String, Object?> order,
    required List<Map<String, Object?>> items,
  }) async {
    final Uri uri = _buildUri('/orders');
    debugPrint('HostClient.submitOrder POST $uri');

    final http.Response response = await _httpClient
        .post(
          uri,
          headers: const <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, Object?>{
            'order': order,
            'items': items,
          }),
        )
        .timeout(const Duration(seconds: 8));

    debugPrint(
      'HostClient.submitOrder status=${response.statusCode} body=${response.body}',
    );

    _ensureOk(response);
  }

  Future<void> completeOrderItem(int itemId) async {
    final Uri uri = _buildUri('/order-items/$itemId/complete');
    debugPrint('HostClient.completeOrderItem POST $uri');

    final http.Response response =
        await _httpClient.post(uri).timeout(const Duration(seconds: 8));

    debugPrint(
      'HostClient.completeOrderItem status=${response.statusCode} body=${response.body}',
    );

    _ensureOk(response);
  }

  Future<List<Map<String, dynamic>>> getSyncEventsSince(
    String? minHlcExclusive,
  ) async {
    final Uri uri = _buildUri(
      '/sync/events',
      queryParameters: minHlcExclusive == null
          ? null
          : <String, String>{
              'since': minHlcExclusive,
            },
    );

    debugPrint('HostClient.getSyncEventsSince GET $uri');

    final http.Response response =
        await _httpClient.get(uri).timeout(const Duration(seconds: 8));

    debugPrint(
      'HostClient.getSyncEventsSince status=${response.statusCode} body=${response.body}',
    );

    _ensureOk(response);

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded
          .map((dynamic e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }

    throw Exception('Unexpected sync events payload: ${response.body}');
  }

  void dispose() {
    _httpClient.close();
  }

  void _ensureOk(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception(
      'Host request failed: ${response.statusCode} ${response.body}',
    );
  }
}
