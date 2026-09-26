// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$roleSelectRoute];

RouteBase get $roleSelectRoute => GoRouteData.$route(
  path: '/',
  name: 'role',
  hasOverriddenOnExit: false,
  factory: $RoleSelectRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'candidates',
      name: 'candidates',
      hasOverriddenOnExit: false,
      factory: $CandidatesRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'offers',
      name: 'offers',
      hasOverriddenOnExit: false,
      factory: $OffersRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'gallery',
      name: 'gallery',
      hasOverriddenOnExit: false,
      factory: $GalleryRoute._fromState,
    ),
  ],
);

mixin $RoleSelectRoute on GoRouteData {
  static RoleSelectRoute _fromState(GoRouterState state) =>
      RoleSelectRoute(from: state.uri.queryParameters['from']);

  RoleSelectRoute get _self => this as RoleSelectRoute;

  @override
  String get location => GoRouteData.$location(
    '/',
    queryParams: {if (_self.from != null) 'from': _self.from},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $CandidatesRoute on GoRouteData {
  static CandidatesRoute _fromState(GoRouterState state) => CandidatesRoute(
    tab: _$convertMapValue(
      'tab',
      state.uri.queryParameters,
      _$CandidateTabEnumMap._$fromName,
    ),
    sort: _$convertMapValue(
      'sort',
      state.uri.queryParameters,
      _$CandidateSortEnumMap._$fromName,
    ),
  );

  CandidatesRoute get _self => this as CandidatesRoute;

  @override
  String get location => GoRouteData.$location(
    '/candidates',
    queryParams: {
      if (_self.tab != null) 'tab': _$CandidateTabEnumMap[_self.tab!],
      if (_self.sort != null) 'sort': _$CandidateSortEnumMap[_self.sort!],
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

const _$CandidateTabEnumMap = {
  CandidateTab.perfect: 'perfect',
  CandidateTab.similar: 'similar',
};

const _$CandidateSortEnumMap = {
  CandidateSort.recommended: 'recommended',
  CandidateSort.near: 'near',
  CandidateSort.rating: 'rating',
};

mixin $OffersRoute on GoRouteData {
  static OffersRoute _fromState(GoRouterState state) => OffersRoute(
    tab: _$convertMapValue(
      'tab',
      state.uri.queryParameters,
      _$OfferTabEnumMap._$fromName,
    ),
    sort: _$convertMapValue(
      'sort',
      state.uri.queryParameters,
      _$OfferSortEnumMap._$fromName,
    ),
  );

  OffersRoute get _self => this as OffersRoute;

  @override
  String get location => GoRouteData.$location(
    '/offers',
    queryParams: {
      if (_self.tab != null) 'tab': _$OfferTabEnumMap[_self.tab!],
      if (_self.sort != null) 'sort': _$OfferSortEnumMap[_self.sort!],
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

const _$OfferTabEnumMap = {
  OfferTab.pending: 'pending',
  OfferTab.answered: 'answered',
  OfferTab.expired: 'expired',
};

const _$OfferSortEnumMap = {
  OfferSort.recommended: 'recommended',
  OfferSort.expiring: 'expiring',
  OfferSort.pay: 'pay',
};

mixin $GalleryRoute on GoRouteData {
  static GalleryRoute _fromState(GoRouterState state) => const GalleryRoute();

  @override
  String get location => GoRouteData.$location('/gallery');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T? Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}

extension<T extends Enum> on Map<T, String> {
  T? _$fromName(String? value) =>
      entries.where((element) => element.value == value).firstOrNull?.key;
}
