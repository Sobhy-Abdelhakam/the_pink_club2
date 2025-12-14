import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_pink_club2/features/services/domain/entities/service_entity.dart';
import '/l10n/app_localizations.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/utils/color.dart';

class ServiceCard extends StatelessWidget {
  final ServiceEntity service;
  final Color cardColor;
  final Color primaryPink;
  final bool isHovered;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.service,
    required this.cardColor,
    required this.primaryPink,
    required this.isHovered,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Generate simple hero tag
    final String heroTag = 'service_card_${service.id}';

    return Hero(
      tag: heroTag,
      child: AnimatedScale(
        scale: isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color:
                    isHovered
                        ? cardColor.withOpacity(0.3)
                        : Colors.grey.shade200,
                width: isHovered ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      isHovered
                          ? cardColor.withOpacity(0.15)
                          : Colors.black.withOpacity(0.04),
                  blurRadius: isHovered ? 16 : 8,
                  offset: Offset(0, isHovered ? 6 : 2),
                  spreadRadius: isHovered ? 2 : 0,
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ICON with service color accent
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                cardColor.withOpacity(0.15),
                                cardColor.withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow:
                                isHovered
                                    ? [
                                      BoxShadow(
                                        color: cardColor.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                    : null,
                          ),
                          child: Center(
                            child: IconHelper.getIcon(
                              service.icon,
                              size: 30,
                              color: cardColor,
                            ),
                          ),
                        ),
                        AnimatedRotation(
                          turns: isHovered ? 0.25 : 0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: isHovered ? cardColor : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // TITLE
                    Text(
                      service.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16, // Slightly smaller
                        color: AppColors.textPrimary,
                        height: 1.3,
                        letterSpacing: -0.3,
                      ),
                    ),

                    const Spacer(), // Push content up

                    // DESCRIPTION (Truncated)
                    if (service.description.isNotEmpty)
                      Text(
                        service.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.85),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    
                    if (service.description.isEmpty) const Spacer(), // Balance if no desc

                    const SizedBox(height: 12),

                    // VIEW DETAILS indicator
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, // Compact
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isHovered
                              ? cardColor.withOpacity(0.1)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isHovered
                                ? cardColor.withOpacity(0.3)
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.more,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: isHovered ? cardColor : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: isHovered ? cardColor : AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class IconHelper {
  static final Map<String, IconData> iconMap = {
    'screwdriverWrench': FontAwesomeIcons.screwdriverWrench,
    'houseChimney': FontAwesomeIcons.houseChimney,
    'fileInvoice': FontAwesomeIcons.fileInvoice,
    'comments': FontAwesomeIcons.comments,
    'oil-can': FontAwesomeIcons.oilCan,
    'tire': FontAwesomeIcons.circle,
    'battery-three-quarters': FontAwesomeIcons.batteryThreeQuarters,
    'car-crash': FontAwesomeIcons.carBurst,
    'filter': FontAwesomeIcons.filter,
    'directions-car': FontAwesomeIcons.car,
    'local-gas-station': FontAwesomeIcons.gasPump,
    'lock-open': FontAwesomeIcons.lockOpen,
    'user-doctor': FontAwesomeIcons.userDoctor,
    'home': FontAwesomeIcons.house,
    'heart-pulse': FontAwesomeIcons.heartPulse,
    'stethoscope': FontAwesomeIcons.stethoscope,
    'id-card': FontAwesomeIcons.idCard,
    'concierge': FontAwesomeIcons.bellConcierge,
    'more': FontAwesomeIcons.ellipsis,
  };

  static Widget getIcon(
    String? iconName, {
    double size = 30,
    Color color = Colors.white,
    String? imageUrl,
  }) {
    final icon = iconMap[iconName];
    if (icon != null) {
      return Icon(icon, size: size, color: color);
    }
    // Handle image url if needed, but current ServiceEntity logic prefers font icons
    // For now we default to unknown if not mapped.
    return Icon(Icons.help_outline, size: size, color: color);
  }
}
