import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zamzam_flutter/main.dart';
import 'package:zamzam_flutter/core/storage/key_value_store.dart';
import 'package:zamzam_flutter/core/strings.dart';
import 'package:zamzam_flutter/features/settings/settings_controller.dart';

void main() {
  testWidgets(
    'size control changes Dhivehi labels but keeps header and system values fixed',
    (tester) async {
      final store = MemoryStore();
      final settings = SettingsController(store);
      await tester.pumpWidget(ZamzamApp(settings: settings));
      await tester.tap(find.byKey(const ValueKey('tab-settings')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('font-large')));
      await tester.pumpAndSettle();
      expect(settings.scale, FontScale.large);
      expect(SettingsController(store).scale, FontScale.large);
      expect(
        tester.widget<Text>(find.text(Dv.settingsGeneral)).style!.fontSize,
        22 * 1.12,
      );
      expect(
        tester.widget<Text>(find.text(Dv.settingsTitle)).style!.fontSize,
        38,
      );
      expect(
        tester
            .widget<Text>(find.text(Dv.settingsLanguageValue))
            .style!
            .fontSize,
        15,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
