import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/app/app.dart';

void main() {
  testWidgets('app opens the demo account picker', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: VardigoApp()));
    await tester.pumpAndSettle();
    expect(find.text('Demo hesabı seç'), findsOneWidget);
    expect(find.text('İşveren'), findsOneWidget);
    expect(find.text('İş arayan'), findsOneWidget);
  });
}
