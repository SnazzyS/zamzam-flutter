import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../platform/app_symbol.dart';
import '../strings.dart';
import '../theme.dart';
import 'dhivehi_text.dart';

class ScreenContainer extends StatelessWidget {
  const ScreenContainer({
    super.key,
    required this.child,
    this.onRefresh,
    this.showBack = false,
    this.background = AppTheme.background,
    this.padding = const EdgeInsets.fromLTRB(24, 28, 24, 36),
    this.maxWidth = 508,
    this.scrollKey,
  });
  final Widget child;
  final Future<void> Function()? onRefresh;
  final bool showBack;
  final Color background;
  final EdgeInsets padding;
  final double maxWidth;
  final PageStorageKey<String>? scrollKey;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: background,
    child: Stack(
      children: [
        SafeArea(
          bottom: false,
          child: CustomScrollView(
            key: scrollKey,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              if (onRefresh != null)
                CupertinoSliverRefreshControl(onRefresh: onRefresh),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Padding(
                      padding: padding,
                      child: SizedBox(width: double.infinity, child: child),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showBack)
          const PositionedDirectional(
            top: 12,
            start: 24,
            child: SafeArea(bottom: false, child: FloatingBackButton()),
          ),
      ],
    ),
  );
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 18,
  });
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: const [
        BoxShadow(color: AppTheme.shadow, blurRadius: 36, offset: Offset(0, 8)),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Padding(padding: padding, child: child),
    ),
  );
}

class ModuleImage extends StatelessWidget {
  const ModuleImage(this.name, {super.key, this.size = 76});
  final String name;
  final double size;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: Image.asset(
      AppTheme.image(name),
      width: size,
      height: size,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    ),
  );
}

class HeaderCard extends StatelessWidget {
  const HeaderCard({super.key, required this.title, required this.image});
  final String title;
  final String image;
  @override
  Widget build(BuildContext context) => AppCard(
    child: Row(
      textDirection: TextDirection.ltr,
      children: [
        ModuleImage(image, size: 62),
        const SizedBox(width: 16),
        Expanded(
          child: DvText(
            title,
            size: 30,
            weight: FontWeight.w600,
            align: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}

class FloatingBackButton extends StatelessWidget {
  const FloatingBackButton({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Back',
    button: true,
    child: ExcludeSemantics(
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.surface.withValues(alpha: .95),
          boxShadow: const [
            BoxShadow(
              color: AppTheme.shadow,
              blurRadius: 28,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: CupertinoButton(
          key: const ValueKey('back'),
          padding: EdgeInsets.zero,
          onPressed: () => context.pop(),
          child: const AppSymbol(
            'chevron.right',
            fallback: CupertinoIcons.chevron_right,
            size: 24,
            bold: true,
          ),
        ),
      ),
    ),
  );
}

class PrimaryAction extends StatelessWidget {
  const PrimaryAction({
    super.key,
    required this.title,
    required this.onPressed,
    this.icon = CupertinoIcons.arrow_right_circle,
    this.loading = false,
    this.enabled = true,
  });
  final String title;
  final VoidCallback onPressed;
  final IconData icon;
  final bool loading;
  final bool enabled;
  @override
  Widget build(BuildContext context) => CupertinoButton(
    color: enabled ? AppTheme.green : AppTheme.secondary.withValues(alpha: .55),
    disabledColor: AppTheme.secondary.withValues(alpha: .55),
    borderRadius: BorderRadius.circular(14),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    minimumSize: const Size(double.infinity, 52),
    onPressed: enabled && !loading ? onPressed : null,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          const CupertinoActivityIndicator(color: CupertinoColors.white)
        else
          Icon(icon, size: 20, color: CupertinoColors.white),
        const SizedBox(width: 8),
        Flexible(
          child: DvText(
            title,
            size: 16,
            weight: FontWeight.w600,
            color: CupertinoColors.white,
            align: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}

class ContentStatus extends StatelessWidget {
  const ContentStatus({
    super.key,
    required this.title,
    this.message = '',
    this.onRetry,
    this.empty = false,
  });
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final bool empty;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              empty ? CupertinoIcons.tray : CupertinoIcons.wifi_exclamationmark,
              size: 34,
              color: AppTheme.green,
            ),
          ),
          const SizedBox(height: 16),
          DvText(
            title,
            size: 22,
            weight: FontWeight.w600,
            align: TextAlign.center,
          ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 16),
            DvText(
              message,
              size: 15,
              color: AppTheme.secondary,
              align: TextAlign.center,
            ),
          ],
          if (onRetry != null)
            CupertinoButton(
              onPressed: onRetry,
              child: const DvText(
                Dv.retry,
                size: 15,
                weight: FontWeight.w600,
                color: AppTheme.green,
              ),
            ),
        ],
      ),
    ),
  );
}

class RemoteImageBox extends StatelessWidget {
  const RemoteImageBox(this.url, {super.key, this.aspectRatio = 1});
  final Uri? url;
  final double aspectRatio;
  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: aspectRatio,
    child: ColoredBox(
      color: AppTheme.surfaceVariant,
      child: ClipRect(
        child: url == null
            ? const _MissingImage()
            : Image.network(
                url.toString(),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                excludeFromSemantics: true,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const Center(child: CupertinoActivityIndicator()),
                errorBuilder: (context, error, stackTrace) =>
                    const _MissingImage(),
              ),
      ),
    ),
  );
}

class _MissingImage extends StatelessWidget {
  const _MissingImage();
  @override
  Widget build(BuildContext context) => const Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(CupertinoIcons.photo, color: AppTheme.secondary),
      SizedBox(height: 8),
      DvText(Dv.imageUnavailable, size: 13, color: AppTheme.secondary),
    ],
  );
}
