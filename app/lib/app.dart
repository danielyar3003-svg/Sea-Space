import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/l10n.dart';
import 'core/providers.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/tokens.dart';
import 'router/app_router.dart';

class SeaSpaceApp extends ConsumerWidget {
  const SeaSpaceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'SEA SPACE',
      locale: ref.watch(localeProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: SsTheme.dark(),
      darkTheme: SsTheme.dark(),
      themeMode: ThemeMode.dark,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) {
        if (!ref.watch(appConfigProvider).demoMode) return child!;
        return Column(
          children: [
            Expanded(child: child!),
            const _DemoStrip(),
          ],
        );
      },
    );
  }
}

/// Always-visible label so demo data can never be mistaken for real data.
class _DemoStrip extends StatelessWidget {
  const _DemoStrip();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SsColors.warning,
      child: SizedBox(
        width: double.infinity,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SsSpace.md, vertical: SsSpace.xs),
            child: Text(
              context.l10n.demoBanner,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.85),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
