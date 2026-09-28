import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/time/clock.dart';

/// Ten frame updates per second, matching the reference's TimelineView.
class WeatherTimeline extends ChangeNotifier {
  WeatherTimeline(this.clock);
  final Clock clock;
  Timer? _timer;
  double seconds = 0;
  bool get running => _timer != null;

  void setRunning(bool value) {
    if (value == running) return;
    if (value) {
      _tick();
      _timer = Timer.periodic(
        const Duration(milliseconds: 100),
        (_) => _tick(),
      );
    } else {
      _timer?.cancel();
      _timer = null;
      seconds = 0;
      notifyListeners();
    }
  }

  void _tick() {
    // Swift's timeIntervalSinceReferenceDate is measured from 2001-01-01 UTC.
    seconds =
        clock.now().microsecondsSinceEpoch / Duration.microsecondsPerSecond -
        978307200;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
