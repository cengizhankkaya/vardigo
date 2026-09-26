import '../entities/role.dart';
import '../entities/session.dart';

abstract interface class ISessionRepository {
  Future<Session> login(Role role);
}
