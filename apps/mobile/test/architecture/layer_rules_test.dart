import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Import rules of the hexagonal layers, checked on every file in lib/.
/// Dependencies point inward: presentation → application → domain ←
/// infrastructure; only the composition root knows the adapters.
void main() {
  final lib = Directory('lib').absolute;
  final files = lib
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .map((f) => _Source(lib, f))
      .where((s) => !s.generated)
      .toList();

  List<String> check(
    bool Function(_Source) applies,
    String? Function(_Source, _Import) rule,
  ) => [
    for (final source in files.where(applies))
      for (final import in source.imports)
        if (rule(source, import) case final problem?)
          '${source.path} → ${import.spec}: $problem',
  ];

  test('finds the layers', () {
    expect(files.where((s) => s.layer == 'domain'), isNotEmpty);
    expect(files.where((s) => s.layer == 'application'), isNotEmpty);
    expect(files.where((s) => s.layer == 'infrastructure'), isNotEmpty);
    expect(files.where((s) => s.layer == 'presentation'), isNotEmpty);
  });

  test('core depends on no feature and not on app', () {
    final problems = check(
      (s) => s.path.startsWith('core/'),
      (s, i) =>
          i.path != null &&
              (i.path!.startsWith('features/') || i.path!.startsWith('app/'))
          ? 'core must stay feature-free'
          : null,
    );
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('domain imports only its own domain, Dart and foundation', () {
    final problems = check((s) => s.layer == 'domain', (s, i) {
      if (i.spec.startsWith('dart:')) return null;
      if (i.spec == 'package:flutter/foundation.dart' ||
          i.spec == 'package:meta/meta.dart') {
        return null;
      }
      if (i.path == null) return 'domain uses no packages';
      return i.path!.startsWith('features/${s.feature}/domain/') ||
              i.path!.startsWith('core/domain/')
          ? null
          : 'domain imports only domain';
    });
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('application imports only domain (Riverpod wires the use cases)', () {
    final problems = check((s) => s.layer == 'application', (s, i) {
      if (i.spec.startsWith('dart:') ||
          i.spec == 'package:flutter_riverpod/flutter_riverpod.dart') {
        return null;
      }
      if (i.path == null) return 'application uses no other packages';
      final own = 'features/${s.feature}/';
      return i.path!.startsWith('${own}domain/') ||
              i.path!.startsWith('${own}application/') ||
              i.path!.startsWith('core/domain/')
          ? null
          : 'application imports only domain and application';
    });
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('infrastructure implements domain ports and nothing above them', () {
    final problems = check(
      (s) => s.layer == 'infrastructure',
      (s, i) =>
          i.layer == 'presentation' ||
              i.layer == 'application' ||
              (i.path?.startsWith('app/') ?? false)
          ? 'adapters do not know application, presentation or app'
          : null,
    );
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('only the composition root knows infrastructure adapters', () {
    final problems = check(
      (s) =>
          s.layer != 'infrastructure' && s.path != 'app/composition_root.dart',
      (s, i) => i.layer == 'infrastructure'
          ? 'use the port from the application layer'
          : null,
    );
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('presentation never reaches the composition root', () {
    final problems = check(
      (s) => s.layer == 'presentation',
      (s, i) => i.path == 'app/composition_root.dart'
          ? 'presentation talks to use cases, not to wiring'
          : null,
    );
    expect(problems, isEmpty, reason: problems.join('\n'));
  });
}

final _importPattern = RegExp(r"^import '([^']+)'", multiLine: true);

/// One file under lib/, with its layer and imports.
class _Source {
  _Source(Directory lib, File file)
    : path = file.path.substring(lib.path.length + 1),
      imports = _importPattern
          .allMatches(file.readAsStringSync())
          .map((m) => _Import(lib, file, m.group(1)!))
          .toList();

  final String path;
  final List<_Import> imports;

  bool get generated =>
      path.startsWith('gen/') ||
      path.contains('/l10n/gen/') ||
      path.endsWith('.g.dart');

  String? get feature => _featureOf(path);
  String? get layer => _layerOf(path);
}

/// An import, resolved to a lib/-relative path when it points into the app.
class _Import {
  _Import(Directory lib, File from, this.spec)
    : path = spec.startsWith('package:vardigo/')
          ? spec.substring('package:vardigo/'.length)
          : spec.contains(':')
          ? null
          : from.uri.resolve(spec).toFilePath().substring(lib.path.length + 1);

  final String spec;
  final String? path;

  String? get layer => path == null ? null : _layerOf(path!);
}

String? _featureOf(String path) {
  final parts = path.split('/');
  return parts.length > 2 && parts.first == 'features' ? parts[1] : null;
}

String? _layerOf(String path) {
  final parts = path.split('/');
  return parts.length > 3 && parts.first == 'features' ? parts[2] : null;
}
