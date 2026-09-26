import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'features/appearance/infrastructure/repositories/prefs_theme_mode_repository.dart';

/// Everything that runs before the first frame, shared by every entry point.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Read before the first frame so a saved dark theme does not flash light.
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        themeModeRepositoryProvider.overrideWithValue(
          PrefsThemeModeRepository(prefs),
        ),
      ],
      child: const VardigoApp(),
    ),
  );
}
