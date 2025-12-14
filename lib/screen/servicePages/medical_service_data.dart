import 'package:flutter/material.dart';
import 'package:the_pink_club2/l10n/app_localizations.dart';
import '../../widget/animated_background.dart';
import '../../widget/color.dart';
import '../../widget/pink_card_grid.dart';

class MedicalServiceData extends StatelessWidget {
  const MedicalServiceData({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(AppLocalizations.of(context)!),
      //       appBar: PreferredSize(
      //   preferredSize: const Size.fromHeight(kToolbarHeight),
      //   child: Container(
      //     decoration: BoxDecoration(
      //       border: Border(
      //         bottom: BorderSide(
      //           color:Color(0xFFd31f75),
      //           width: 3.0,
      //         ),
      //       ),
      //       borderRadius: const BorderRadius.vertical(
      //         bottom: Radius.circular(25),
      //       ),
      //     ),
      //     child: AppBar(
      //       iconTheme: const IconThemeData(color: Color(0xFFd31f75)),
      //       backgroundColor: Colors.transparent,
      //       elevation: 0,
      //       title: const Text(
      //         'The Pink Club',
      //         style: TextStyle(
      //           color: Color(0xFFd31f75),
      //           fontWeight: FontWeight.bold,
      //           fontSize: 24,
      //         ),
      //       ),
      //       centerTitle: true,
      //       shape: const RoundedRectangleBorder(
      //         borderRadius: BorderRadius.vertical(
      //           bottom: Radius.circular(30),
      //         ),
      //       ),
      //       flexibleSpace: Container(
      //         decoration: BoxDecoration(
      //           borderRadius: const BorderRadius.vertical(
      //             bottom: Radius.circular(25),
      //           ),
      //           gradient: LinearGradient(
      //             colors: [
      //               AppColors.primary,
      //               AppColors.primary,
      //             ],
      //             begin: Alignment.topLeft,
      //             end: Alignment.bottomRight,
      //           ),
      //           boxShadow: [
      //             BoxShadow(
      //               color: AppColors.primary,
      //               blurRadius: 20,
      //               spreadRadius: 5,
      //             )
      //           ],
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
      body: const Stack(
        children: const [
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
