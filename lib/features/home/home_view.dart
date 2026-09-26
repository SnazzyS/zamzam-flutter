import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../core/ui/components.dart';
import '../../core/ui/dhivehi_text.dart';

enum HomeModule {
  trips(Dv.tripsTitle, 'trips'),
  services(Dv.servicesTitle, 'services'),
  umrah(Dv.umrahTitle, 'umrah'),
  dua(Dv.duaTitle, 'supplication'),
  checklist(Dv.checklistTitle, 'checklist'),
  office(Dv.officeTitle, 'office');

  const HomeModule(this.title, this.image);
  final String title;
  final String image;
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    final systemScale = MediaQuery.textScalerOf(context).scale(22) / 22;
    final labelHeight = math.max(42.0, 42 * systemScale);
    return ScreenContainer(
      scrollKey: const PageStorageKey('home'),
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DvText(Dv.appName, size: 38, fixedSize: true),
            const SizedBox(height: 28),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                mainAxisExtent: 140 + labelHeight,
              ),
              itemCount: HomeModule.values.length,
              itemBuilder: (context, index) {
                final module = HomeModule.values[index];
                return Semantics(
                  label: module.title,
                  onTap: () => context.push('/home/${module.name}'),
                  button: true,
                  child: ExcludeSemantics(
                    child: CupertinoButton(
                      key: ValueKey('home-${module.name}'),
                      padding: EdgeInsets.zero,
                      onPressed: () => context.push('/home/${module.name}'),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: AppTheme.shadow,
                              blurRadius: 36,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ModuleImage(module.image, size: 114),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: labelHeight,
                                child: Center(
                                  child: DvText(
                                    module.title,
                                    size: 22,
                                    weight: FontWeight.w600,
                                    maxLines: 2,
                                    minScale: .82,
                                    align: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// The reference Umrah/Dua screens are intentionally header-only. Other routes
/// temporarily share the header while their feature milestones are implemented.
class HomeDestinationHeader extends StatelessWidget {
  const HomeDestinationHeader({super.key, required this.module});
  final HomeModule module;
  @override
  Widget build(BuildContext context) => ScreenContainer(
    showBack: true,
    child: HeaderCard(title: module.title, image: module.image),
  );
}
