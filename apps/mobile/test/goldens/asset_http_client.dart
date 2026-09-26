import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// The backend's own photos and logos, served without a network.
const _assets = '../api/public';

File _asset(Uri url) => File('$_assets${url.path}');

/// For SVG logos ([svgHttpClientProvider]).
http.Client svgAssetClient() => MockClient((request) async {
  final file = _asset(request.url);
  return file.existsSync()
      ? http.Response.bytes(file.readAsBytesSync(), 200)
      : http.Response('', 404);
});

/// For photos loaded with `Image.network`
/// (`debugNetworkImageHttpClientProvider`).
class AssetHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _Request(_asset(url));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Request implements HttpClientRequest {
  _Request(this.file);

  final File file;

  @override
  Future<HttpClientResponse> close() async => _Response(file);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Response extends Stream<List<int>> implements HttpClientResponse {
  _Response(this.file);

  final File file;

  @override
  int get statusCode => file.existsSync() ? HttpStatus.ok : HttpStatus.notFound;

  @override
  int get contentLength => file.existsSync() ? file.lengthSync() : 0;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => Stream.value(file.existsSync() ? file.readAsBytesSync() : const <int>[])
      .listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
