import 'role.dart';

/// A logged-in demo account; [token] goes into every API call.
class Session {
  const Session({required this.token, required this.role});

  final String token;
  final Role role;
}
