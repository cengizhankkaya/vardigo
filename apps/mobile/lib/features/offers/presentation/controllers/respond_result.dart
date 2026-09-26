import '../../../../core/error/exceptions/api_exception.dart';
import '../../domain/entities/offer.dart';

sealed class RespondResult {
  const RespondResult();
}

class Responded extends RespondResult {
  const Responded(this.offer);
  final Offer offer;
}

class RespondFailed extends RespondResult {
  const RespondFailed(this.error);
  final ApiException error;
}
