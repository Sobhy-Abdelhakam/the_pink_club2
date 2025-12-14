import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_pink_club2/core/di/injection_container.dart';
import 'package:the_pink_club2/features/services/domain/entities/service_entity.dart';
import 'package:the_pink_club2/features/services/presentation/bloc/services_bloc.dart';
import 'package:the_pink_club2/features/services/presentation/bloc/services_event.dart';
import 'package:the_pink_club2/features/services/presentation/bloc/services_state.dart';
import '../pages/service_details_page.dart';
import '../../../../core/utils/color.dart';
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    // We use a unique key based on language and service type to force re-creation of the Bloc
    // or we can handle it inside the Bloc. Standard is to provide a new Bloc.
    return BlocProvider(
      create:
          (_) => sl<ServicesBloc>()..add(
            GetServicesEvent(type: widget.serviceType, lang: lang),
          ),
      child: BlocBuilder<ServicesBloc, ServicesState>(
        builder: (context, state) {
          if (state is ServicesLoading) {
            return _buildLoading();
          } else if (state is ServicesError) {
            return _buildError(context, state.message);
          } else if (state is ServicesLoaded) {
            return _buildContent(context, state.services);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
          const SizedBox(height: 20),
          Text(
            'Loading...',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
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
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final lang = Localizations.localeOf(context).languageCode;
                context.read<ServicesBloc>().add(
                  GetServicesEvent(type: widget.serviceType, lang: lang),
                );
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<ServiceEntity> services) {
    if (services.isEmpty) {
      return _buildEmptyState(context);
    }

    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color primaryPink = isDarkMode ? const Color(0xFFE91E63) : const Color(0xFFC2185B);

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        final horizontalPadding = screenWidth > 600 ? 24.0 : 16.0;
        final topPadding = screenHeight > 800 ? 20.0 : 10.0;
        final bottomPadding = 16.0;

        final crossAxisCount = screenWidth > 600 ? 2 : 1;
        final crossAxisSpacing = screenWidth > 600 ? 20.0 : 16.0;
        final mainAxisSpacing = screenWidth > 600 ? 20.0 : 16.0;

        final avgDescriptionLength =
            services.fold<int>(0, (sum, service) {
              return sum + service.description.length;
            }) /
            services.length;

        double childAspectRatio;
        if (avgDescriptionLength > 200) {
          childAspectRatio = screenWidth > 600 ? 1.70 : 1.30;
        } else if (avgDescriptionLength > 100) {
          childAspectRatio = screenWidth > 600 ? 1.90 : 1.50;
        } else {
          childAspectRatio = screenWidth > 600 ? 2.10 : 1.70;
        }
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
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              final bool isHovered = _hoveredIndex == index;

              Color cardColor;
              try {
                if (service.color.startsWith('#')) {
                  cardColor = Color(
                    int.parse(service.color.substring(1), radix: 16) + 0xFF000000,
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
                    onTap: () => _navigateToServiceDetails(context, service, cardColor),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
      final localizations = AppLocalizations.of(context)!;
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
                child: const Icon(
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
                style: const TextStyle(
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

  void _navigateToServiceDetails(
    BuildContext context,
    ServiceEntity service,
    Color color,
  ) {
    // We map ServiceEntity back to Map if ServiceDetailsPage requires Map,
    // OR we update ServiceDetailsPage.
    // Assuming ServiceDetailsPage requires Map based on previous code.
    // Let's create a map for compatibility for now to avoid breaking too much.
    final serviceMap = {
        'id': service.id,
        'title': service.title,
        'icon': service.icon,
        'color': service.color,
        'description': service.description,
        'price': service.price,
        'duration': service.duration,
        'features': service.features,
    };

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                ServiceDetailsPage(service: serviceMap, color: color),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}
