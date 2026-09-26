import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/core/error/exceptions/api_exception.dart';
import 'package:vardigo/gen/assets.gen.dart';
import 'package:vardigo/core/l10n/l10n.dart';
import 'package:vardigo/core/presentation/widgets/error_view.dart';
import 'package:vardigo/core/presentation/widgets/primary_button.dart';
import 'package:vardigo/core/presentation/widgets/square_icon_button.dart';
import 'package:vardigo/core/theme/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('disabled primary button is dimmed and ignores taps', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const PrimaryButton(label: 'Gönder', onPressed: null)),
    );
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0.45);
  });

  testWidgets('primary button calls back once per tap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(PrimaryButton(label: 'Gönder', onPressed: () => taps++)),
    );
    await tester.tap(find.text('Gönder'));
    expect(taps, 1);
  });

  testWidgets('square button exposes its label to screen readers', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        SquareIconButton(
          icon: Assets.icons.back,
          label: 'Geri',
          onPressed: () {},
        ),
      ),
    );
    expect(find.bySemanticsLabel('Geri'), findsOneWidget);
  });

  testWidgets('error text prefers the backend message', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(
      errorText(
        context,
        const ApiException(
          code: 'OFFER_PENDING_EXISTS',
          message: 'Seçilen personel için açık teklif var: w_merve',
        ),
      ),
      'Seçilen personel için açık teklif var: w_merve',
    );
    expect(
      errorText(
        context,
        const ApiException(code: ApiException.network, message: ''),
      ),
      context.l10n.errorNetwork,
    );
  });
}
