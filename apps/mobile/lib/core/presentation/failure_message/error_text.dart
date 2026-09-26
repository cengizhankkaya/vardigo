import 'package:flutter/material.dart';

import '../../error/exceptions/api_exception.dart';
import '../../l10n/l10n.dart';

/// Text to show for a failed call: the backend's own Turkish message when it
/// sent one, otherwise a local text for connection problems.
String errorText(BuildContext context, Object error) {
  final l10n = context.l10n;
  if (error is ApiException) {
    if (error.code == ApiException.network) return l10n.errorNetwork;
    if (error.code == ApiException.timeout) return l10n.errorTimeout;
    if (error.message.isNotEmpty && error.code != ApiException.badResponse) {
      return error.message;
    }
  }
  return l10n.errorUnexpected;
}
