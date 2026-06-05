import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class DiscoveredHost {
  const DiscoveredHost({
    required this.baseUrl,
    this.deviceId,
    this.storeId,
    this.storeName,
    this.role,
  });

  final String baseUrl;
  final String? deviceId;
  final String? storeId;
  final String? storeName;
  final String? role;

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

class HostProbeResult {
  const HostProbeResult({
    required this.host,
    required this.baseUrl,
    required this.port,
    this.discoveredHost,
    this.statusCode,
    this.error,
    this.responded = false,
  });

  final String host;
  final String baseUrl;
  final int port;
  final DiscoveredHost? discoveredHost;
  final int? statusCode;
  final String? error;
  final bool responded;

  bool get isSuccess => discoveredHost != null;
}

class HostDiscoveryScanReport {
  const HostDiscoveryScanReport({
    required this.subnetPrefix,
    required this.port,
    required this.scannedHosts,
    required this.startedAt,
    required this.finishedAt,
    required this.results,
  });

  final String subnetPrefix;
  final int port;
  final int scannedHosts;
  final DateTime startedAt;
  final DateTime finishedAt;
  final List<HostProbeResult> results;

  Duration get duration => finishedAt.difference(startedAt);

  List<DiscoveredHost> get discoveredHosts => results
      .where((result) => result.discoveredHost != null)
      .map((result) => result.discoveredHost!)
      .toList();

  List<HostProbeResult> get respondedHosts =>
      results.where((result) => result.responded).toList();

  List<HostProbeResult> get failedHosts =>
      results.where((result) => result.error != null).toList();
}

class HostDiscoveryService {
  HostDiscoveryService({
    http.Client? httpClient,
    this.port = 8787,
    this.probeTimeout = const Duration(milliseconds: 800),
    this.maxHost = 254,
  }) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  final int port;
  final Duration probeTimeout;
  final int maxHost;

  HostDiscoveryScanReport? _lastReport;

  HostDiscoveryScanReport? get lastReport => _lastReport;

  Future<List<DiscoveredHost>> scanSubnet(String subnetPrefix) async {
    final report = await scanSubnetDetailed(subnetPrefix);
    return report.discoveredHosts;
  }

  Future<HostDiscoveryScanReport> scanSubnetDetailed(
      String subnetPrefix) async {
    final DateTime startedAt = DateTime.now();
    final futures = <Future<HostProbeResult>>[];

    for (int i = 1; i <= maxHost; i++) {
      final host = '$subnetPrefix.$i';
      futures.add(_probeHost(host));
    }

    final List<HostProbeResult> results = await Future.wait(futures);
    final DateTime finishedAt = DateTime.now();

    final HostDiscoveryScanReport report = HostDiscoveryScanReport(
      subnetPrefix: subnetPrefix,
      port: port,
      scannedHosts: maxHost,
      startedAt: startedAt,
      finishedAt: finishedAt,
      results: results,
    );

    _lastReport = report;
    return report;
  }

  Future<HostProbeResult> probeSingleHost(String host) async {
    return _probeHost(host);
  }

  Future<HostProbeResult> _probeHost(String host) async {
    final String baseUrl = 'http://$host:$port';
    final Uri uri = Uri.parse('$baseUrl/host-info');

    try {
      final http.Response response =
          await _httpClient.get(uri).timeout(probeTimeout);

      if (response.statusCode != 200) {
        return HostProbeResult(
          host: host,
          baseUrl: baseUrl,
          port: port,
          statusCode: response.statusCode,
          responded: true,
          error: 'HTTP ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return HostProbeResult(
          host: host,
          baseUrl: baseUrl,
          port: port,
          statusCode: response.statusCode,
          responded: true,
          error: 'Invalid JSON shape',
        );
      }

      final discoveredHost = DiscoveredHost.fromJson(
        baseUrl: baseUrl,
        json: decoded,
      );

      return HostProbeResult(
        host: host,
        baseUrl: baseUrl,
        port: port,
        statusCode: response.statusCode,
        responded: true,
        discoveredHost: discoveredHost,
      );
    } on TimeoutException {
      return HostProbeResult(
        host: host,
        baseUrl: baseUrl,
        port: port,
        error: 'timeout',
      );
    } catch (e) {
      return HostProbeResult(
        host: host,
        baseUrl: baseUrl,
        port: port,
        error: e.toString(),
      );
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
