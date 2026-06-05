import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'local_network_info.dart';
import '../../data/models/device_config.dart';
import '../../data/models/store_config.dart';
import '../../data/repositories/device_config_repository.dart';

class HostServer {
  HostServer({
    required DeviceConfigRepository deviceConfigRepository,
    LocalNetworkInfo? localNetworkInfo,
    this.port = 8787,
  })  : _deviceConfigRepository = deviceConfigRepository,
        _localNetworkInfo = localNetworkInfo ?? LocalNetworkInfo();

  final DeviceConfigRepository _deviceConfigRepository;
  final LocalNetworkInfo _localNetworkInfo;
  final int port;

  HttpServer? _server;
  Future<void>? _starting;

  bool get isRunning => _server != null;

  Future<void> start() {
    if (_server != null) {
      debugPrint(
        'HostServer.start skipped: already running on port ${_server!.port}',
      );
      return Future<void>.value();
    }

    final existingStart = _starting;
    if (existingStart != null) {
      debugPrint('HostServer.start skipped: start already in progress');
      return existingStart;
    }

    final future = _startInternal();
    _starting = future;
    return future.whenComplete(() {
      _starting = null;
    });
  }

  Future<void> _startInternal() async {
    if (_server != null) {
      return;
    }

    debugPrint('HostServer starting on 0.0.0.0:$port');

    final server = await HttpServer.bind(
      InternetAddress.anyIPv4,
      port,
      shared: true,
    );

    _server = server;
    _listen(server);

    final hostUrl = await buildHostUrl();
    debugPrint(
      'HostServer started on ${server.address.address}:${server.port}'
      '${hostUrl == null ? '' : ' hostUrl=$hostUrl'}',
    );
  }

  Future<void> stop() async {
    final server = _server;
    _server = null;
    debugPrint(
      'HostServer stopping${server == null ? '' : ' on port ${server.port}'}',
    );
    await server?.close(force: true);
  }

  Future<String?> buildHostUrl() async {
    final ip = await _localNetworkInfo.getLocalIpv4();
    if (ip == null) {
      return null;
    }
    return 'http://$ip:$port';
  }

  void _listen(HttpServer server) {
    server.listen((HttpRequest request) async {
      try {
        final path = request.uri.path;
        final method = request.method.toUpperCase();

        debugPrint('HostServer request: $method $path');

        if (method == 'GET' && path == '/health') {
          await _writeJson(request.response, 200, <String, dynamic>{
            'ok': true,
          });
          return;
        }

        if (method == 'GET' && path == '/host-info') {
          final payload = await _buildHostInfoPayload();
          if (payload == null) {
            await _writeJson(request.response, 404, <String, dynamic>{
              'error': 'Host is not initialized',
            });
            return;
          }

          await _writeJson(request.response, 200, payload);
          return;
        }

        if (method == 'POST' && path == '/bootstrap/join') {
          final payload = await _buildHostInfoPayload();
          if (payload == null) {
            await _writeJson(request.response, 404, <String, dynamic>{
              'error': 'Store config not found',
            });
            return;
          }

          final body = await utf8.decoder.bind(request).join();
          if (body.isNotEmpty) {
            jsonDecode(body);
          }

          await _writeJson(request.response, 200, payload);
          return;
        }

        await _writeJson(request.response, 404, <String, dynamic>{
          'error': 'Not found',
        });
      } catch (e, st) {
        debugPrint('HostServer request error: $e');
        debugPrint('$st');
        await _writeJson(request.response, 500, <String, dynamic>{
          'error': e.toString(),
        });
      }
    });
  }

  Future<Map<String, dynamic>?> _buildHostInfoPayload() async {
    final DeviceConfig? device =
        await _deviceConfigRepository.getDeviceConfig();
    final StoreConfig? store = await _deviceConfigRepository.getStoreConfig();

    if (device == null ||
        store == null ||
        device.role != DeviceRole.storeHost ||
        device.storeId == null) {
      return null;
    }

    final hostUrl = device.hostUrl ?? await buildHostUrl();

    return <String, dynamic>{
      'device_id': device.deviceId,
      'store_id': store.storeId,
      'store_name': store.storeName,
      'role': device.role.name,
      'host_url': hostUrl,
    };
  }

  Future<void> _writeJson(
    HttpResponse response,
    int statusCode,
    Map<String, dynamic> payload,
  ) async {
    response.statusCode = statusCode;
    response.headers.contentType = ContentType.json;
    response.write(jsonEncode(payload));
    await response.close();
  }
}
