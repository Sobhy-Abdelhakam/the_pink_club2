// lib/pages/widgets/header_section.dart
import 'package:flutter/material.dart';
import 'package:the_pink_club2/l10n/app_localizations.dart';
import 'package:the_pink_club2/widget/color.dart';

class HeaderSection extends StatelessWidget {
  final AppLocalizations localizations;
  const HeaderSection({Key? key, required this.localizations}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${localizations.hello} 🌸', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: 0.2)),
        const SizedBox(height: 4),
        Text(localizations.choosePackage, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.4)),
      ],
    );
  }
}
