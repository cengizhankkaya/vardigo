import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../features/session/presentation/role_select_screen.dart';
import '../preview/phone_frame.dart';
import '../shared/design_system/theme/app_theme.dart';

class VardigoApp extends StatelessWidget {
  const VardigoApp({
    super.key,
    this.referenceFrame = ReferenceFrameView.enabled,
  });

  /// Draws the app inside the case's 390×844 phone frame instead of using
  /// the device's own screen edges.
  final bool referenceFrame;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: referenceFrame
          ? (context, child) => ReferenceFrameView(child: child!)
          : null,
      home: const RoleSelectScreen(),
    );
  }
}
