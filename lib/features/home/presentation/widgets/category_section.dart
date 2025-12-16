// lib/pages/widgets/category_section.dart
import 'package:flutter/material.dart';
import '../../../../core/utils/color.dart';

import '../../../services/presentation/widgets/service_card.dart'; // Keep for IconHelper if static

class CategorySection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> services;
  final int startIndex;
  final bool itemsClickable;

  const CategorySection({
    Key? key,
    required this.title,
    required this.services,
    required this.startIndex,
    this.itemsClickable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 16,
            top: 12,
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ),
        _ServicesGrid(
          services: services,
          startIndex: startIndex,
          itemsClickable: itemsClickable,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _ServicesGrid extends StatelessWidget {
  final List<Map<String, dynamic>> services;
  final int startIndex;
  final bool itemsClickable;

  const _ServicesGrid({
    Key? key,
    required this.services,
    required this.startIndex,
    required this.itemsClickable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 165, // Increased height for larger cards
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: services.length,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ), // More vertical padding for shadows
        itemBuilder: (context, index) {
          final serviceData = services[index];

          return _ServiceItemCard(
            title: serviceData['title'] as String,
            iconKey: serviceData['icon'] as String,
            imagePath: serviceData['image'] as String?,
            onTap: itemsClickable
                ? () {
                    final route = serviceData['route'] as String?;
                    if (route != null && route.isNotEmpty) {
                      Navigator.of(context).pushNamed(route);
                    }
                  }
                : null,
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 14),
      ),
    );
  }
}

class _ServiceItemCard extends StatelessWidget {
  final String title;
  final String iconKey;
  final String? imagePath;
  final VoidCallback? onTap; // Made nullable

  const _ServiceItemCard({
    Key? key,
    required this.title,
    required this.iconKey,
    this.imagePath,
    this.onTap, // Made optional
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 115, // Slightly wider
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20), // Softer corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          // Removed border for cleaner "professional" look, reliant on shadow elevation
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null)
              Expanded(
                flex: 3,
                 child: Container(
                   width: double.infinity,
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(15),
                     // No background for cleaner look if image fills
                   ),
                   child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                     child: Image.asset(
                       imagePath!,
                       fit: BoxFit.contain, // Contain to show full image without cropping
                       errorBuilder: (context, error, stackTrace) => Icon(
                         Icons.broken_image,
                         color: Colors.grey.shade300,
                       ),
                     ),
                   ),
                 ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: IconHelper.getIcon(
                  iconKey,
                  size: 28, // Increased size
                  color: AppColors.primary,
                ),
              ),
            const SizedBox(height: 10),
            Flexible(
              flex: 2,
              child: Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.2,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
