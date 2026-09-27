import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import '../../core/theme.dart';
import '../../core/ui/components.dart';

class ChecklistView extends StatefulWidget {
  const ChecklistView({super.key});
  static const pages = [
    'checklist-documents',
    'checklist-money',
    'checklist-medicine',
    'checklist-cloths',
  ];
  @override
  State<ChecklistView> createState() => _ChecklistViewState();
}

class _ChecklistViewState extends State<ChecklistView> {
  final _pages = PageController(keepPage: false);
  int _selected = 0;
  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ArtworkFrame(
    child: Stack(
      fit: StackFit.expand,
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: PageView.builder(
            controller: _pages,
            itemCount: ChecklistView.pages.length,
            onPageChanged: (page) => setState(() => _selected = page),
            // Swift's page-style TabView centers its full-height image in
            // the safe-area content, shifting it by half the top inset.
            itemBuilder: (context, index) => ColoredBox(
              color: CupertinoColors.white,
              child: ClipRect(
                child: Transform.translate(
                  offset: Offset(0, MediaQuery.paddingOf(context).top / 2),
                  child: ArtworkImage(
                    ChecklistView.pages[index],
                    aspectRatio: 941 / 1672,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 34,
          child: Center(
            child: Semantics(
              key: const ValueKey('checklist-page'),
              label: '${_selected + 1} / ${ChecklistView.pages.length}',
              liveRegion: true,
              child: ExcludeSemantics(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.black.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    textDirection: TextDirection.rtl,
                    children: [
                      for (var i = 0; i < ChecklistView.pages.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        AnimatedContainer(
                          duration: MediaQuery.disableAnimationsOf(context)
                              ? Duration.zero
                              : const Duration(milliseconds: 220),
                          curve: Curves.easeInOut,
                          width: i == _selected ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: CupertinoColors.white.withValues(
                              alpha: i == _selected ? 1 : .42,
                            ),
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x3D000000),
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

/// Full content-area artwork extends behind the status bar; the persistent
/// bottom navigation still owns its own safe-area region, as in Swift.
class ArtworkFrame extends StatelessWidget {
  const ArtworkFrame({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      child,
      const PositionedDirectional(
        top: 12,
        start: 24,
        child: SafeArea(bottom: false, child: FloatingBackButton()),
      ),
    ],
  );
}

class ArtworkImage extends StatelessWidget {
  const ArtworkImage(this.name, {super.key, required this.aspectRatio});
  final String name;
  final double aspectRatio;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final decodeWidth =
          (math.max(constraints.maxWidth, constraints.maxHeight * aspectRatio) *
                  MediaQuery.devicePixelRatioOf(context))
              .ceil();
      return ClipRect(
        child: Image.asset(
          AppTheme.image(name),
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          fit: BoxFit.cover,
          cacheWidth: decodeWidth,
          excludeFromSemantics: true,
        ),
      );
    },
  );
}
