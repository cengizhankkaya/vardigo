import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/i_candidates_repository.dart';

/// Port for candidate lists and interview requests.
/// The composition root (`app/composition_root.dart`) binds the adapter;
/// tests bind a fake.
final candidatesRepositoryProvider = Provider<ICandidatesRepository>(
  (ref) => throw UnimplementedError(
    'candidatesRepositoryProvider is bound in the composition root',
  ),
);
