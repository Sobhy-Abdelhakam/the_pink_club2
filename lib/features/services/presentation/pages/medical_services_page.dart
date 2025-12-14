
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:the_pink_club2/core/presentation/widgets/clean_service_appbar.dart';
import 'package:the_pink_club2/core/utils/color.dart';
import 'package:the_pink_club2/l10n/app_localizations.dart';

class MedicalServices extends StatefulWidget {
  const MedicalServices({Key? key}) : super(key: key);

  @override
  _MedicalServicesState createState() => _MedicalServicesState();
}

class _MedicalServicesState extends State<MedicalServices>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _services = [];
  List<AnimationController> _controllers = [];
  List<Animation<double>> _opacity = [];
  List<Animation<double>> _scale = [];

  Locale? _lastLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final currentLocale = Localizations.localeOf(context);
    if (_lastLocale != currentLocale) {
      _lastLocale = currentLocale;
      final loc = AppLocalizations.of(context)!;

      /// Load actual localization strings
      _services = [
        {
          'title': loc.medicalDiscounts,
          'icon': FontAwesomeIcons.stethoscope,
          'route': '/medical_service_data',
        },
        {
          'title': loc.medicalNetwork,
          'icon': FontAwesomeIcons.mapLocation,
          'route': '/medical_network',
        },
      ];

      _initAnimations();
    }
  }

  void _initAnimations() {
    for (var c in _controllers) c.dispose();

    _controllers = List.generate(
      _services.length,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 350 + (i * 110)),
      ),
    );

    _scale =
        _controllers
            .map(
              (c) => Tween<double>(
                begin: 0.94,
                end: 1.0,
              ).animate(CurvedAnimation(curve: Curves.easeOutBack, parent: c)),
            )
            .toList();

    _opacity =
        _controllers
            .map(
              (c) => Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(curve: Curves.easeIn, parent: c)),
            )
            .toList();

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 110), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(loc),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, size) {
            final isWide = size.maxWidth > 600;

            return GridView.builder(
              itemCount: _services.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWide ? 2 : 1,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: isWide ? 1.4 : 1.35,
              ),
              itemBuilder: (_, i) => _buildAnimatedCard(i),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations loc) {
    return CleanServiceAppBar(
      title: loc.medicalServices,
    );
  }

  Widget _buildAnimatedCard(int index) {
    return AnimatedBuilder(
      animation: _controllers[index],
      builder: (_, child) {
        return Opacity(
          opacity: _opacity[index].value,
          child: Transform.scale(scale: _scale[index].value, child: child),
        );
      },
      child: _buildServiceCard(
        title: _services[index]['title'],
        icon: _services[index]['icon'],
        route: _services[index]['route'],
      ),
    );
  }

  /// Clean, minimal service card matching the new design system
  Widget _buildServiceCard({
    required String title,
    required IconData icon,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container with minimal color accent
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.primary, size: 32),
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            // View details indicator
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back,
                    size: 12,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'عرض',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
