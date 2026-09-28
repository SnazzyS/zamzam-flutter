import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zamzam_flutter/core/time/clock.dart';
import 'package:zamzam_flutter/features/weather/weather_models.dart';
import 'package:zamzam_flutter/features/weather/weather_motion.dart';
import 'package:zamzam_flutter/features/weather/weather_scene.dart';

class TestClock implements Clock {
  DateTime value = DateTime.utc(2001, 1, 1, 0, 0, 10);
  @override
  DateTime now() => value;
}

double time(WidgetTester tester) =>
    (tester
                .widget<CustomPaint>(
                  find.byKey(const ValueKey('weather-scene-paint')),
                )
                .painter!
            as WeatherScenePainter)
        .time;

void main() {
  testWidgets(
    'scene runs at ten fps and pauses for tabs, reduced motion and lifecycle',
    (tester) async {
      final clock = TestClock();
      Widget scene({
        bool active = true,
        bool reduced = false,
        bool enabled = true,
      }) => CupertinoApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(400, 800),
            disableAnimations: reduced,
          ),
          child: TickerMode(
            enabled: active,
            child: SizedBox(
              width: 354,
              height: 231,
              child: WeatherScene(
                style: WeatherStyle.rain,
                enabled: enabled,
                clock: clock,
              ),
            ),
          ),
        ),
      );
      await tester.pumpWidget(scene());
      expect(time(tester), 10);
      clock.value = clock.value.add(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 99));
      expect(time(tester), 10);
      await tester.pump(const Duration(milliseconds: 1));
      expect(time(tester), 11);
      await tester.pumpWidget(scene(active: false));
      expect(time(tester), 0);
      await tester.pump(const Duration(seconds: 1));
      expect(time(tester), 0);
      await tester.pumpWidget(scene(reduced: true));
      expect(time(tester), 0);
      await tester.pumpWidget(scene());
      expect(time(tester), 11);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump(const Duration(seconds: 1));
      expect(time(tester), 0);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(time(tester), 11);
      await tester.pumpWidget(scene(enabled: false));
      expect(time(tester), 0);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'scrolling fully out of the viewport stops updates and returning resumes',
    (tester) async {
      final clock = TestClock();
      final scroll = ScrollController();
      await tester.binding.setSurfaceSize(const Size(400, 400));
      await tester.pumpWidget(
        CupertinoApp(
          home: CustomScrollView(
            controller: scroll,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(
                      height: 231,
                      child: WeatherScene(
                        style: WeatherStyle.clear,
                        enabled: true,
                        clock: clock,
                      ),
                    ),
                    const SizedBox(height: 1200),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      expect(time(tester), 10);
      scroll.jumpTo(600);
      await tester.pump();
      expect(time(tester), 0);
      clock.value = clock.value.add(const Duration(seconds: 5));
      await tester.pump(const Duration(seconds: 1));
      expect(time(tester), 0);
      scroll.jumpTo(0);
      await tester.pump();
      expect(time(tester), 15);
      await tester.pumpWidget(const SizedBox());
      scroll.dispose();
      await tester.binding.setSurfaceSize(null);
    },
  );
}
