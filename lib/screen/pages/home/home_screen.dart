import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:the_pink_club2/main.dart';
import 'package:the_pink_club2/screen/pages/home/ads_banner.dart';
import 'package:the_pink_club2/screen/pages/home/widgets/category_section.dart';
import 'package:the_pink_club2/utils/service_generator.dart';
import 'package:the_pink_club2/widget/color.dart';
import '/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  List<Map<String, dynamic>> _allServices = [];
  late Map<String, List<Map<String, dynamic>>> _categorizedServices;
  Locale? _lastLocale;
  late List<String> _categories;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final t = AppLocalizations.of(context)!;

    _categories = [
      t.roadsideAssistance,
      t.medicalDiscounts,
      t.automotiveSupplies,
      t.homecareServices,
      t.healthAndBeauty,
      t.conciergeServices,
      t.entertainmentLeisure,
      t.fashion,
      t.restaurants,
    ];

    final locale = Localizations.localeOf(context);
    if (_lastLocale != locale) {
      _lastLocale = locale;

      final loc = AppLocalizations.of(context)!;
      _categorizedServices = generateCategorizedServices(loc);
      _flattenServices();
      _setupAnimations();
    }
  }

  void _flattenServices() {
    _allServices = [];
    _categorizedServices.forEach((_, list) => _allServices.addAll(list));
  }

  void _setupAnimations() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();

    for (int i = 0; i < _allServices.length; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 520 + (i * 80)),
      );
      _controllers.add(controller);

      Future.delayed(Duration(milliseconds: i * 120), () {
        if (mounted) controller.forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    /// NEW category keys in correct order:
    const categoryKeys = [
      'roadsideAssistance',
      'medicalDiscounts',
      'automotiveSupplies',
      'homecareServices',
      'healthAndBeauty',
      'conciergeServices',
      'entertainmentLeisure',
      'fashion',
      'restaurants',
    ];

    final Map<String, int> startIndexes = {};
    int acc = 0;

    for (final key in categoryKeys) {
      startIndexes[key] = acc;
      acc += _categorizedServices[key]?.length ?? 0;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(loc),
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const AdsBanner(
                height: 240,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 4),
                borderRadius: 0,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    /// Chips
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (_, i) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _categories[i],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// SECTION BUILDER
                    for (int i = 0; i < categoryKeys.length; i++)
                      CategorySection(
                        key: ValueKey(categoryKeys[i]),
                        title: _categories[i],
                        icon: _pickIconForCategory(categoryKeys[i]),
                        services: _categorizedServices[categoryKeys[i]] ?? [],
                        startIndex: startIndexes[categoryKeys[i]]!,
                        controllers: _controllers,
                      ),

                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Best practice: choose icons based on each category
  IconData _pickIconForCategory(String key) {
    switch (key) {
      case 'roadsideAssistance':
        return FontAwesomeIcons.carBurst;
      case 'medicalDiscounts':
        return FontAwesomeIcons.stethoscope;
      case 'automotiveSupplies':
        return FontAwesomeIcons.wrench;
      case 'homecareServices':
        return FontAwesomeIcons.houseChimneyMedical;
      case 'healthAndBeauty':
        return FontAwesomeIcons.spa;
      case 'conciergeServices':
        return FontAwesomeIcons.bellConcierge;
      case 'entertainmentLeisure':
        return FontAwesomeIcons.play;
      case 'fashion':
        return FontAwesomeIcons.shirt;
      case 'restaurants':
        return FontAwesomeIcons.utensils;
      default:
        return FontAwesomeIcons.circleInfo;
    }
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations loc) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.primary,
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    loc.appName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    loc.enjoyExclusive,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: GestureDetector(
            onTap: () {
              MyApp.setLocale(
                context,
                isArabic ? const Locale('en') : const Locale('ar'),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.language, color: AppColors.textPrimary, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'EN',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
