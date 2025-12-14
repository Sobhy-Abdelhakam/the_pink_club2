import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/l10n/app_localizations.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'color.dart';
import 'hero_tag_manager.dart';

class ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
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
    final String heroTag = HeroTagManager.generateServiceCardTag(service);

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
                    // ICON with service color accent - Enhanced (Fixed at top)
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
                              service['icon'],
                              size: 30,
                              color: cardColor,
                              imageUrl: service['image'],
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

                    // TITLE - Enhanced (Fixed at top)
                    Text(
                      service['title'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: AppColors.textPrimary,
                        height: 1.3,
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Scrollable content area
                    Expanded(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          scrollbarTheme: ScrollbarThemeData(
                            thickness: MaterialStateProperty.all(6),
                            radius: const Radius.circular(10),
                            thumbColor: MaterialStateProperty.all(
                              cardColor.withOpacity(0.7),
                            ),
                            minThumbLength: 50,
                          ),
                        ),
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // DESCRIPTION - scrollable with better styling
                                if (service['description'] != null &&
                                    service['description']
                                        .toString()
                                        .trim()
                                        .isNotEmpty)
                                  Text(
                                    service['description'],
                                    style: TextStyle(
                                      color: AppColors.textSecondary
                                          .withOpacity(0.85),
                                      fontSize: 13.5,
                                      height: 1.5,
                                      letterSpacing: 0.1,
                                    ),
                                  ),

                                const SizedBox(height: 14),

                                // VIEW DETAILS indicator - Always at bottom of scrollable content
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient:
                                        isHovered
                                            ? LinearGradient(
                                              colors: [
                                                cardColor.withOpacity(0.15),
                                                cardColor.withOpacity(0.08),
                                              ],
                                            )
                                            : null,
                                    color:
                                        isHovered
                                            ? null
                                            : cardColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(14),
                                    border:
                                        isHovered
                                            ? Border.all(
                                              color: cardColor.withOpacity(0.3),
                                              width: 1,
                                            )
                                            : null,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.more,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: cardColor,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      AnimatedRotation(
                                        turns: isHovered ? 0.5 : 0,
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward,
                                          size: 14,
                                          color: cardColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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

// --------------------------------------------------
// BOTTOM SHEET — Simplified & Clean
// --------------------------------------------------

// --------------------------------------------------
// ICON HELPER (unchanged, clean)
// --------------------------------------------------

class IconHelper {
  static final Map<String, IconData> iconMap = {
    'screwdriverWrench': FontAwesomeIcons.screwdriverWrench,
    'houseChimney': FontAwesomeIcons.houseChimney,
    'fileInvoice': FontAwesomeIcons.fileInvoice,
    'comments': FontAwesomeIcons.comments,
    'oil-can': FontAwesomeIcons.oilCan,
    'tire': FontAwesomeIcons.circle,
    'battery-three-quarters': FontAwesomeIcons.batteryThreeQuarters,
    'car-crash': FontAwesomeIcons.carCrash,
    'filter': FontAwesomeIcons.filter,
    'directions-car': FontAwesomeIcons.car,
    'local-gas-station': FontAwesomeIcons.gasPump,
    'lock-open': FontAwesomeIcons.lockOpen,
    'user-doctor': FontAwesomeIcons.userDoctor,
    'home': FontAwesomeIcons.house,
    'heart-pulse': FontAwesomeIcons.heartPulse,
    'stethoscope': FontAwesomeIcons.stethoscope,
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
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }
    return Icon(Icons.help_outline, size: size, color: color);
  }
}
