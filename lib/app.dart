import 'package:flutter/material.dart';
import 'features/frontdesk/frontdesk_page.dart';

class PosKdsApp extends StatelessWidget {
  const PosKdsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS KDS App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC97D60),
        ),
        useMaterial3: true,
      ),
      home: const FrontdeskPage(),
    );
  }
}
