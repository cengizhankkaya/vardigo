import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'features/appearance/data/prefs_theme_mode_repository.dart';

Future<void> main() async {
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
