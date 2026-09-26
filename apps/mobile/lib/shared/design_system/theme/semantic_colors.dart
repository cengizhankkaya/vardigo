import 'package:flutter/material.dart';

/// Business states: accepted / pay fits (success), pay does not fit and
/// ratings (warning), neutral notes (info). Errors use [ColorScheme.error].
@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  const SemanticColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.info,
  });

  /// Pay amounts, "Ücret beklentisi uyuşuyor", the accept button.
  final Color success;

  /// Text and icons on [success].
  final Color onSuccess;

  /// "İlgileniyorsun" label.
  final Color successContainer;
  final Color onSuccessContainer;

  /// Rating star, "Ücret beklentisi uyuşmuyor".
  final Color warning;
  final Color info;

  @override
  SemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? info,
  }) => SemanticColors(
    success: success ?? this.success,
    onSuccess: onSuccess ?? this.onSuccess,
    successContainer: successContainer ?? this.successContainer,
    onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
    warning: warning ?? this.warning,
    info: info ?? this.info,
  );

  @override
  SemanticColors lerp(SemanticColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return SemanticColors(
      success: mix(success, other.success),
      onSuccess: mix(onSuccess, other.onSuccess),
      successContainer: mix(successContainer, other.successContainer),
      onSuccessContainer: mix(onSuccessContainer, other.onSuccessContainer),
      warning: mix(warning, other.warning),
      info: mix(info, other.info),
    );
  }
}
