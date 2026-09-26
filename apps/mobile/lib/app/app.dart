import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/appearance/presentation/controllers/theme_mode_controller.dart';
import '../features/appearance/domain/entities/app_theme_mode.dart';
import '../core/l10n/l10n.dart';
import 'reference_frame/phone_frame.dart';
import '../core/theme/app_theme.dart';
import 'router/app_router.dart';

class VardigoApp extends ConsumerWidget {
  const VardigoApp({
    super.key,
    this.referenceFrame = ReferenceFrameView.enabled,
  });

  /// Draws the app inside the case's 390×844 phone frame instead of using
  /// the device's own screen edges.
  final bool referenceFrame;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: switch (ref.watch(themeModeControllerProvider)) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: referenceFrame
          ? (context, child) => ReferenceFrameView(child: child!)
          : null,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
