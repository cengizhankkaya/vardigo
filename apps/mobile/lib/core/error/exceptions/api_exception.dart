/// A failed API call. [code] is the backend error code (`OFFER_EXPIRED`...)
/// or one of the client-side codes below; screens decide what to show by it.
class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    this.statusCode,
  });

  /// Server not reachable (off, wrong address, no network).
  static const network = 'NETWORK_ERROR';

  /// Server did not answer in time.
  static const timeout = 'TIMEOUT';

  /// Server answered with something that is not the case envelope.
  static const badResponse = 'BAD_RESPONSE';

  final String code;

  /// Backend message in Turkish; empty for client-side codes.
  final String message;
  final int? statusCode;

  bool get isConnectionProblem => code == network || code == timeout;

  @override
  String toString() => 'ApiException($code, $statusCode): $message';
}
