import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zamzam_flutter/main.dart';
import 'package:zamzam_flutter/core/strings.dart';

void main() {
  testWidgets('starts with Dhivehi content in an RTL light shell', (
    tester,
  ) async {
    await tester.pumpWidget(const ZamzamApp());
    expect(find.text(Dv.appName), findsOneWidget);
    final context = tester.element(find.text(Dv.appName));
    expect(Directionality.of(context), TextDirection.rtl);
    expect(CupertinoTheme.of(context).brightness, Brightness.light);
  });
}
