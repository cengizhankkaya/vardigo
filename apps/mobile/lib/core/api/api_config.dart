import 'package:flutter/foundation.dart';

/// Where the backend runs. Override with
/// `flutter run --dart-define=API_ORIGIN=http://192.168.1.20:3000`.
class ApiConfig {
  const ApiConfig(this.origin);

  /// Server root without a trailing slash, e.g. `http://127.0.0.1:3000`.
  final String origin;

  String get baseUrl => '$origin/api';

  /// Photos and logos come as server paths (`/assets/photos/merve.png`).
  String assetUrl(String path) => '$origin$path';

  /// Android emulator reaches the host machine at 10.0.2.2; the iOS simulator
  /// shares the host network. 127.0.0.1 is used because the API listens on IPv4.
  static ApiConfig fromEnvironment({TargetPlatform? platform}) {
    const defined = String.fromEnvironment('API_ORIGIN');
    if (defined.isNotEmpty) return ApiConfig(defined);
    return (platform ?? defaultTargetPlatform) == TargetPlatform.android
        ? const ApiConfig('http://10.0.2.2:3000')
        : const ApiConfig('http://127.0.0.1:3000');
  }
}
