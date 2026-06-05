// lib/network/local_network_info.dart

import 'dart:io';

class LocalNetworkInfo {
  Future<String?> getLocalIpv4() async {
    final interfaces = await NetworkInterface.list(
      includeLoopback: false,
      type: InternetAddressType.IPv4,
    );

    for (final interface in interfaces) {
      for (final addr in interface.addresses) {
        final ip = addr.address;
        if (_looksLikeLanIpv4(ip)) {
          return ip;
        }
      }
    }

    for (final interface in interfaces) {
      for (final addr in interface.addresses) {
        return addr.address;
      }
    }

    return null;
  }

  Future<String?> getSubnetPrefix() async {
    final ip = await getLocalIpv4();
    if (ip == null || !ip.contains('.')) {
      return null;
    }

    return ip.substring(0, ip.lastIndexOf('.'));
  }

  bool _looksLikeLanIpv4(String ip) {
    return ip.startsWith('192.168.') ||
        ip.startsWith('10.') ||
        ip.startsWith('172.');
  }
}
