import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zamzam_flutter/core/strings.dart';
import 'package:zamzam_flutter/core/ui/dhivehi_text.dart';
import 'package:zamzam_flutter/features/content/content_models.dart';
import 'package:zamzam_flutter/features/content/service_card.dart';

void main() {
  testWidgets(
    'service fallback and long text fit compact and large-text cards',
    (tester) async {
      for (final description in [
        '',
        'ފަސޭހަކަމާއެކު ޢުމްރާ ވިސާ ހޯދައިދިނުން',
        List.filled(15, 'ޢުމްރާ').join(' '),
      ]) {
        for (final textScale in [1.0, 2.0]) {
          await tester.pumpWidget(
            CupertinoApp(
              home: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
                child: FontScaleScope(
                  scale: 1.12,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: SingleChildScrollView(
                      child: Builder(
                        builder: (context) => Center(
                          child: ServiceCard(
                            service: ServiceItem(
                              title: 'ޢުމްރާ ޕެކޭޖު',
                              description: description,
                            ),
                            width: 272,
                            height: ServiceCard.cardHeight(context, 272),
                            image: const SizedBox(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            find.text(
              description.isEmpty
                  ? Dv.servicesDescriptionFallback
                  : description,
            ),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        }
      }
    },
  );
}
