part of 'app_router.dart';

/// The demo account a location needs, or null when anyone may open it.
Role? requiredRoleFor(Uri uri) => switch (uri.pathSegments.firstOrNull) {
  RouteDefinitions.candidatesPath => Role.employer,
  RouteDefinitions.offersPath => Role.worker,
  _ => null,
};

/// Where [role] lands after choosing it on the role screen.
String homeLocationFor(Role role) => switch (role) {
  Role.employer => const CandidatesRoute().location,
  Role.worker => const OffersRoute().location,
};

/// Where to send a visitor instead of [uri], or null to open it.
///
/// A screen that needs another account goes to role selection with the
/// address in `from`, so choosing the right role continues there.
String? guardRedirect(Uri uri, Session? session, {required bool allowGallery}) {
  if (uri.pathSegments.firstOrNull == RouteDefinitions.galleryPath &&
      !allowGallery) {
    return const RoleSelectRoute().location;
  }
  final role = requiredRoleFor(uri);
  if (role == null || session?.role == role) return null;
  return RoleSelectRoute(from: uri.toString()).location;
}
