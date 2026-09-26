import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zamzam_flutter/core/ui/components.dart';
import 'package:zamzam_flutter/core/ui/dhivehi_text.dart';
import 'package:zamzam_flutter/core/strings.dart';

void main() {
  testWidgets('error retry is actionable at compact width and enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var retries = 0;
    await tester.pumpWidget(
      CupertinoApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: FontScaleScope(
              scale: 1.12,
              child: ScreenContainer(
                child: ContentStatus(
                  title: Dv.networkError,
                  message: Dv.genericError,
                  onRetry: () => retries++,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text(Dv.retry));
    expect(retries, 1);
    expect(tester.takeException(), isNull);
  });
  testWidgets('busy actions cannot submit twice', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: PrimaryAction(
            title: Dv.signInAction,
            loading: true,
            onPressed: () => calls++,
          ),
        ),
      ),
    );
    await tester.tap(find.text(Dv.signInAction));
    expect(calls, 0);
  });
}
