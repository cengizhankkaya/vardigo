import 'api_exception.dart';

/// Reads a JSON object from the API. A missing or wrongly typed field means
/// the backend and the app disagree, reported as [ApiException.badResponse].
extension type JsonReader(Map<String, Object?> json) {
  static JsonReader of(Object? value) {
    if (value is Map<String, Object?>) return JsonReader(value);
    throw _mismatch('object');
  }

  T read<T>(String key) {
    final value = json[key];
    if (value is T) return value;
    throw _mismatch(key);
  }

  T? readOptional<T>(String key) {
    final value = json[key];
    if (value == null || value is T) return value as T?;
    throw _mismatch(key);
  }

  /// An enum value written with its Dart name (`"pending"`, `"worker"`).
  T readEnum<T extends Enum>(String key, List<T> values) {
    final name = read<String>(key);
    for (final value in values) {
      if (value.name == name) return value;
    }
    throw _mismatch(key);
  }

  List<T> readList<T>(String key, T Function(JsonReader item) map) =>
      read<List<Object?>>(key).map((item) => map(JsonReader.of(item))).toList();

  static ApiException _mismatch(String what) => ApiException(
    code: ApiException.badResponse,
    message: 'Unexpected API data: $what',
  );
}
