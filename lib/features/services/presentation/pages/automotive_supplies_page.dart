import 'package:flutter/material.dart';
import 'package:the_pink_club2/core/presentation/widgets/clean_service_appbar.dart';
import 'package:the_pink_club2/core/utils/color.dart';
import '/l10n/app_localizations.dart';
import '../widgets/pink_card_grid.dart';

class AutomotiveSuppliesPage extends StatelessWidget {
  const AutomotiveSuppliesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CleanServiceAppBar(
        title: AppLocalizations.of(context)!.automotiveSupplies,
      ),
      body: PinkAnimatedCardsGrid(serviceType: 'automotive_supplies'),
    );
  }
}
