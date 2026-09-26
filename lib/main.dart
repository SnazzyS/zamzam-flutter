import 'package:flutter/cupertino.dart';
import 'app/glass_tab_bar.dart';
import 'core/strings.dart';
import 'core/theme.dart';

void main() => runApp(const ZamzamApp());

class ZamzamApp extends StatelessWidget {
  const ZamzamApp({super.key});
  @override
  Widget build(BuildContext context) => CupertinoApp(
    title: 'Zamzam Mobile',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.theme,
    builder: (context, child) =>
        Directionality(textDirection: TextDirection.rtl, child: child!),
    home: const _NavigationPreview(),
  );
}

class _NavigationPreview extends StatefulWidget {
  const _NavigationPreview();
  @override
  State<_NavigationPreview> createState() => _NavigationPreviewState();
}

class _NavigationPreviewState extends State<_NavigationPreview> {
  int _selected = 0;
  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
    child: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                _selected == 0 ? Dv.appName : RootTab.values[_selected].label,
                style: AppTheme.dhivehi(38),
              ),
            ),
          ),
          GlassTabBar(
            selectedIndex: _selected,
            onSelected: (index) => setState(() => _selected = index),
          ),
        ],
      ),
    ),
  );
}
