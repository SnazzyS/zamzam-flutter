import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/semantics.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import 'content_models.dart';
import 'service_card.dart';

class ServicePager extends StatefulWidget {
  const ServicePager({super.key, required this.services});
  final List<ServiceItem> services;
  @override
  State<ServicePager> createState() => _ServicePagerState();
}

class _ServicePagerState extends State<ServicePager> {
  final _pages = PageController();
  int _selected = 0;
  int? _target;
  int _animation = 0;
  static const _next = CustomSemanticsAction(label: 'ދެން އޮތް ޚިދުމަތް');
  static const _previous = CustomSemanticsAction(label: 'ކުރީގެ ޚިދުމަތް');
  @override
  void didUpdateWidget(ServicePager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.services.length != widget.services.length) {
      _selected = 0;
      _target = null;
      _animation++;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pages.hasClients) {
          _pages.jumpToPage(0);
        }
      });
    }
  }

  Future<void> _select(int index, {bool accessibility = false}) async {
    final count = widget.services.length;
    if (count < 2 || !_pages.hasClients) return;
    final next = accessibility ? index % count : index.clamp(0, count - 1);
    final animation = ++_animation;
    setState(() {
      _selected = next;
      _target = next;
    });
    if (MediaQuery.disableAnimationsOf(context)) {
      _pages.jumpToPage(next);
    } else {
      await _pages.animateToPage(
        next,
        duration: Duration(milliseconds: accessibility ? 260 : 240),
        curve: Curves.easeInOut,
      );
    }
    if (mounted && animation == _animation) {
      setState(() {
        _target = null;
        _selected = (_pages.page?.round() ?? next).clamp(0, count - 1);
      });
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.services.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(constraints.maxWidth, 368.0);
        final height = widget.services
            .map(
              (service) =>
                  ServiceCard.cardHeight(context, width, service: service),
            )
            .reduce(math.max);
        return Semantics(
          key: const ValueKey('services-pager-semantics'),
          container: true,
          label: Dv.servicesTitle,
          value: '${_selected + 1} / ${widget.services.length}',
          increasedValue:
              '${(_selected + 1) % widget.services.length + 1} / ${widget.services.length}',
          decreasedValue:
              '${(_selected - 1) % widget.services.length + 1} / ${widget.services.length}',
          onIncrease: widget.services.length > 1
              ? () => _select(_selected + 1, accessibility: true)
              : null,
          onDecrease: widget.services.length > 1
              ? () => _select(_selected - 1, accessibility: true)
              : null,
          customSemanticsActions: widget.services.length > 1
              ? {
                  _next: () => _select(_selected + 1, accessibility: true),
                  _previous: () => _select(_selected - 1, accessibility: true),
                }
              : null,
          child: SizedBox(
            height: math.max(456, height + 25),
            child: Column(
              children: [
                SizedBox(
                  height: height,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: PageView.builder(
                      controller: _pages,
                      physics: const BouncingScrollPhysics(),
                      itemCount: widget.services.length,
                      onPageChanged: (index) {
                        if (_target == null || _target == index) {
                          setState(
                            () => _selected = index.clamp(
                              0,
                              widget.services.length - 1,
                            ),
                          );
                        }
                      },
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: OverflowBox(
                          minWidth: width,
                          maxWidth: width,
                          child: ServiceCard(
                            service: widget.services[index],
                            width: width,
                            height: height,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.services.length > 1) ...[
                  const SizedBox(height: 18),
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < widget.services.length; i++) ...[
                        if (i > 0) const SizedBox(width: 7),
                        Semantics(
                          key: ValueKey('service-dot-state-$i'),
                          label: '${i + 1} / ${widget.services.length}',
                          button: true,
                          selected: i == _selected,
                          onTap: () => _select(i),
                          child: ExcludeSemantics(
                            child: CupertinoButton(
                              key: ValueKey('service-dot-$i'),
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              onPressed: () => _select(i),
                              child: AnimatedContainer(
                                duration:
                                    MediaQuery.disableAnimationsOf(context)
                                    ? Duration.zero
                                    : const Duration(milliseconds: 220),
                                curve: Curves.easeInOut,
                                width: i == _selected ? 22 : 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: i == _selected
                                      ? AppTheme.green
                                      : AppTheme.secondary.withValues(
                                          alpha: .24,
                                        ),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
