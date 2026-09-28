// Manual reference evidence generator; does not replace or approve goldens.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:zamzam_flutter/features/weather/weather_models.dart';
import 'package:zamzam_flutter/features/weather/weather_scene.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'export deterministic 10-fps scene keyframes for native comparison',
    () async {
      final output = Directory('artifacts/weather/motion/flutter')
        ..createSync(recursive: true);
      for (final style in WeatherStyle.values) {
        for (var frame = 0; frame < 3; frame++) {
          final recorder = ui.PictureRecorder();
          final canvas = ui.Canvas(recorder)..scale(3);
          WeatherScenePainter(
            style: style,
            time: frame * .8,
          ).paint(canvas, const ui.Size(354, 231));
          final picture = recorder.endRecording();
          final image = await picture.toImage(1062, 693);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          File(
            '${output.path}/${style.name}-$frame.png',
          ).writeAsBytesSync(bytes!.buffer.asUint8List());
          image.dispose();
          picture.dispose();
        }
      }
      expect(output.listSync().whereType<File>().length, 12);
    },
  );
}
