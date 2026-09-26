import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/i_offers_repository.dart';

/// Port for interview requests of the job seeker.
/// The composition root (`app/composition_root.dart`) binds the adapter;
/// tests bind a fake.
final offersRepositoryProvider = Provider<IOffersRepository>(
  (ref) => throw UnimplementedError(
    'offersRepositoryProvider is bound in the composition root',
  ),
);
