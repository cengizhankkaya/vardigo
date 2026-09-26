import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/app/app.dart';
import 'package:vardigo/shared/design_system/assets/app_icons.dart';

void main() {
  testWidgets('app opens the design gallery with every icon', (tester) async {
    await tester.pumpWidget(const VardigoApp());
    expect(find.text('Tasarım galerisi'), findsOneWidget);
    for (final icon in AppIcons.values) {
      expect(find.text(icon.name), findsOneWidget);
    }
  });
}
