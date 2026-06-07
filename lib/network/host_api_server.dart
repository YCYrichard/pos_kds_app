import 'dart:convert';
import 'dart:io';

import 'package:pos_kds_app/app_role.dart';
import 'package:pos_kds_app/data/models/order.dart';
import 'package:pos_kds_app/data/models/order_item.dart';
import 'package:pos_kds_app/data/repositories/menu_repository.dart';
import 'package:pos_kds_app/data/repositories/order_repository.dart';
import 'package:pos_kds_app/data/repositories/sync_event_repository.dart';
import 'package:pos_kds_app/device_persistence/store_bootstrap_record.dart';

import 'host_api_models.dart';

class HostApiServer {
  HostApiServer({
    required this.menuRepository,
    required this.orderRepository,
    required this.syncEventRepository,
    required this.storeBootstrapRecord,
    required this.runtimeRole,
  });

  final MenuRepository menuRepository;
  final OrderRepository orderRepository;
  final SyncEventRepository syncEventRepository;
  final StoreBootstrapRecord storeBootstrapRecord;
  final AppRole runtimeRole;

  HttpServer? _server;

  bool get isRunning => _server != null;
  int? get port => _server?.port;

  Future<void> start({int port = 8787}) async {
    if (_server != null) {
      return;
    }

    final HttpServer server = await HttpServer.bind(
      InternetAddress.anyIPv4,
      port,
    );

    _server = server;
    server.listen(_handleRequest);
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  Future<void> _handleRequest(HttpRequest request) async {
    try {
      final String path = request.uri.path;
      final String method = request.method;

      if (method == 'GET' && path == '/health') {
        _writeJson(request.response, HttpStatus.ok, <String, Object?>{
          'ok': true,
          'service': 'pos_kds_host',
          'port': _server?.port,
        });
        return;
      }

      if (method == 'GET' && path == '/host-info') {
        _writeJson(request.response, HttpStatus.ok, <String, Object?>{
          'ok': true,
          'device_id': storeBootstrapRecord.hostDeviceId ??
              storeBootstrapRecord.deviceId,
          'store_id': storeBootstrapRecord.storeId,
          'store_name': storeBootstrapRecord.storeName,
          'host_url': _buildHostUrl(request),
          'role': runtimeRole.name,
          'port': _server?.port,
        });
        return;
      }

      if (method == 'POST' && path == '/bootstrap/join') {
        final String rawBody = await utf8.decoder.bind(request).join();
        final dynamic decoded =
            rawBody.trim().isEmpty ? <String, dynamic>{} : jsonDecode(rawBody);

        if (decoded is! Map<String, dynamic>) {
          _writeJson(request.response, HttpStatus.badRequest, <String, Object?>{
            'ok': false,
            'message': 'Invalid JSON body',
          });
          return;
        }

        final String? joiningDeviceId =
            (decoded['device_id'] as String?)?.trim();
        final String? displayName =
            (decoded['display_name'] as String?)?.trim();

        if (joiningDeviceId == null || joiningDeviceId.isEmpty) {
          _writeJson(request.response, HttpStatus.badRequest, <String, Object?>{
            'ok': false,
            'message': 'device_id is required',
          });
          return;
        }

        _writeJson(request.response, HttpStatus.ok, <String, Object?>{
          'store_id': storeBootstrapRecord.storeId,
          'store_name': storeBootstrapRecord.storeName,
          'device_id': storeBootstrapRecord.hostDeviceId ??
              storeBootstrapRecord.deviceId,
          'host_url': _buildHostUrl(request),
          'joined_device_id': joiningDeviceId,
          'joined_display_name': displayName,
        });
        return;
      }

      if (method == 'GET' && path == '/menu') {
        final menu = await menuRepository.getAllActive();
        _writeRawJson(request.response, HttpStatus.ok, encodeMenuList(menu));
        return;
      }

      if (method == 'GET' && path == '/orders/active') {
        final bundles = await orderRepository.getActiveOrderBundles();
        _writeRawJson(
          request.response,
          HttpStatus.ok,
          encodeActiveBundles(bundles),
        );
        return;
      }

      if (method == 'POST' && path == '/orders') {
        final String rawBody = await utf8.decoder.bind(request).join();
        final dynamic decoded =
            rawBody.trim().isEmpty ? <String, dynamic>{} : jsonDecode(rawBody);

        if (decoded is! Map<String, dynamic>) {
          _writeJson(request.response, HttpStatus.badRequest, <String, Object?>{
            'ok': false,
            'message': 'Invalid JSON body',
          });
          return;
        }

        final dynamic rawOrder = decoded['order'];
        final dynamic rawItems = decoded['items'];

        if (rawOrder is! Map) {
          _writeJson(request.response, HttpStatus.badRequest, <String, Object?>{
            'ok': false,
            'message': 'order is required',
          });
          return;
        }

        if (rawItems is! List) {
          _writeJson(request.response, HttpStatus.badRequest, <String, Object?>{
            'ok': false,
            'message': 'items must be a list',
          });
          return;
        }

        final OrderEntity order = OrderEntity.fromMap(
          Map<String, Object?>.from(rawOrder as Map),
        );

        final List<OrderItemEntity> items = rawItems
            .map(
              (dynamic e) =>
                  OrderItemEntity.fromMap(Map<String, Object?>.from(e as Map)),
            )
            .toList();

        final int orderId = await orderRepository.createOrder(
          order: order,
          items: items,
        );

        _writeJson(request.response, HttpStatus.ok, <String, Object?>{
          'ok': true,
          'order_id': orderId,
          'order_no': order.orderNo,
        });
        return;
      }

      if (method == 'GET' && path == '/sync/events') {
        final String? since = request.uri.queryParameters['since'];

        final events = await syncEventRepository.listSince(
          minHlcExclusive: since,
          limit: 500,
        );

        final body = events.map((e) => e.toMap()).toList();

        _writeRawJson(
          request.response,
          HttpStatus.ok,
          jsonEncode(body),
        );
        return;
      }

      final RegExp completePattern = RegExp(r'^/order-items/(\d+)/complete$');
      final RegExpMatch? match = completePattern.firstMatch(path);

      if (method == 'POST' && match != null) {
        final int itemId = int.parse(match.group(1)!);
        await orderRepository.completeOrderItem(itemId);
        _writeJson(request.response, HttpStatus.ok, <String, Object?>{
          'ok': true,
          'itemId': itemId,
        });
        return;
      }

      _writeJson(request.response, HttpStatus.notFound, <String, Object?>{
        'ok': false,
        'message': 'Not found',
      });
    } catch (error) {
      _writeJson(
        request.response,
        HttpStatus.internalServerError,
        <String, Object?>{
          'ok': false,
          'message': error.toString(),
        },
      );
    }
  }

  String _buildHostUrl(HttpRequest request) {
    final int resolvedPort = _server?.port ?? 8787;
    final String host = request.requestedUri.host.isNotEmpty
        ? request.requestedUri.host
        : '127.0.0.1';
    return 'http://$host:$resolvedPort';
  }

  void _writeJson(
    HttpResponse response,
    int statusCode,
    Map<String, Object?> body,
  ) {
    _writeRawJson(response, statusCode, jsonEncode(body));
  }

  void _writeRawJson(
    HttpResponse response,
    int statusCode,
    String body,
  ) {
    response.statusCode = statusCode;
    response.headers.contentType = ContentType.json;
    response.write(body);
    response.close();
  }
}
