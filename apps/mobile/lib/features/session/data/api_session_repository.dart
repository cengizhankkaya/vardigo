import '../../../core/network/api_client.dart';
import '../../../core/network/json_reader.dart';
import '../domain/session.dart';

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
