import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/role.dart';
import '../../domain/entities/session.dart';
import '../../domain/repositories/i_session_repository.dart';
import '../session_repository_provider.dart';

/// Logs in with the demo account of a role.
class Login {
  const Login(this._repository);

  final ISessionRepository _repository;

  Future<Session> call(Role role) => _repository.login(role);
}

final loginProvider = Provider<Login>(
  (ref) => Login(ref.watch(sessionRepositoryProvider)),
);
