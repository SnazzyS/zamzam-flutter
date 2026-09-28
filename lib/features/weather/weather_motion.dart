import 'package:flutter/cupertino.dart';
import '../../core/time/clock.dart';
import 'weather_models.dart';
import 'weather_scene.dart';
import 'weather_timeline.dart';

class WeatherScene extends StatefulWidget {
  const WeatherScene({
    super.key,
    required this.style,
    required this.enabled,
    this.clock = const SystemClock(),
    this.frameTime,
  });
  final WeatherStyle style;
  final bool enabled;
  final Clock clock;

  /// Deterministic reference captures; normal screens leave this null.
  final double? frameTime;
  @override
  State<WeatherScene> createState() => _WeatherSceneState();
}

class _WeatherSceneState extends State<WeatherScene>
    with WidgetsBindingObserver {
  late WeatherTimeline _timeline;
  ScrollPosition? _position;
  bool _scheduled = false;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    _timeline = WeatherTimeline(widget.clock);
    _active =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (_position != position) {
      _position?.removeListener(_scheduleVisibility);
      _position = position;
      _position?.addListener(_scheduleVisibility);
    }
    // Register dependencies so hidden tab/reduced-motion changes stop the timer.
    TickerMode.valuesOf(context).enabled;
    MediaQuery.disableAnimationsOf(context);
    _scheduleVisibility();
  }

  @override
  void didUpdateWidget(WeatherScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clock != widget.clock) {
      _timeline.dispose();
      _timeline = WeatherTimeline(widget.clock);
    }
    _scheduleVisibility();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    _updateVisibility();
  }

  @override
  void didChangeMetrics() => _scheduleVisibility();

  void _scheduleVisibility() {
    if (_scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (mounted) _updateVisibility();
    });
  }

  void _updateVisibility() {
    if (!mounted) return;
    var visible =
        widget.enabled &&
        widget.frameTime == null &&
        _active &&
        TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context);
    final box = context.findRenderObject();
    if (visible && box is RenderBox && box.attached && box.hasSize) {
      final rect = box.localToGlobal(Offset.zero) & box.size;
      final scroll = _position?.context.notificationContext?.findRenderObject();
      final viewport = scroll is RenderBox && scroll.hasSize
          ? scroll.localToGlobal(Offset.zero) & scroll.size
          : Offset.zero & MediaQuery.sizeOf(context);
      visible = rect.overlaps(viewport);
    } else {
      visible = false;
    }
    _timeline.setRunning(visible);
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      key: const ValueKey('weather-scene-paint'),
      painter: WeatherScenePainter(
        style: widget.style,
        time: widget.frameTime ?? 0,
        timeline: widget.frameTime == null ? _timeline : null,
      ),
    ),
  );
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _position?.removeListener(_scheduleVisibility);
    _timeline.dispose();
    super.dispose();
  }
}
