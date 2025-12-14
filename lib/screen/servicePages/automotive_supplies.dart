import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import '/widget/color.dart';
import '/widget/pink_card_grid.dart';
import '/widget/clean_service_appbar.dart';

class AutomotiveSuppliesPage extends StatelessWidget {
  const AutomotiveSuppliesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CleanServiceAppBar(
        title: AppLocalizations.of(context)!.automotiveSupplies,
      ),
      body: const PinkAnimatedCardsGrid(serviceType: 'automotive_supplies'),
    );
  }
}
