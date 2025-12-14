import 'package:flutter/material.dart';
import 'package:the_pink_club2/core/presentation/widgets/animated_background.dart';
import 'package:the_pink_club2/core/utils/color.dart';
import 'package:the_pink_club2/l10n/app_localizations.dart';
import '../widgets/pink_card_grid.dart';

class AdvisoryServicesPage extends StatelessWidget {
  const AdvisoryServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
         appBar: PreferredSize(
  preferredSize: const Size.fromHeight(kToolbarHeight),
  child: Container(
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color:Color(0xFFd31f75), 
          width: 3.0,        
        ),
      ),
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(25),
      ),
    ),
    child: AppBar(
      iconTheme: const IconThemeData(color: Color(0xFFd31f75)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      title:  Text(
        AppLocalizations.of(context)!.advisoryServices,
        style: TextStyle(
          color: Color(0xFFd31f75),
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      centerTitle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(25),
          ),
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary,
              blurRadius: 20,
              spreadRadius: 5,
            )
          ],
        ),
      ),
    ),
  ),
),

    body: const Stack(
    children: [
    AnimatedBackground(),
    PinkAnimatedCardsGrid(serviceType: 'advisory'),
    ],
    ),
    );
  }
}