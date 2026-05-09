import 'package:flutter/material.dart';

class KitchenPage extends StatelessWidget {
  const KitchenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('後廚看單')),
      body: const Center(
        child: Text('後廚 KDS 頁骨架已建立'),
      ),
    );
  }
}
