import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/composition_root.dart';

/// Everything that runs before the first frame, shared by every entry point.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Read before the first frame so a saved dark theme does not flash light.
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(overrides: appAdapters(prefs), child: const VardigoApp()),
  );
}
