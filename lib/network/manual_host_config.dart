class ManualHostConfig {
  const ManualHostConfig({
    required this.host,
    this.port = 8787,
  });

  final String host;
  final int port;

  Uri get baseUri => Uri(
        scheme: 'http',
        host: host,
        port: port,
      );

  String get baseUrl => baseUri.toString();
}
