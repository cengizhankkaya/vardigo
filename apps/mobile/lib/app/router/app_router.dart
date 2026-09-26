import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/candidates/domain/candidate.dart';
import '../../features/candidates/presentation/candidates_screen.dart';
import '../../features/offers/domain/offer.dart';
import '../../features/offers/presentation/offers_screen.dart';
import '../../features/session/application/session_controller.dart';
import '../../features/session/domain/session.dart';
import '../../features/session/presentation/role_select_screen.dart';
import '../../preview/design_preview_screen.dart';
import 'route_definitions.dart';
import 'route_error_screen.dart';

part '../../features/candidates/presentation/routes/candidates_route.dart';
part '../../features/offers/presentation/routes/offers_route.dart';
part '../../features/session/presentation/routes/role_select_route.dart';
part '../../preview/gallery_route.dart';
part 'app_router.g.dart';
part 'route_guard.dart';

/// The app's only router. Routes are typed classes (see `*_route.dart`);
/// navigate with `const OffersRoute().push(context)`, never `Navigator`.
final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: const RoleSelectRoute().location,
    routes: $appRoutes,
    // Runs on every go and push. The session changes only on role
    // selection, so there is no refreshListenable: a refresh would re-read
    // the address before a pop is reported and bring the popped screen back.
    redirect: (context, state) => guardRedirect(
      state.uri,
      ref.read(sessionProvider),
      allowGallery: kDebugMode,
    ),
    errorBuilder: (context, state) => RouteErrorScreen(
      location: state.uri.toString(),
      onHome: () => const RoleSelectRoute().go(context),
    ),
  );
  // Coming back to role selection from another screen ends the demo
  // session, however it happens: back button, guard or deep link.
  // `router.state` is the visible screen, pushed ones included.
  String? lastPath;
  router.routerDelegate.addListener(() {
    if (router.routerDelegate.currentConfiguration.isEmpty) return;
    final path = router.state.uri.path;
    final returned =
        path == RouteDefinitions.rolePath &&
        lastPath != null &&
        lastPath != path;
    lastPath = path;
    if (returned && ref.read(sessionProvider) != null) {
      ref.read(sessionProvider.notifier).logout();
    }
  });

  ref.onDispose(router.dispose);
  return router;
});
