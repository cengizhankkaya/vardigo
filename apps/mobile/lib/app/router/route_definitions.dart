/// Paths and names of every route. Role selection is the root; the other
/// screens sit under it, so the back button always leads there.
abstract final class RouteDefinitions {
  static const rolePath = '/';
  static const roleName = 'role';

  static const candidatesPath = 'candidates';
  static const candidatesName = 'candidates';

  static const offersPath = 'offers';
  static const offersName = 'offers';
}
