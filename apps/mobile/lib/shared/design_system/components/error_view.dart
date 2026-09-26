import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../gen/colors.gen.dart';
import '../../../l10n/l10n.dart';
import '../tokens/app_text_styles.dart';

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

/// Centered error text with a retry button, used in place of a list.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            errorText(context, error),
            textAlign: TextAlign.center,
            style: AppTextStyles.label14.copyWith(
              color: ColorName.sub,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: Text(context.l10n.retry, style: AppTextStyles.label14),
          ),
        ],
      ),
    );
  }
}
