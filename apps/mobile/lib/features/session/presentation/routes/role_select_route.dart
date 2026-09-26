part of '../../../../app/router/app_router.dart';

/// Root: pick the demo account. [from] is the address a guard stopped;
/// it opens after logging in with the account it needs.
@TypedGoRoute<RoleSelectRoute>(
  path: RouteDefinitions.rolePath,
  name: RouteDefinitions.roleName,
  routes: [
    TypedGoRoute<CandidatesRoute>(
      path: RouteDefinitions.candidatesPath,
      name: RouteDefinitions.candidatesName,
    ),
    TypedGoRoute<OffersRoute>(
      path: RouteDefinitions.offersPath,
      name: RouteDefinitions.offersName,
    ),
    TypedGoRoute<GalleryRoute>(
      path: RouteDefinitions.galleryPath,
      name: RouteDefinitions.galleryName,
    ),
  ],
)
final class RoleSelectRoute extends GoRouteData with $RoleSelectRoute {
  const RoleSelectRoute({this.from});

  final String? from;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      RoleSelectScreen(from: from);
}
