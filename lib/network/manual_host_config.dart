class ManualHostConfig {
  const ManualHostConfig({
    required this.host,
    this.port = 8787,
  });

  final String host;
  final int port;

  String get baseUrl => 'http://$host:$port';
}
