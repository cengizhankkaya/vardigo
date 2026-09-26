part of '../../../../app/router/app_router.dart';

/// "Görüşme Talepleri"; job seeker only. `/offers?tab=answered&sort=pay`
/// opens that tab and sort.
final class OffersRoute extends GoRouteData with $OffersRoute {
  const OffersRoute({this.tab, this.sort});

  final OfferTab? tab;
  final OfferSort? sort;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      // A new tab or sort from a link opens a fresh screen on it.
      OffersScreen(
        key: ValueKey((tab, sort)),
        initialTab: tab,
        initialSort: sort,
      );
}
