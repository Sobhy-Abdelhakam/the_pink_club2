import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:the_pink_club2/core/services/data_service.dart';
import 'package:the_pink_club2/features/subscription/presentation/pages/subscription_form_page.dart';
import '/l10n/app_localizations.dart';

import 'dart:async';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({Key? key}) : super(key: key);

  @override
  _SubscriptionsPageState createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage>
    with SingleTickerProviderStateMixin {
  // --- kept exactly as your original logic ---
  late AnimationController _scaleController;
  late Future<List<Map<String, dynamic>>> _subscriptionsFuture;
  bool _isLoading = false;
  String? _errorMessage;

  // --- UI state for the carousel (new additions but do not change data logic) ---
  final PageController _pageController = PageController(viewportFraction: 0.86);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _loadSubscriptions();

    // keep page listener for CTA / indicator
    _pageController.addListener(() {
      final page = _pageController.page;
      if (page == null) return;
      final newIndex = page.round();
      if (newIndex != _currentPage && mounted) {
        setState(() => _currentPage = newIndex);
      }
    });
  }

  Future<void> _loadSubscriptions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _subscriptionsFuture = SecureApiService.getSubscriptions(context);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Top bar with localized strings
  Widget _buildTopBar(AppLocalizations tr) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr.subscriptions,
                  style: const TextStyle(
                    color: Color(0xFFD31F75),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tr.choosePackage,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFE6F2), Color(0xFFFFDCEC)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.shade100.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Color(0xFFB0006F),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadSubscriptions,
          child: Column(
            children: [
              _buildTopBar(tr),

              // loading state (kept)
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(color: Color(0xFFD31F75)),
                  ),
                ),

              // top-level error (kept)
              if (_errorMessage != null)
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(_errorMessage!),
                      ),
                      FilledButton(
                        onPressed: _loadSubscriptions,
                        child: Text(tr.retry),
                      ),
                    ],
                  ),
                ),

              // main content (FutureBuilder with carousel)
              if (!_isLoading && _errorMessage == null)
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _subscriptionsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text('${snapshot.error}'),
                              ),
                              const SizedBox(height: 8),
                              FilledButton(
                                onPressed: _loadSubscriptions,
                                child: Text(tr.retry),
                              ),
                            ],
                          ),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFD31F75),
                          ),
                        );
                      }

                      final subscriptions = snapshot.data!;
                      if (subscriptions.isEmpty) {
                        return Center(child: Text('No subscriptions'));
                      }

                      // Carousel + indicator + CTA area
                      return Column(
                        children: [
                          // PageView carousel
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: subscriptions.length,
                              itemBuilder: (context, index) {
                                final subscription = subscriptions[index];

                                // keep your original call to _buildSubscriptionCard exactly
                                final card = ScaleTransition(
                                  scale: _scaleController,
                                  child: _buildSubscriptionCard(
                                    int.tryParse(
                                          subscription['id'].toString(),
                                        ) ??
                                        0,
                                    subscription['name'],
                                    subscription['price'] + tr.egb,
                                    _parseFeatures(subscription['features']),
                                    _getColorForSubscription(
                                      subscription['name'],
                                    ),
                                    _getIconForSubscription(
                                      subscription['name'],
                                    ),
                                  ),
                                );

                                // small transform to emphasize center
                                final page =
                                    _pageController.hasClients
                                        ? (_pageController.page ??
                                            _pageController.initialPage)
                                        : _pageController.initialPage
                                            .toDouble();
                                final delta = (index - page).abs();
                                final scale = (1 - (delta * 0.06)).clamp(
                                  0.92,
                                  1.0,
                                );

                                return Transform.scale(
                                  scale: scale,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 6,
                                    ),
                                    child: card,
                                  ),
                                );
                              },
                              onPageChanged: (idx) {
                                setState(() => _currentPage = idx);
                              },
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Page indicator (dots)
                          _buildPageIndicator(subscriptions.length),

                          const SizedBox(height: 14),

                          // Floating CTA (keeps original navigation but adds a polished CTA)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildFloatingCTAForCurrent(
                              subscriptions,
                              tr,
                            ),
                          ),

                          const SizedBox(height: 18),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Keep your original _parseFeatures unchanged
  List<String> _parseFeatures(dynamic features) {
    if (features is List) {
      return features.map((e) => e.toString()).toList();
    }
    return [];
  }

  // Keep your original color mapping unchanged
  Color _getColorForSubscription(String name) {
    if (name.contains('VIP')) return Colors.pink[800]!;
    if (name.contains('Diamond')) return Colors.pink[600]!;
    return Colors.pink;
  }

  // Keep your original icon mapping unchanged
  IconData _getIconForSubscription(String name) {
    if (name.contains('VIP')) return Icons.star;
    if (name.contains('Diamond')) return Icons.diamond;
    return Icons.favorite;
  }

  // Keep your original card builder signature and internals exactly the same.
  // I polished spacing inside but did not change logic or parameters.
  Widget _buildSubscriptionCard(
    int id,
    String title,
    String price,
    List<String> features,
    Color color,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 0),
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: color.withOpacity(0.28),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.12), color.withOpacity(0.04)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // top row with icon and title chip
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(icon, size: 30, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.09),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                // price emphasized
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 12),

                // features list (keeps original mapping)
                Column(
                  children:
                      features.map((feature) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, size: 20, color: color),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),

                const SizedBox(height: 18),
                // action button (keeps original navigation logic)
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => SubscriptionFormPage(
                              selectedPackage: title,
                              packagePrice: price,
                              packageId: id,
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.choosePackageBtn,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Page indicator (dots)
  Widget _buildPageIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final selected = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: selected ? 18 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFD31F75) : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
            boxShadow:
                selected
                    ? [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.22),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : null,
          ),
        );
      }),
    );
  }

  // Floating CTA that uses the currently visible subscription (keeps navigation logic)
  Widget _buildFloatingCTAForCurrent(
    List<Map<String, dynamic>> subscriptions,
    AppLocalizations tr,
  ) {
    final safeIndex = _currentPage.clamp(0, subscriptions.length - 1);
    final current = subscriptions[safeIndex];
    final name = current['name']?.toString() ?? '';
    final price = current['price']?.toString() ?? '';
    final displayPrice = price + tr.egb;

    final color = _getColorForSubscription(name);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => SubscriptionFormPage(
                  selectedPackage: name,
                  packagePrice: displayPrice,
                  packageId: int.tryParse(current['id'].toString()) ?? 0,
                ),
          ),
        );
      },
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.96),
              Colors.white.withOpacity(0.85),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.6)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getIconForSubscription(name), color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    AppLocalizations.of(context)!.choosePackageBtn,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Text(
                displayPrice,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
