import 'package:flutter/material.dart';

class FrontdeskPage extends StatelessWidget {
  const FrontdeskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('前台點單')),
      body: const Center(
        child: Text('前台頁骨架已建立，下一步接控制器與 keypad'),
      ),
    );
  }
}
