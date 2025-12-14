import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_pink_club2/screen/Medical/medical_network.dart';
import 'package:the_pink_club2/screen/pages/about_us/about_screen.dart';
import 'package:the_pink_club2/screen/servicePages/advisory_services.dart';
import 'package:the_pink_club2/screen/servicePages/car_service.dart';
import 'package:the_pink_club2/screen/servicePages/concierge.dart';
import 'package:the_pink_club2/screen/pages/contact/contact_us_page.dart';
import 'package:the_pink_club2/screen/servicePages/license_services.dart';
import 'package:the_pink_club2/screen/servicePages/medical_advisory.dart';
import 'package:the_pink_club2/screen/servicePages/medical_service_data.dart';
import 'package:the_pink_club2/screen/servicePages/medical_services.dart';
import 'package:the_pink_club2/screen/servicePages/more_services.dart';
import 'package:the_pink_club2/screen/pages/subscription/subscriptions_page.dart';
import 'package:the_pink_club2/screen/servicePages/automotive_supplies.dart';
import 'package:the_pink_club2/screen/servicePages/second_medical_opinion.dart';
import 'package:the_pink_club2/screen/splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:the_pink_club2/widget/color.dart';
import '/l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    final _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('ar');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 780),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          locale: _locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('ar')],
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
              onPrimary: Colors.white,
              secondary: AppColors.secondary,
              onSecondary: Colors.white,
              surface: AppColors.card,
              onSurface: AppColors.textPrimary,
              background: AppColors.background,
              onBackground: AppColors.textPrimary,
              error: AppColors.error,
              onError: Colors.white,
            ),
            scaffoldBackgroundColor: AppColors.background,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            textTheme: ThemeData.light().textTheme.apply(
              bodyColor: AppColors.textPrimary,
              displayColor: AppColors.textPrimary,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
              titleTextStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: 0.2,
              ),
              iconTheme: IconThemeData(color: AppColors.textPrimary),
            ),
            cardTheme: CardThemeData(
              color: AppColors.card,
              elevation: 10,
              shadowColor: AppColors.shadow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.6,
                ),
              ),
            ),
            scrollbarTheme: ScrollbarThemeData(
              thickness: MaterialStateProperty.all(6),
              radius: const Radius.circular(10),
              thumbColor: MaterialStateProperty.all(
                AppColors.primary.withOpacity(0.6),
              ),
              minThumbLength: 50,
            ),
            // elevatedButtonTheme: ElevatedButtonThemeData(
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: AppColors.primary,
            //     foregroundColor: Colors.white,
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 24,
            //       vertical: 14,
            //     ),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(24),
            //     ),
            //   ),
            // ),
            // iconTheme: const IconThemeData(color: AppColors.primary),
            // progressIndicatorTheme: const ProgressIndicatorThemeData(
            //   color: AppColors.primary,
            // ),
          ),
          debugShowCheckedModeBanner: false,
          routes: {
            '/car_services': (context) => const CarServicePage(),
            '/medical_services': (context) => const MedicalServices(),
            '/about_us': (context) => const AboutUsPage(),
            '/subscriptions': (context) => const SubscriptionsPage(),
            '/contact_us': (context) => const ContactUsPage(),
            '/concierge': (context) => const ConciergeServicesPage(),
            '/advisory': (context) => const AdvisoryServicesPage(),
            '/license': (context) => const LicenseServicesPage(),
            '/medical_advisory': (context) => const MedicalAdvisory(),
            '/medical_service_data': (context) => const MedicalServiceData(),
            '/medical_network': (context) => const Main2(),
            '/more': (context) => const MoreServices(),
            '/automotive_supplies': (context) => const AutomotiveSuppliesPage(),
            '/second_medical_opinion':
                (context) => const SecondMedicalOpinionPage(),
          },
          home: const SplashScreen(),
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            // تحقق من لغة الجهاز وإذا كانت مدعومة
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == deviceLocale?.languageCode) {
                return supportedLocale;
              }
            }
            // إذا لم تكن لغة الجهاز مدعومة، نعود للغة الافتراضية (العربية)
            return const Locale('ar');
          },
        );
      },
    );
  }
}
