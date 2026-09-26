/// The two demo accounts of the case.
enum Role { employer, worker }

/// A logged-in demo account; [token] goes into every API call.
class Session {
  const Session({required this.token, required this.role});

  final String token;
  final Role role;
}

abstract interface class SessionRepository {
  Future<Session> login(Role role);
}
