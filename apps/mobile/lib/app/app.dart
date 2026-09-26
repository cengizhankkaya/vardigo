import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../features/session/presentation/role_select_screen.dart';
import '../shared/design_system/theme/app_theme.dart';

class VardigoApp extends StatelessWidget {
  const VardigoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const RoleSelectScreen(),
    );
  }
}
