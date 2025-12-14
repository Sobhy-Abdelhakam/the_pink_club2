import 'package:flutter/material.dart';
import '../Services/data_service.dart';
import '../screen/servicePages/service_details_page.dart';
import 'color.dart';
import 'service_card.dart';
import '/l10n/app_localizations.dart';

class PinkAnimatedCardsGrid extends StatefulWidget {
  final String serviceType;
  const PinkAnimatedCardsGrid({super.key, this.serviceType = 'car'});

  @override
  State<PinkAnimatedCardsGrid> createState() => _PinkAnimatedCardsGridState();
}

class _PinkAnimatedCardsGridState extends State<PinkAnimatedCardsGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int? _hoveredIndex;
  final Duration _animationDuration = const Duration(milliseconds: 400);
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _didLoad = false;
  Locale? _lastLocale;

  static const List<Color> _pinkPalette = [AppColors.primary];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newLocale = Localizations.localeOf(context);
    if (!_didLoad || newLocale != _lastLocale) {
      _lastLocale = newLocale;
      _loadServices();
      _didLoad = true;
    }
  }

  Future<void> _loadServices() async {
    try {
      debugPrint(
        'Loading services in language: ${Localizations.localeOf(context).languageCode}',
      );

      List<Map<String, dynamic>> services;
      switch (widget.serviceType) {
        case 'advisory':
          services = await SecureApiService.getAdvisoryServices(context);
          break;
        case 'license':
          services = await SecureApiService.getLicenseServices(context);
          break;
        case 'medical':
          services = await SecureApiService.getMedicalAdvisory(context);
          break;
        case 'medical_service':
          services = await SecureApiService.getMedicalServices(context);
          break;
        case 'more':
          services = await SecureApiService.getMoreServices(context);
          break;
        case 'automotive_supplies':
          services = await SecureApiService.getAutomotiveSupplies(context);
          break;
        case 'second_medical_opinion':
          services = await SecureApiService.getSecondMedicalOpinion(context);
          break;
        case 'car':
        default:
          services = await SecureApiService.getServices(context);
          break;
      }

      debugPrint('Received ${services.length} services');
      if (services.isNotEmpty) {
        debugPrint('First service title: ${services[0]['title']}');
      }

      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading services: $e');
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.failedToLoadServices;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color primaryPink =
        isDarkMode ? const Color(0xFFE91E63) : const Color(0xFFC2185B);

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
            const SizedBox(height: 20),
            Text(
              'Loading...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppColors.error.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadServices();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_services.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                localizations.noServicesAvailable,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                localizations.newServicesComingSoon,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive values based on screen size
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Adaptive padding based on screen size
        final horizontalPadding = screenWidth > 600 ? 24.0 : 16.0;
        final topPadding = screenHeight > 800 ? 20.0 : 10.0;
        final bottomPadding = 16.0;

        // Adaptive grid settings based on content amount and screen size
        final crossAxisCount = screenWidth > 600 ? 2 : 1;
        final crossAxisSpacing = screenWidth > 600 ? 20.0 : 16.0;
        final mainAxisSpacing = screenWidth > 600 ? 20.0 : 16.0;

        // Dynamic childAspectRatio based on content amount
        final avgDescriptionLength =
            _services.fold<int>(0, (sum, service) {
              final desc = service['description']?.toString() ?? '';
              return sum + desc.length;
            }) /
            _services.length;

        // Adjust aspect ratio based on content length - 50% of original height
        double childAspectRatio;
        if (avgDescriptionLength > 200) {
          childAspectRatio =
              screenWidth > 600
                  ? 1.70 // doubled from 0.85
                  : 1.30; // doubled from 0.65
        } else if (avgDescriptionLength > 100) {
          childAspectRatio = screenWidth > 600 ? 1.90 : 1.50; // doubled
        } else {
          childAspectRatio = screenWidth > 600 ? 2.10 : 1.70; // doubled
        }
        // Ensure minimum and maximum aspect ratios to prevent extreme sizes
        childAspectRatio = childAspectRatio.clamp(1.2, 2.4);
        return Padding(
          padding: EdgeInsets.only(
            top: topPadding,
            left: horizontalPadding,
            right: horizontalPadding,
            bottom: bottomPadding,
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: _services.length,
            itemBuilder: (context, index) {
              final service = _services[index];
              final bool isHovered = _hoveredIndex == index;

              Color cardColor;
              try {
                final colorString = service['color'];
                if (colorString != null &&
                    colorString.toString().startsWith('#')) {
                  cardColor = Color(
                    int.parse(colorString.toString().substring(1), radix: 16) +
                        0xFF000000,
                  );
                } else {
                  cardColor = _pinkPalette[index % _pinkPalette.length];
                }
              } catch (e) {
                cardColor = _pinkPalette[index % _pinkPalette.length];
              }

              return MouseRegion(
                onEnter: (_) => setState(() => _hoveredIndex = index),
                onExit: (_) => setState(() => _hoveredIndex = null),
                child: AnimatedContainer(
                  duration: _animationDuration,
                  curve: Curves.easeInOutQuint,
                  transform:
                      Matrix4.identity()
                        ..scale(isHovered ? 1.05 : 1.0)
                        ..translate(
                          0.0,
                          isHovered ? -10.0 : 0.0,
                          isHovered ? 20.0 : 0.0,
                        ),
                  child: ServiceCard(
                    service: service,
                    cardColor: cardColor,
                    primaryPink: primaryPink,
                    isHovered: isHovered,
                    onTap:
                        () => _navigateToServiceDetails(
                          context,
                          service,
                          cardColor,
                        ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _navigateToServiceDetails(
    BuildContext context,
    Map<String, dynamic> service,
    Color color,
  ) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                ServiceDetailsPage(service: service, color: color),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}
