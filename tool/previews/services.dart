// Run with flutter run -t tool/previews/services.dart for a controlled review.
import 'package:flutter/cupertino.dart';
import 'package:zamzam_flutter/app/glass_tab_bar.dart';
import 'package:zamzam_flutter/app/router.dart';
import 'package:zamzam_flutter/core/strings.dart';
import 'package:zamzam_flutter/core/ui/components.dart';
import 'package:zamzam_flutter/features/content/content_models.dart';
import 'package:zamzam_flutter/features/content/service_pager.dart';
import 'package:zamzam_flutter/main.dart';

void main() => runApp(
  ZamzamApp(
    router: createRouter(
      roots: {
        RootTab.home: (context) => ScreenContainer(
          showBack: true,
          child: Column(
            children: [
              const HeaderCard(title: Dv.servicesTitle, image: 'services'),
              const SizedBox(height: 22),
              ServicePager(
                services: List.generate(
                  5,
                  (_) => ServiceItem(
                    title: 'ޢުމްރާ ޕެކޭޖު',
                    description:
                        'ޢުމްރާގެ މަތިވެރި އަޅުކަން ފަސޭހަކަމާއެކު ފުރިހަމަކުރުމަށްޓަކައި އެކުލަވާލެވިފައިވާ ޚާއްޞަ ޕެކޭޖް',
                    imageUrl: Uri.parse(
                      'https://fls-a259740c-61ab-439c-a4ba-6b92118ab6ae.laravel.cloud/website/services/service-6a68cfcfcaf1d.jpg',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      },
    ),
  ),
);
