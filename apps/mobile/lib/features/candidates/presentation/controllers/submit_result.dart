import '../../../../core/error/exceptions/api_exception.dart';

sealed class SubmitResult {
  const SubmitResult();
}

class SubmitSucceeded extends SubmitResult {
  const SubmitSucceeded(this.count);
  final int count;
}

class SubmitFailed extends SubmitResult {
  const SubmitFailed(this.error);
  final ApiException error;

  /// No answer from the server: the requests may or may not exist.
  bool get uncertain => error.isConnectionProblem;
}
