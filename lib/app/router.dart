import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../core/strings.dart';
import '../features/settings/settings_view.dart';
import '../features/home/home_view.dart';
import '../features/content/content_screen.dart';
import '../features/artwork/checklist_view.dart';
import '../features/artwork/office_view.dart';
import '../core/theme.dart';
import 'glass_tab_bar.dart';

GoRouter createRouter({
  Map<RootTab, WidgetBuilder> roots = const {},
  List<RouteBase> homeChildren = const [],
}) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _AppShell(shell: shell),
        branches: [
          for (final tab in RootTab.values)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/${tab.name}',
                  builder: roots[tab] == null
                      ? (context, state) => tab == RootTab.home
                            ? const HomeView()
                            : tab == RootTab.settings
                            ? const SettingsView()
                            : _FeatureRoot(tab: tab)
                      : (context, state) => roots[tab]!(context),
                  routes: tab == RootTab.home
                      ? [
                          for (final module in HomeModule.values)
                            GoRoute(
                              path: module.name,
                              builder: (context, state) => switch (module) {
                                HomeModule.trips => const TripsView(),
                                HomeModule.services => const ServicesView(),
                                HomeModule.checklist => const ChecklistView(),
                                HomeModule.office => const OfficeView(),
                                _ => HomeDestinationHeader(module: module),
                              },
                            ),
                          ...homeChildren,
                        ]
                      : const [],
                ),
              ],
            ),
        ],
      ),
    ],
  );
}

class _AppShell extends StatelessWidget {
  const _AppShell({required this.shell});
  final StatefulNavigationShell shell;
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: shell.currentIndex == 0 || GoRouter.of(context).canPop(),
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop && shell.currentIndex != 0) shell.goBranch(0);
    },
    child: CupertinoPageScaffold(
      child: Column(
        children: [
          Expanded(child: shell),
          ColoredBox(
            color: AppTheme.background,
            child: SafeArea(
              top: false,
              child: GlassTabBar(
                selectedIndex: shell.currentIndex,
                onSelected: (index) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  shell.goBranch(index);
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// Feature roots are replaced in their individual milestones.
class _FeatureRoot extends StatelessWidget {
  const _FeatureRoot({required this.tab});
  final RootTab tab;
  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Center(
      child: Text(
        tab == RootTab.home ? Dv.appName : tab.label,
        style: AppTheme.dhivehi(38),
      ),
    ),
  );
}
