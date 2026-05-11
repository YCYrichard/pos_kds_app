import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.orderDetailTitle),
      ),
      body: Center(
        child: Text(l10n.orderDetailPageStub),
      ),
    );
  }
}
