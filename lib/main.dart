import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'app/router.dart';
import 'core/theme.dart';

void main() => runApp(const ZamzamApp());

class ZamzamApp extends StatefulWidget {
  const ZamzamApp({super.key, this.router});
  final GoRouter? router;
  @override
  State<ZamzamApp> createState() => _ZamzamAppState();
}

class _ZamzamAppState extends State<ZamzamApp> {
  late final GoRouter _router = widget.router ?? createRouter();
  @override
  void dispose() {
    if (widget.router == null) _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CupertinoApp.router(
    title: 'Zamzam Mobile',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.theme,
    routerConfig: _router,
    builder: (context, child) =>
        Directionality(textDirection: TextDirection.rtl, child: child!),
  );
}
