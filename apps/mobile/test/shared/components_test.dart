import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/core/error/exceptions/api_exception.dart';
import 'package:vardigo/core/l10n/l10n.dart';
import 'package:vardigo/core/presentation/failure_message/error_text.dart';
import 'package:vardigo/core/presentation/widgets/primary_button.dart';
import 'package:vardigo/core/presentation/widgets/square_icon_button.dart';
import 'package:vardigo/core/theme/app_theme.dart';
import 'package:vardigo/core/theme/tokens/app_sizes.dart';
import 'package:vardigo/gen/assets.gen.dart';

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

  testWidgets('primary button wraps its label under large system text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: _wrap(
          SizedBox(
            width: 368,
            child: PrimaryButton(
              icon: Assets.icons.send,
              label: 'Görüşme Talebi Gönder (3)',
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(PrimaryButton)).height,
      greaterThan(AppSizes.cta),
    );
  });

  testWidgets('primary button keeps its height at normal text size', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(PrimaryButton(label: 'Gönder', onPressed: () {})),
    );
    expect(tester.getSize(find.byType(PrimaryButton)).height, AppSizes.cta);
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
