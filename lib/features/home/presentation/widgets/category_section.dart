// lib/pages/widgets/category_section.dart
import 'package:flutter/material.dart';
import '../../../../core/utils/color.dart';

import '../../../services/presentation/widgets/service_card.dart'; // Keep for IconHelper if static


class CategorySection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> services;
  final int startIndex;

  const CategorySection({
    Key? key,
    required this.title,
    required this.services,
    required this.startIndex,
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
        _ServicesGrid(services: services, startIndex: startIndex),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _ServicesGrid extends StatelessWidget {
  final List<Map<String, dynamic>> services;
  final int startIndex;

  const _ServicesGrid({
    Key? key,
    required this.services,
    required this.startIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140, // Reduced height for compact look
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: services.length,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4), // Aligned padding
        itemBuilder: (context, index) {
          final serviceData = services[index];
          
          return _CompactServiceCard(
            title: serviceData['title'] as String,
            iconKey: serviceData['icon'] as String,
            onTap: () {
              final route = serviceData['route'] as String?;
              if (route != null && route.isNotEmpty) {
                Navigator.of(context).pushNamed(route);
              }
            },
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 12),
      ),
    );
  }
}

class _CompactServiceCard extends StatelessWidget {
  final String title;
  final String iconKey;
  final VoidCallback onTap;

  const _CompactServiceCard({
    Key? key,
    required this.title,
    required this.iconKey,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110, // Compact width
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: IconHelper.getIcon(
                iconKey,
                size: 24, // Smaller icon
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
