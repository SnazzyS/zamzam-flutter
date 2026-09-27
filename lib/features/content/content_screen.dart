import 'package:flutter/cupertino.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../core/ui/components.dart';
import 'content_models.dart';
import 'content_repository.dart';
import 'trip_card.dart';
import 'service_pager.dart';

class ContentScope extends InheritedWidget {
  const ContentScope({
    super.key,
    required this.repository,
    required super.child,
  });
  final ContentRepository repository;
  static ContentRepository of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ContentScope>()!.repository;
  @override
  bool updateShouldNotify(ContentScope oldWidget) =>
      repository != oldWidget.repository;
}

class TripsView extends StatelessWidget {
  const TripsView({super.key});
  @override
  Widget build(BuildContext context) => ContentScreen(
    title: Dv.tripsTitle,
    image: 'trips',
    emptyTitle: Dv.tripsEmptyTitle,
    emptyBody: Dv.tripsEmptyBody,
    errorTitle: Dv.tripsErrorTitle,
    isEmpty: (content) => content.packages.isEmpty,
    builder: (content) => TripList(packages: content.packages),
  );
}

class ServicesView extends StatelessWidget {
  const ServicesView({super.key});
  @override
  Widget build(BuildContext context) => ContentScreen(
    title: Dv.servicesTitle,
    image: 'services',
    emptyTitle: Dv.servicesEmptyTitle,
    emptyBody: Dv.servicesEmptyBody,
    errorTitle: Dv.servicesErrorTitle,
    isEmpty: (content) => content.services.isEmpty,
    builder: (content) => ServicePager(services: content.services),
  );
}

class ContentScreen extends StatefulWidget {
  const ContentScreen({
    super.key,
    required this.title,
    required this.image,
    required this.emptyTitle,
    required this.emptyBody,
    required this.errorTitle,
    required this.isEmpty,
    required this.builder,
  });
  final String title, image, emptyTitle, emptyBody, errorTitle;
  final bool Function(WebsiteContent) isEmpty;
  final Widget Function(WebsiteContent) builder;
  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  ContentRepository? _repository;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repository = ContentScope.of(context);
    if (repository == _repository) return;
    _repository = repository;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) repository.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final repository = _repository!;
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final state = repository.state;
        final content = state.content;
        return ScreenContainer(
          showBack: true,
          scrollKey: PageStorageKey(widget.image),
          onRefresh: () => repository.load(forceRefresh: true),
          child: Column(
            children: [
              HeaderCard(title: widget.title, image: widget.image),
              const SizedBox(height: 22),
              if (content != null)
                if (widget.isEmpty(content))
                  ContentStatus(
                    title: widget.emptyTitle,
                    message: widget.emptyBody,
                    empty: true,
                  )
                else
                  widget.builder(content)
              else if (state.phase == ContentPhase.failed)
                ContentStatus(
                  title: widget.errorTitle,
                  onRetry: () => repository.load(forceRefresh: true),
                )
              else
                const ContentLoadingGrid(),
            ],
          ),
        );
      },
    );
  }
}

class ContentLoadingGrid extends StatelessWidget {
  const ContentLoadingGrid({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Loading',
    liveRegion: true,
    child: GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 16,
        mainAxisExtent: 220,
      ),
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: AppTheme.shadow,
              blurRadius: 24,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: const Center(child: CupertinoActivityIndicator()),
      ),
    ),
  );
}
