// lib/pages/widgets/service_card.dart
import 'package:flutter/material.dart';
import 'package:the_pink_club2/utils/service_generator.dart';
import 'package:the_pink_club2/widget/color.dart';

class ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final AnimationController? animationController;
  final int index;

  const ServiceCard({
    Key? key,
    required this.service,
    required this.animationController,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = parseColor(service['color'] ?? '#D31F75');
    final icon =
        (service['icon'] is IconData)
            ? service['icon'] as IconData
            : iconFromString(service['icon']?.toString() ?? '');

    final card = _buildCard(context, color, icon);

    if (animationController == null) return card;

    return AnimatedBuilder(
      animation: animationController!,
      builder: (context, child) {
        final scale =
            Tween<double>(begin: 0.92, end: 1.0)
                .animate(
                  CurvedAnimation(
                    parent: animationController!,
                    curve: Curves.elasticOut,
                  ),
                )
                .value;
        final opacity =
            Tween<double>(begin: 0.0, end: 1.0)
                .animate(
                  CurvedAnimation(
                    parent: animationController!,
                    curve: Curves.easeIn,
                  ),
                )
                .value;
        return Transform.scale(
          scale: scale,
          child: Opacity(opacity: opacity, child: child),
        );
      },
      child: card,
    );
  }

  Widget _buildCard(BuildContext context, Color color, IconData icon) {
    final title = service['title']?.toString() ?? '';
    final subtitle = service['subtitle']?.toString();
    final route = service['route']?.toString() ?? '';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (route.isNotEmpty) Navigator.pushNamed(context, route);
      },
      child: Container(
        width: 160,
        height: 130,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
            if (subtitle != null && subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
