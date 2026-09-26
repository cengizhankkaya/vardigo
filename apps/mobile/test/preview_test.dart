import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart' show MaterialApp;
import 'package:vardigo/l10n/l10n.dart';
import 'package:vardigo/preview/design_preview_screen.dart';

void main() {
  testWidgets('design gallery shows styles and icons', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: DesignPreviewScreen(),
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
