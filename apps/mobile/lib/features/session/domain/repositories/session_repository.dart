import '../entities/role.dart';
import '../entities/session.dart';

abstract interface class SessionRepository {
  Future<Session> login(Role role);
}
