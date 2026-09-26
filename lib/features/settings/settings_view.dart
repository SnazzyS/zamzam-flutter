import 'package:flutter/cupertino.dart';
import '../../core/platform/app_symbol.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../core/ui/components.dart';
import '../../core/ui/dhivehi_text.dart';
import 'settings_controller.dart';

class SettingsScope extends InheritedNotifier<SettingsController> {
  const SettingsScope({
    super.key,
    required SettingsController controller,
    required super.child,
  }) : super(notifier: controller);
  static SettingsController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsScope>()!.notifier!;
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context);
    return ScreenContainer(
      scrollKey: const PageStorageKey('settings'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DvText(Dv.settingsTitle, size: 38, fixedSize: true),
          const SizedBox(height: 22),
          const _Section(
            title: Dv.settingsGeneral,
            child: _ValueRow(
              title: Dv.settingsLanguage,
              value: Dv.settingsLanguageValue,
              symbol: 'globe',
              fallback: CupertinoIcons.globe,
            ),
          ),
          const SizedBox(height: 22),
          _Section(
            title: Dv.settingsDisplay,
            child: Column(
              children: [
                const _ValueRow(
                  title: Dv.settingsTheme,
                  value: Dv.settingsThemeValue,
                  symbol: 'sun.max',
                  fallback: CupertinoIcons.sun_max,
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppSymbol(
                      'textformat.size',
                      fallback: CupertinoIcons.textformat_size,
                      size: 17,
                      color: AppTheme.green,
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: DvText(
                        Dv.settingsFontSize,
                        size: 16,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _FontPicker(settings: settings),
                if (settings.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Semantics(
                      liveRegion: true,
                      child: DvText(
                        settings.error!,
                        size: 14,
                        color: AppTheme.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      DvText(title, size: 22, weight: FontWeight.w600, align: TextAlign.left),
      const SizedBox(height: 12),
      AppCard(child: child),
    ],
  );
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({
    required this.title,
    required this.value,
    required this.symbol,
    required this.fallback,
  });
  final String title, value, symbol;
  final IconData fallback;
  @override
  Widget build(BuildContext context) => Row(
    textDirection: TextDirection.ltr,
    children: [
      SizedBox(
        width: 24,
        child: AppSymbol(
          symbol,
          fallback: fallback,
          size: 17,
          color: AppTheme.green,
        ),
      ),
      const SizedBox(width: 12),
      Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppTheme.secondary,
          letterSpacing: 0,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(child: DvText(title, size: 16, weight: FontWeight.w600)),
    ],
  );
}

class _FontPicker extends StatelessWidget {
  const _FontPicker({required this.settings});
  final SettingsController settings;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final height = (MediaQuery.textScalerOf(context).scale(13) + 16).clamp(
        32.0,
        double.infinity,
      );
      void selectAt(double x) {
        final index = (2 - (x / (constraints.maxWidth / 3)).floor()).clamp(
          0,
          2,
        );
        settings.setScale(FontScale.values[index]);
      }

      return GestureDetector(
        onHorizontalDragUpdate: (details) => selectAt(details.localPosition.dx),
        child: Container(
          height: height,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: const Color(0xFFEFEFF0),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                alignment: Alignment(1 - settings.scale.index.toDouble(), 0),
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: FractionallySizedBox(
                  widthFactor: 1 / 3,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: const [
                        BoxShadow(color: Color(0x0A000000), blurRadius: 3),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (final scale in FontScale.values)
                    Expanded(
                      child: Semantics(
                        button: true,
                        selected: scale == settings.scale,
                        onTap: () => settings.setScale(scale),
                        label: scale.title,
                        child: ExcludeSemantics(
                          child: CupertinoButton(
                            key: ValueKey('font-${scale.name}'),
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            onPressed: () => settings.setScale(scale),
                            child: Text(
                              scale.title,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.text,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
