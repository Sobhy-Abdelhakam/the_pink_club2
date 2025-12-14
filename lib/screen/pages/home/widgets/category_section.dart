// lib/pages/widgets/category_section.dart
import 'package:flutter/material.dart';
import 'package:the_pink_club2/widget/color.dart';

import 'service_card.dart';

class CategorySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Map<String, dynamic>> services;
  final int startIndex;
  final List<AnimationController> controllers;

  const CategorySection({
    Key? key,
    required this.title,
    required this.icon,
    required this.services,
    required this.startIndex,
    required this.controllers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16, top: 12),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        _ServicesGrid(
          services: services,
          controllers: controllers,
          startIndex: startIndex,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _ServicesGrid extends StatelessWidget {
  final List<Map<String, dynamic>> services;
  final List<AnimationController> controllers;
  final int startIndex;

  const _ServicesGrid({
    Key? key,
    required this.services,
    required this.controllers,
    required this.startIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: services.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final globalIndex = startIndex + index;
          final controller =
              globalIndex < controllers.length
                  ? controllers[globalIndex]
                  : null;
          return ServiceCard(
            service: services[index],
            animationController: controller,
            index: globalIndex,
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 20),
      ),
    );
  }
}
