import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'app_bootstrap_context.dart';
import 'app_role.dart';
import 'app_session_state.dart';
import 'app_shells/backoffice_app_shell.dart';
import 'app_shells/combined_app_shell.dart';
import 'app_shells/frontdesk_app_shell.dart';
import 'app_shells/kitchen_app_shell.dart';
import 'debug/app_session_banner.dart';
import 'l10n/generated/app_localizations.dart';

class PosKdsApp extends StatelessWidget {
  const PosKdsApp({
    super.key,
    required this.role,
  });

  final AppRole role;

  @override
  Widget build(BuildContext context) {
    final bootstrapContext = context.read<AppBootstrapContext>();

    return MaterialApp(
      title: _appTitle(bootstrapContext.runtimeRole),
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
      home: const _AppFrame(),
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

class _AppFrame extends StatelessWidget {
  const _AppFrame();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppSessionBanner(),
        Expanded(
          child: Consumer<AppSessionState>(
            builder: (context, session, child) {
              return _AppRoot(
                role: session.runtimeRole,
                session: session,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot({
    required this.role,
    required this.session,
  });

  final AppRole role;
  final AppSessionState session;

  bool _isBoundToRemoteHost(AppSessionState session) {
    final hostDeviceId = session.hostDeviceId?.trim();
    if (hostDeviceId == null || hostDeviceId.isEmpty) {
      return false;
    }
    return hostDeviceId != session.deviceId;
  }

  String _boundHostLabel(AppSessionState session) {
    final hostDeviceId = session.hostDeviceId?.trim();
    if (hostDeviceId == null || hostDeviceId.isEmpty) {
      return 'unknown';
    }
    return hostDeviceId;
  }

  @override
  Widget build(BuildContext context) {
    final bool boundToRemoteHost = _isBoundToRemoteHost(session);

    switch (role) {
      case AppRole.frontdesk:
        if (!session.canUseFrontdesk) {
          return const _FeatureBlockedPage(
            title: 'Frontdesk unavailable',
            message: 'Frontdesk mode is not available on this device.',
          );
        }

        if (boundToRemoteHost) {
          return _FeatureBlockedPage(
            title: 'Frontdesk blocked on client device',
            message:
                'This device is currently bound to remote host ${_boundHostLabel(session)}, so frontdesk order creation is disabled in client mode.',
          );
        }

        return const FrontdeskAppShell();

      case AppRole.kitchen:
        if (!session.canUseKitchen) {
          return const _FeatureBlockedPage(
            title: 'Kitchen unavailable',
            message: 'Kitchen mode is not available on this device.',
          );
        }
        return const KitchenAppShell();

      case AppRole.backoffice:
        if (!session.canUseBackoffice) {
          return const _FeatureBlockedPage(
            title: 'Backoffice unavailable',
            message: 'Backoffice mode is not available on this device.',
          );
        }
        return const BackofficeAppShell();

      case AppRole.combined:
        if (boundToRemoteHost) {
          return _FeatureBlockedPage(
            title: 'Combined mode blocked on client device',
            message:
                'This device is currently bound to remote host ${_boundHostLabel(session)}, so combined host workflow is disabled in client mode.',
          );
        }
        return const CombinedAppShell();
    }
  }
}

class _FeatureBlockedPage extends StatelessWidget {
  const _FeatureBlockedPage({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: DefaultTextStyle(
                style:
                    theme.textTheme.bodyLarge ?? const TextStyle(fontSize: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(message),
                    const SizedBox(height: 12),
                    Text(
                      'Use the debug session controls to switch to kitchen or backoffice while testing client separation.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
