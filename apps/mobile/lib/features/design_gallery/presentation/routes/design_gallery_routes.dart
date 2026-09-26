part of '../../../../app/router/app_router.dart';

/// Design gallery; the guard sends release builds back to role selection.
final class GalleryRoute extends GoRouteData with $GalleryRoute {
  const GalleryRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const DesignPreviewScreen();
}
