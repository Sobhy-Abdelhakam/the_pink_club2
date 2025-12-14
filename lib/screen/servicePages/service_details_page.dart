import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widget/animated_background_gradient.dart';
import '/l10n/app_localizations.dart';
import 'package:the_pink_club2/widget/service_card.dart';

class ServiceDetailsPage extends StatelessWidget {
  final Map<String, dynamic> service;
  final Color color;

  const ServiceDetailsPage({
    super.key,
    required this.service,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor =
        isDarkMode ? Colors.grey[900]! : Colors.grey[50]!;
    final Color textColor = isDarkMode ? Colors.white : Colors.grey[800]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                service['title'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black.withOpacity(0.7),
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
              ),
              background: _buildHeroSection(context),
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
            ),
            leading: IconButton(
              icon: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.3),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildServiceDescription(context, textColor),
                  const SizedBox(height: 32),
                  ...((service['features'] != null &&
                          service['features'].isNotEmpty)
                      ? [
                        _buildFeaturesSection(context, textColor),
                        const SizedBox(height: 32),
                      ]
                      : []),
                  _buildActionButtons(context, localizations),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final String? imageUrl = service['image'];

    // Generate unique hero tag that matches the service card
    final String heroTag =
        'service_card_${service['id'] ?? service['title'] ?? DateTime.now().millisecondsSinceEpoch}';

    return Hero(
      tag: heroTag,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null && imageUrl.isNotEmpty)
            Image.network(
              imageUrl.startsWith('http')
                  ? imageUrl
                  : 'http://127.0.0.1:8000/$imageUrl',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return AnimatedBackgroundGradient(color: color);
              },
            )
          else
            AnimatedBackgroundGradient(color: color),

          // Gradient overlay to darken the image or colored background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color.withOpacity(0.4), color.withOpacity(0.2)],
              ),
            ),
          ),

          // Center icon/logo overlay (only if there's no image)
          if (imageUrl == null || imageUrl.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: IconHelper.getIcon(service['icon'], size: 36),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildServiceDescription(BuildContext context, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.serviceOverview,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          service['description'],
          style: TextStyle(fontSize: 18, color: textColor, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(BuildContext context, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.keyFeatures,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth >= 700;
            final double spacing = 16;
            final double itemWidth =
                isWide
                    ? (constraints.maxWidth - spacing) / 2
                    : constraints.maxWidth;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: List.generate(service['features'].length, (index) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: itemWidth,
                    minWidth: itemWidth,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.check, size: 16, color: color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              service['features'][index].toString(),
                              style: TextStyle(
                                fontSize: 16,
                                color: textColor,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Column(
      children: [
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: color, width: 2),
              ),
              elevation: 3,
            ),
            onPressed: () async {
              final Uri phoneUri = Uri(scheme: 'tel', path: '+20233001166');
              if (await canLaunchUrl(phoneUri)) {
                await launchUrl(phoneUri);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("localizations.failedToOpenDialer")),
                );
              }
            },
            child: Text(
              localizations.callUs,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
