import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/physics.dart';
import '../core/platform/app_symbol.dart';
import '../core/strings.dart';
import '../core/theme.dart';

enum RootTab {
  home(Dv.homeNav, 'house.fill', CupertinoIcons.house_fill),
  weather(Dv.scheduleNav, 'cloud.sun.rain', CupertinoIcons.cloud_sun_rain),
  prayer(Dv.prayerTimesNav, 'clock', CupertinoIcons.clock),
  member(
    Dv.memberNav,
    'person.text.rectangle',
    CupertinoIcons.person_crop_rectangle,
  ),
  settings(Dv.settingsNav, 'gearshape', CupertinoIcons.gear_alt);

  const RootTab(this.label, this.symbol, this.icon);
  final String label;
  final String symbol;
  final IconData icon;
}

class GlassTabBar extends StatelessWidget {
  const GlassTabBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: .10),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: CupertinoColors.white.withValues(alpha: .22),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: CupertinoColors.white.withValues(alpha: .62),
              ),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                for (final tab in RootTab.values)
                  Expanded(
                    child: _TabItem(
                      tab: tab,
                      selected: selectedIndex == tab.index,
                      onTap: () => onSelected(tab.index),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _TabItem extends StatefulWidget {
  const _TabItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });
  final RootTab tab;
  final bool selected;
  final VoidCallback onTap;
  @override
  State<_TabItem> createState() => _TabItemState();
}

class _TabItemState extends State<_TabItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _selection = AnimationController.unbounded(
    vsync: this,
    value: widget.selected ? 1 : 0,
  );
  @override
  void didUpdateWidget(_TabItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected == widget.selected) return;
    final target = widget.selected ? 1.0 : 0.0;
    if (MediaQuery.disableAnimationsOf(context)) {
      _selection.value = target;
      return;
    }
    const frequency = 2 * math.pi / .34;
    _selection.animateWith(
      SpringSimulation(
        SpringDescription(
          mass: 1,
          stiffness: frequency * frequency,
          damping: 2 * .82 * frequency,
        ),
        _selection.value,
        target,
        _selection.velocity,
      ),
    );
  }

  @override
  void dispose() {
    _selection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: widget.tab.label,
    onTap: widget.onTap,
    button: true,
    selected: widget.selected,
    child: ExcludeSemantics(
      child: CupertinoButton(
        key: ValueKey('tab-${widget.tab.name}'),
        padding: EdgeInsets.zero,
        minimumSize: const Size(48, 52),
        onPressed: widget.onTap,
        child: AnimatedBuilder(
          animation: _selection,
          builder: (context, child) {
            final t = _selection.value.clamp(0.0, 1.0);
            return SizedBox(
              height: 52,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: t,
                      child: Container(
                        width: 54,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: CupertinoColors.white.withValues(alpha: .66),
                          border: Border.all(
                            color: CupertinoColors.white.withValues(alpha: .72),
                            width: .8,
                          ),
                        ),
                      ),
                    ),
                    AppSymbol(
                      widget.tab.symbol,
                      fallback: widget.tab.icon,
                      size: 22 + 2 * t,
                      bold: widget.selected,
                      color: AppTheme.text.withValues(alpha: .58 + .42 * t),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}
