import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/i_theme_mode_repository.dart';

/// Port for the saved theme choice.
/// The composition root (`app/composition_root.dart`) binds the adapter;
/// tests bind a fake.
final themeModeRepositoryProvider = Provider<IThemeModeRepository>(
  (ref) => throw UnimplementedError(
    'themeModeRepositoryProvider is bound in the composition root',
  ),
);
