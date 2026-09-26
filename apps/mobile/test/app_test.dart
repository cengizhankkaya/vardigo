import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/app/app.dart';

void main() {
  testWidgets('app opens the design gallery', (tester) async {
    await tester.pumpWidget(const VardigoApp());
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
