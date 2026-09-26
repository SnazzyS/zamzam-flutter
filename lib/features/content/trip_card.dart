import 'package:flutter/cupertino.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../core/ui/components.dart';
import '../../core/ui/dhivehi_text.dart';
import 'content_models.dart';

class TripCard extends StatelessWidget {
  const TripCard({super.key, required this.package, this.image});
  final TripPackage package;
  final Widget? image;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(color: AppTheme.shadow, blurRadius: 28, offset: Offset(0, 7)),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: ColoredBox(
        color: AppTheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            image ??
                RemoteImageBox(
                  package.imageUrl,
                  aspectRatio: 1.35,
                  naturalHeight: true,
                ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DvText(
                    package.title,
                    size: 22,
                    weight: FontWeight.w600,
                    maxLines: 2,
                    minScale: .82,
                  ),
                  if (package.price.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            package.price,
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.greenDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const DvText(
                          Dv.tripsPriceLabel,
                          size: 15,
                          color: AppTheme.greenDark,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class TripList extends StatelessWidget {
  const TripList({super.key, required this.packages});
  final List<TripPackage> packages;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < packages.length; i++) ...[
        if (i > 0) const SizedBox(height: 18),
        TripCard(package: packages[i]),
      ],
    ],
  );
}
