import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/core/api/api_client.dart';
import 'package:vardigo/core/api/api_config.dart';
import 'package:vardigo/core/error/exceptions/api_exception.dart';

import '../support/fake_adapter.dart';

void main() {
  const config = ApiConfig('http://api.test');

  (ApiClient, FakeAdapter) client(
    Future<ResponseBody> Function(RequestOptions) handler, {
    String? token,
  }) {
    final adapter = FakeAdapter(handler);
    final dio = Dio()..httpClientAdapter = adapter;
    return (ApiClient(config, token: () => token, dio: dio), adapter);
  }

  Future<ApiException> failure(Future<Object?> call) async {
    try {
      await call;
    } on ApiException catch (error) {
      return error;
    }
    fail('expected ApiException');
  }

  test('returns data from the success envelope', () async {
    final (api, _) = client(
      (_) async => FakeAdapter.json({
        'ok': true,
        'data': {'status': 'up'},
      }),
    );
    expect(await api.get('/health'), {'status': 'up'});
  });

  test('sends the bearer token, JSON body and query', () async {
    final (api, adapter) = client(
      (_) async => FakeAdapter.json({'ok': true, 'data': null}),
      token: 'dev-employer',
    );
    await api.post(
      '/offers',
      body: {
        'workerIds': ['w_merve'],
      },
    );
    await api.get('/candidates', query: {'tab': 'perfect'});

    final post = adapter.requests.first;
    expect(post.uri.toString(), 'http://api.test/api/offers');
    expect(post.headers['Authorization'], 'Bearer dev-employer');
    expect(post.data, {
      'workerIds': ['w_merve'],
    });
    expect(adapter.requests.last.uri.query, 'tab=perfect');
  });

  test('turns an error envelope into ApiException', () async {
    final (api, _) = client(
      (_) async => FakeAdapter.json({
        'ok': false,
        'error': {'code': 'OFFER_EXPIRED', 'message': 'Teklifin süresi doldu'},
      }, status: 409),
    );
    final error = await failure(api.post('/offers/o_komi/accept'));
    expect(error.code, 'OFFER_EXPIRED');
    expect(error.message, 'Teklifin süresi doldu');
    expect(error.statusCode, 409);
  });

  test('reports a non-envelope answer as BAD_RESPONSE', () async {
    final (api, _) = client(
      (_) async => ResponseBody.fromString('<html>Bad gateway</html>', 502),
    );
    final error = await failure(api.get('/candidates'));
    expect(error.code, ApiException.badResponse);
    expect(error.statusCode, 502);
  });

  test('reports an unreachable server as NETWORK_ERROR', () async {
    final (api, _) = client(
      (options) async => throw DioException.connectionError(
        requestOptions: options,
        reason: 'Connection refused',
      ),
    );
    final error = await failure(api.get('/candidates'));
    expect(error.code, ApiException.network);
    expect(error.isConnectionProblem, isTrue);
  });

  test('reports a slow server as TIMEOUT', () async {
    final (api, _) = client(
      (options) async => throw DioException.receiveTimeout(
        timeout: const Duration(seconds: 10),
        requestOptions: options,
      ),
    );
    expect((await failure(api.get('/candidates'))).code, ApiException.timeout);
  });

  group('ApiConfig', () {
    test('picks the emulator host on Android', () {
      final android = ApiConfig.fromEnvironment(
        platform: TargetPlatform.android,
      );
      expect(android.origin, 'http://10.0.2.2:3000');
      final ios = ApiConfig.fromEnvironment(platform: TargetPlatform.iOS);
      expect(ios.baseUrl, 'http://127.0.0.1:3000/api');
    });

    test('builds asset URLs from server paths', () {
      expect(
        config.assetUrl('/assets/photos/merve.png'),
        'http://api.test/assets/photos/merve.png',
      );
    });
  });
}
