part of '../../../../app/router/app_router.dart';

/// "Eşleşen Personeller"; employer only. `/candidates?tab=similar&sort=near`
/// opens that tab and sort.
final class CandidatesRoute extends GoRouteData with $CandidatesRoute {
  const CandidatesRoute({this.tab, this.sort});

  final CandidateTab? tab;
  final CandidateSort? sort;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      // A new tab or sort from a link opens a fresh screen on it.
      CandidatesScreen(
        key: ValueKey((tab, sort)),
        initialTab: tab,
        initialSort: sort,
      );
}
