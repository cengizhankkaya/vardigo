import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/app/app.dart';

void main() {
  testWidgets('app starts', (tester) async {
    await tester.pumpWidget(const VardigoApp());
    expect(find.text('Vardigo'), findsOneWidget);
  });
}
