import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'app/router.dart';
import 'core/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/storage/key_value_store.dart';
import 'features/settings/settings_controller.dart';
import 'features/settings/settings_view.dart';
import 'core/ui/dhivehi_text.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(
    ZamzamApp(settings: SettingsController(PreferencesStore(preferences))),
  );
}

class ZamzamApp extends StatefulWidget {
  const ZamzamApp({super.key, this.router, this.settings});
  final GoRouter? router;
  final SettingsController? settings;
  @override
  State<ZamzamApp> createState() => _ZamzamAppState();
}

class _ZamzamAppState extends State<ZamzamApp> {
  late final SettingsController _settings =
      widget.settings ?? SettingsController(MemoryStore());
  late final GoRouter _router = widget.router ?? createRouter();
  @override
  void dispose() {
    if (widget.router == null) _router.dispose();
    if (widget.settings == null) _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SettingsScope(
    controller: _settings,
    child: ListenableBuilder(
      listenable: _settings,
      builder: (context, _) => FontScaleScope(
        scale: _settings.scale.multiplier,
        child: CupertinoApp.router(
          title: 'Zamzam Mobile',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          routerConfig: _router,
          builder: (context, child) =>
              Directionality(textDirection: TextDirection.rtl, child: child!),
        ),
      ),
    ),
  );
}
