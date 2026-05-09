import 'package:flutter/material.dart';

class BackofficePage extends StatelessWidget {
  const BackofficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('後台摘要')),
      body: const Center(
        child: Text('後台頁骨架已建立'),
      ),
    );
  }
}
