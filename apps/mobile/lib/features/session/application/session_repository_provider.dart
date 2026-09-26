import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/i_session_repository.dart';

/// Port for demo login.
/// The composition root (`app/composition_root.dart`) binds the adapter;
/// tests bind a fake.
final sessionRepositoryProvider = Provider<ISessionRepository>(
  (ref) => throw UnimplementedError(
    'sessionRepositoryProvider is bound in the composition root',
  ),
);
