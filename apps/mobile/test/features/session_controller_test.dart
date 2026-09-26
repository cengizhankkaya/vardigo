import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/app/providers.dart';
import 'package:vardigo/core/api/api_config.dart';
import 'package:vardigo/core/api/api_client.dart';
import 'package:vardigo/core/error/exceptions/api_exception.dart';
import 'package:vardigo/features/session/presentation/controllers/session_controller.dart';
import 'package:vardigo/features/session/domain/entities/session.dart';

import '../support/fake_adapter.dart';

void main() {
  late FakeAdapter adapter;
  late ProviderContainer container;

  setUp(() {
    adapter = FakeAdapter((options) async {
      if (options.path == '/auth/login') {
        final role = (options.data as Map)['role'];
        return FakeAdapter.json({
          'ok': true,
          'data': {'token': 'dev-$role', 'role': role},
        });
      }
      if (options.headers['Authorization'] == null) {
        return FakeAdapter.json({
          'ok': false,
          'error': {
            'code': 'AUTH_REQUIRED',
            'message': 'Giriş yapmanız gerekiyor',
          },
        }, status: 401);
      }
      return FakeAdapter.json({'ok': true, 'data': null});
    });
    container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWith(
          (ref) => ApiClient(
            const ApiConfig('http://api.test'),
            token: () => ref.read(sessionProvider)?.token,
            dio: Dio()..httpClientAdapter = adapter,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  test('starts logged out', () {
    expect(container.read(sessionProvider), isNull);
  });

  test('later calls carry the token of the logged-in role', () async {
    await container.read(sessionProvider.notifier).login(Role.employer);
    expect(container.read(sessionProvider)?.role, Role.employer);

    await container.read(apiClientProvider).get('/candidates');
    expect(
      adapter.requests.last.headers['Authorization'],
      'Bearer dev-employer',
    );

    await container.read(sessionProvider.notifier).login(Role.worker);
    await container.read(apiClientProvider).get('/offers');
    expect(adapter.requests.last.headers['Authorization'], 'Bearer dev-worker');
  });

  test('logout removes the token', () async {
    await container.read(sessionProvider.notifier).login(Role.worker);
    container.read(sessionProvider.notifier).logout();
    await expectLater(
      container.read(apiClientProvider).get('/offers'),
      throwsA(
        isA<ApiException>().having((e) => e.code, 'code', 'AUTH_REQUIRED'),
      ),
    );
  });
}
