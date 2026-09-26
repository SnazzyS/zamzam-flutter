import 'package:flutter/cupertino.dart';
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
    home: CupertinoPageScaffold(
      child: Center(child: Text(Dv.appName, style: AppTheme.dhivehi(38))),
    ),
  );
}
