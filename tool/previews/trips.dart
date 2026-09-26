// Run with flutter run -t tool/previews/trips.dart for a controlled layout review.
import 'package:flutter/cupertino.dart';
import 'package:zamzam_flutter/app/glass_tab_bar.dart';
import 'package:zamzam_flutter/app/router.dart';
import 'package:zamzam_flutter/core/strings.dart';
import 'package:zamzam_flutter/core/ui/components.dart';
import 'package:zamzam_flutter/features/content/content_models.dart';
import 'package:zamzam_flutter/features/content/trip_card.dart';
import 'package:zamzam_flutter/main.dart';

void main() => runApp(
  ZamzamApp(
    router: createRouter(
      roots: {
        RootTab.home: (_) => ScreenContainer(
          showBack: true,
          child: Column(
            children: [
              const HeaderCard(title: Dv.tripsTitle, image: 'trips'),
              const SizedBox(height: 22),
              TripList(
                packages: [
                  TripPackage(
                    title: 'ޑިސެންބަރު ޢުމްރާ',
                    price: '29,500',
                    imageUrl: Uri.parse(
                      'https://fls-a259740c-61ab-439c-a4ba-6b92118ab6ae.laravel.cloud/packages/package-6a6610be75316.jpg',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      },
    ),
  ),
);
