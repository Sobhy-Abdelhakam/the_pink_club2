import 'package:flutter/material.dart';
import '../widgets/ads_banner.dart';
import '../widgets/category_section.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/category_chips_list.dart';
import 'package:the_pink_club2/core/utils/service_generator.dart';
import 'package:the_pink_club2/core/utils/color.dart';
import 'package:the_pink_club2/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    }
  }

  static const _categoryKeys = [
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final Map<String, int> startIndexes = {};
    int acc = 0;

    for (final key in _categoryKeys) {
      startIndexes[key] = acc;
      acc += _categorizedServices[key]?.length ?? 0;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(
        0xFFFAFAFA,
      ), // Slightly off-white for premium feel
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const HomeAppBar(),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const AdsBanner(
                    height: 180, // Sleeker height
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 4),
                    borderRadius: 20,
                    fit: BoxFit.fill,
                  ),
                  const SizedBox(height: 24),

                  /// Categories Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      loc.categories, // Ensure generic fallback if key missing
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// Chips
                  CategoryChipsList(categories: _categories),

                  const SizedBox(height: 24),

                  /// SECTION BUILDER
                  for (int i = 0; i < _categoryKeys.length; i++)
                    CategorySection(
                      key: ValueKey(_categoryKeys[i]),
                      title: _categories[i],
                      services: _categorizedServices[_categoryKeys[i]] ?? [],
                      startIndex: startIndexes[_categoryKeys[i]]!,
                      itemsClickable: _categoryKeys[i] != 'roadsideAssistance',
                    ),

                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
