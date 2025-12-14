import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import '/widget/color.dart';
import '/widget/pink_card_grid.dart';
import '/widget/clean_service_appbar.dart';

class SecondMedicalOpinionPage extends StatefulWidget {
  const SecondMedicalOpinionPage({Key? key}) : super(key: key);

  @override
  State<SecondMedicalOpinionPage> createState() =>
      _SecondMedicalOpinionPageState();
}

class _SecondMedicalOpinionPageState extends State<SecondMedicalOpinionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CleanServiceAppBar(
        title: AppLocalizations.of(context)!.secondMedicalOpinion,
      ),
      body: const PinkAnimatedCardsGrid(serviceType: 'second_medical_opinion'),
    );
  }
}
