import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/app/startup/startup_branding.dart';
import 'package:vardigo/core/l10n/l10n.dart';
import 'package:vardigo/core/presentation/widgets/brand_logo.dart';
import 'package:vardigo/core/theme/app_theme.dart';

Widget _app({
  required Widget child,
  bool reducedMotion = false,
  bool dark = false,
}) => MaterialApp(
  theme: dark ? AppTheme.dark() : AppTheme.light(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reducedMotion),
    child: StartupBranding(child: child),
  ),
);

void main() {
  testWidgets('intro blocks input, completes, and does not replay on rebuild', (
    tester,
  ) async {
    var taps = 0;
    final child = Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => taps++,
          child: const Text('Continue'),
        ),
      ),
    );
    await tester.pumpWidget(_app(child: child));
    expect(find.byType(BrandLogo), findsOneWidget);
    // The visible logo covers this area. Coordinates deliberately exercise
    // hit testing instead of tapping a finder for an inaccessible button.
    await tester.tapAt(tester.getCenter(find.text('Continue')));
    expect(taps, 0);
    await tester.pumpAndSettle();
    expect(find.byType(BrandLogo), findsNothing);
    await tester.tap(find.text('Continue'));
    expect(taps, 1);

    await tester.pumpWidget(_app(child: child, dark: true));
    await tester.pumpAndSettle();
    expect(find.byType(BrandLogo), findsNothing);
  });

  testWidgets('reduced motion opens the app without a timed intro', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _app(
        child: Scaffold(
          body: TextButton(onPressed: () => taps++, child: const Text('Ready')),
        ),
        reducedMotion: true,
      ),
    );
    expect(find.byType(BrandLogo), findsNothing);
    expect(find.text('Ready'), findsOneWidget);
    await tester.tap(find.text('Ready'));
    expect(taps, 1);
  });

  testWidgets('turning reduced motion on stops an intro already in progress', (
    tester,
  ) async {
    const child = Scaffold(body: Text('Ready'));
    await tester.pumpWidget(_app(child: child));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.byType(BrandLogo), findsOneWidget);
    await tester.pumpWidget(_app(child: child, reducedMotion: true));
    expect(find.byType(BrandLogo), findsNothing);
    await tester.pumpWidget(_app(child: child));
    expect(find.byType(BrandLogo), findsNothing);
  });

  testWidgets('the router child stays mounted under the intro', (tester) async {
    final state = GlobalKey<_StatefulDestinationState>();
    await tester.pumpWidget(_app(child: _StatefulDestination(key: state)));
    final initialState = state.currentState;
    initialState!.setValue('Deep-linked screen');
    await tester.pumpAndSettle();
    expect(state.currentState, same(initialState));
    expect(find.text('Deep-linked screen'), findsOneWidget);
  });

  testWidgets('disposing during the intro releases its ticker', (tester) async {
    await tester.pumpWidget(_app(child: const SizedBox()));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });
}

class _StatefulDestination extends StatefulWidget {
  const _StatefulDestination({super.key});

  @override
  State<_StatefulDestination> createState() => _StatefulDestinationState();
}

class _StatefulDestinationState extends State<_StatefulDestination> {
  String value = 'Initial screen';

  void setValue(String next) => setState(() => value = next);

  @override
  Widget build(BuildContext context) => Scaffold(body: Text(value));
}
