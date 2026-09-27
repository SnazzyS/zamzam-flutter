import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../core/ui/components.dart';
import '../../core/ui/dhivehi_text.dart';
import 'content_models.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.service,
    required this.width,
    required this.height,
    this.image,
  });
  final ServiceItem service;
  final double width, height;
  final Widget? image;
  static double cardHeight(
    BuildContext context,
    double width, {
    ServiceItem? service,
  }) {
    final base = math.min(width * 1.16, 430.0);
    if (service == null) return base;
    final appScale = FontScaleScope.of(context);
    double measure(String text, double size, int lines) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: AppTheme.dhivehi(size * appScale)),
        textDirection: TextDirection.rtl,
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: lines,
        ellipsis: '…',
      )..layout(maxWidth: width - 42);
      final result =
          painter.height +
          (size == 15
              ? 4 *
                    (painter.computeLineMetrics().length - 1).clamp(
                      0,
                      lines - 1,
                    )
              : 0);
      painter.dispose();
      return result;
    }

    final titleHeight = measure(service.title, 25, 2);
    final descriptionHeight = measure(
      service.description.isEmpty
          ? Dv.servicesDescriptionFallback
          : service.description,
      15,
      4,
    );
    return math.max(
      base,
      14 + base * .54 + 16 + titleHeight + 8 + descriptionHeight + 2,
    );
  }

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        width: width,
        height: math.max(height, cardHeight(context, width, service: service)),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.divider.withValues(alpha: .72)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x21000000),
              blurRadius: 48,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: width - 28,
                  height: math.min(width * 1.16, 430) * .54,
                  child: ColoredBox(
                    color: AppTheme.surfaceVariant,
                    child: Center(
                      child:
                          image ??
                          RemoteImageBox(service.imageUrl, aspectRatio: 1.24),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      DvText(
                        service.title,
                        size: 25,
                        weight: FontWeight.w600,
                        maxLines: 2,
                        minScale: .76,
                        widthBasis: TextWidthBasis.longestLine,
                      ),
                      const SizedBox(height: 8),
                      DvText(
                        service.description.isEmpty
                            ? Dv.servicesDescriptionFallback
                            : service.description,
                        size: 15,
                        color: AppTheme.secondary,
                        maxLines: 4,
                        align: TextAlign.left,
                        widthBasis: TextWidthBasis.longestLine,
                        lineSpacing: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
