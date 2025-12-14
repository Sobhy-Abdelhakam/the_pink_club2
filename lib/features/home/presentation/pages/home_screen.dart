import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:the_pink_club2/main.dart';
import '../widgets/ads_banner.dart';
import '../widgets/category_section.dart';
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
      backgroundColor: const Color(
        0xFFFAFAFA,
      ), // Slightly off-white for premium feel
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(loc),
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
                  SizedBox(
                    height: 48, // Taller touch target
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _categories.length,
                      itemBuilder: (_, i) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _categories[i],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// SECTION BUILDER
                  for (int i = 0; i < categoryKeys.length; i++)
                    CategorySection(
                      key: ValueKey(categoryKeys[i]),
                      title: _categories[i],
                      services: _categorizedServices[categoryKeys[i]] ?? [],
                      startIndex: startIndexes[categoryKeys[i]]!,
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

  Widget _buildSliverAppBar(AppLocalizations loc) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return SliverAppBar(
      backgroundColor: const Color(0xFFFAFAFA),
      floating: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(
                'assets/images/logo_placeholder.png',
              ), // Use asset if available or icon
              backgroundColor: AppColors.primary,
              child: Icon(FontAwesomeIcons.user, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${loc.hello}, User!', // Placeholder for username
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  loc.enjoyExclusive,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 20),
          child: GestureDetector(
            onTap: () {
              MyApp.setLocale(
                context,
                isArabic ? const Locale('en') : const Locale('ar'),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    isArabic ? 'EN' : 'AR',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.language,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
