import '../../../../core/api/api_client.dart';
import '../../../../core/api/json_reader.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/session.dart';
import '../../domain/repositories/session_repository.dart';

class ApiSessionRepository implements SessionRepository {
  ApiSessionRepository(this._api);

  final ApiClient _api;

  @override
  Future<Session> login(Role role) async {
    final data = JsonReader.of(
      await _api.post('/auth/login', body: {'role': role.name}),
    );
    return Session(
      token: data.read<String>('token'),
      role: data.readEnum('role', Role.values),
    );
  }
}
