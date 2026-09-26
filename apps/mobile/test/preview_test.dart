import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart' show MaterialApp;
import 'package:vardigo/core/l10n/l10n.dart';
import 'package:vardigo/features/design_gallery/presentation/pages/design_preview_screen.dart';
import 'package:vardigo/core/theme/app_theme.dart';

void main() {
  testWidgets('design gallery shows styles and icons', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const DesignPreviewScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tasarım galerisi'), findsOneWidget);
    expect(find.text('title18 18/500/24'), findsOneWidget);

    for (final name in ['alarm', 'online', 'star', 'shield']) {
      await tester.scrollUntilVisible(
        find.text(name),
        200,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text(name), findsOneWidget);
    }
  });
}
