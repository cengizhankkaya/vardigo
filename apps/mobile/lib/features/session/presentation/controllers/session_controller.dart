import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/usecases/login.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/session.dart';

/// The logged-in demo account, or null before login.
final sessionProvider = NotifierProvider<SessionController, Session?>(
  SessionController.new,
);

class SessionController extends Notifier<Session?> {
  @override
  Session? build() => null;

  /// Logs in with the demo account of [role]. Throws ApiException on failure
  /// and keeps the previous session.
  Future<Session> login(Role role) async {
    final session = await ref.read(loginProvider)(role);
    state = session;
    return session;
  }

  void logout() => state = null;
}
