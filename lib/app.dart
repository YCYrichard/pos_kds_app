import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_role.dart';
import 'app_shells/backoffice_app_shell.dart';
import 'app_shells/combined_app_shell.dart';
import 'app_shells/frontdesk_app_shell.dart';
import 'app_shells/kitchen_app_shell.dart';
import 'l10n/generated/app_localizations.dart';

class PosKdsApp extends StatelessWidget {
  const PosKdsApp({
    super.key,
    required this.role,
  });

  final AppRole role;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _appTitle(role),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC97D60),
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: _AppRoot(role: role),
    );
  }

  String _appTitle(AppRole role) {
    switch (role) {
      case AppRole.frontdesk:
        return 'POS Frontdesk App';
      case AppRole.kitchen:
        return 'POS Kitchen App';
      case AppRole.backoffice:
        return 'POS Backoffice App';
      case AppRole.combined:
        return 'POS KDS App';
    }
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot({required this.role});

  final AppRole role;

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case AppRole.frontdesk:
        return const FrontdeskAppShell();
      case AppRole.kitchen:
        return const KitchenAppShell();
      case AppRole.backoffice:
        return const BackofficeAppShell();
      case AppRole.combined:
        return const CombinedAppShell();
    }
  }
}
