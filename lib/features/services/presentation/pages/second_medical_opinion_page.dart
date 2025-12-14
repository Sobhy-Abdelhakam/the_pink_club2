import 'package:flutter/material.dart';
import 'package:the_pink_club2/core/presentation/widgets/clean_service_appbar.dart';
import 'package:the_pink_club2/core/utils/color.dart';
import '/l10n/app_localizations.dart';
import '../widgets/pink_card_grid.dart';

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
      body: PinkAnimatedCardsGrid(serviceType: 'second_medical_opinion'),
    );
  }
}
