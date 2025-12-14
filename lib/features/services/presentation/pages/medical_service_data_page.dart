import 'package:flutter/material.dart';
import 'package:the_pink_club2/core/presentation/widgets/animated_background.dart';
import 'package:the_pink_club2/core/utils/color.dart';
import 'package:the_pink_club2/l10n/app_localizations.dart';
import '../widgets/pink_card_grid.dart';

class MedicalServiceData extends StatelessWidget {
  const MedicalServiceData({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(AppLocalizations.of(context)!),
      body: const Stack(
        children: [
          AnimatedBackground(),
          PinkAnimatedCardsGrid(serviceType: 'medical_service'),
        ],
      ),
    );
  }
  PreferredSizeWidget _buildAppBar(AppLocalizations loc) {
    return AppBar(
      title: Text(
        loc.medicalServices,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      backgroundColor: AppColors.primary,
      elevation: 3,
      centerTitle: true,
    );
  }
}
