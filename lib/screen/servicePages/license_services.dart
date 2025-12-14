import 'package:flutter/material.dart';
import 'package:the_pink_club2/l10n/app_localizations.dart';
import '../../widget/color.dart';
import '../../widget/pink_card_grid.dart';
import '../../widget/clean_service_appbar.dart';

class LicenseServicesPage extends StatelessWidget {
  const LicenseServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CleanServiceAppBar(
        title: AppLocalizations.of(context)!.licenseAssistance,
      ),
      body: const PinkAnimatedCardsGrid(serviceType: 'license'),
    );
  }
}