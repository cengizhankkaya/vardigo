import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/app/app.dart';

void main() {
  testWidgets('app opens the design gallery with every icon', (tester) async {
    await tester.pumpWidget(const VardigoApp());
    expect(find.text('Tasarım galerisi'), findsOneWidget);
    for (final name in ['alarm', 'online', 'star', 'shield']) {
      expect(find.text(name), findsOneWidget);
    }
  });
}
