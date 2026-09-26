import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zamzam_flutter/core/theme.dart';
import 'package:zamzam_flutter/core/ui/components.dart';
import 'package:zamzam_flutter/features/content/content_models.dart';
import 'package:zamzam_flutter/features/content/trip_card.dart';

void main() {
  testWidgets(
    'Trip card preserves mixed-script price and handles long titles and system text',
    (tester) async {
      tester.view.resetPhysicalSize();
      tester.view.physicalSize = const Size(1206, 2622);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final loader = FontLoader('MV Waheed')
        ..addFont(rootBundle.load('assets/fonts/MVWaheed.otf'));
      await loader.load();
      for (final scale in [1.0, 2.0]) {
        await tester.pumpWidget(
          CupertinoApp(
            theme: AppTheme.theme,
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: ScreenContainer(
                  child: TripCard(
                    package: TripPackage(
                      title: scale == 1
                          ? 'ޑިސެންބަރު ޢުމްރާ'
                          : 'ރަމަޟާން ޢުމްރާ 2027 - ފަހު 15 ދުވަސް ޑިސެންބަރު ޢުމްރާ',
                      price: '29,500',
                    ),
                    image: Image.file(
                      File('test/fixtures/trip.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('29,500'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
