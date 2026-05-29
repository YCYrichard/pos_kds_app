import 'dart:convert';
import 'dart:io';

import 'package:pos_kds_app/data/repositories/menu_repository.dart';
import 'package:pos_kds_app/data/repositories/order_repository.dart';

import 'host_api_models.dart';

class HostApiServer {
  HostApiServer({
    required this.menuRepository,
    required this.orderRepository,
  });

  final MenuRepository menuRepository;
  final OrderRepository orderRepository;

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
          request.response, HttpStatus.internalServerError, <String, Object?>{
        'ok': false,
        'message': error.toString(),
      });
    }
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
