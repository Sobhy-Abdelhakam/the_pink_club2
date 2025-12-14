import 'dart:async';

import 'package:flutter/material.dart';
import '../../../models/provider_ad.dart';
import '../../../Services/data_service.dart';
import 'provider_ad_detail_page.dart';

/// AdsBanner: a reusable banner carousel with dots indicator that fetches provider ads from API.
///
/// Optional:
///  - autoPlay: whether to automatically move to next page
///  - autoPlayInterval: Duration between auto advances
///  - height, borderRadius
class AdsBanner extends StatefulWidget {
  final double height;
  final double borderRadius;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final BoxFit fit;

  const AdsBanner({
    super.key,
    this.height = 180,
    this.borderRadius = 8.0,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 5),
    this.fit = BoxFit.cover,
  });

  @override
  State<AdsBanner> createState() => _AdsBannerState();
}

class _AdsBannerState extends State<AdsBanner> {
  late final PageController _pageController;
  late int _currentPage;
  Timer? _autoPlayTimer;
  List<ProviderAd> _providerAds = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _currentPage = 0;
    _pageController = PageController(initialPage: _currentPage);
    _fetchProviderAds();
  }

  Future<void> _fetchProviderAds() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final data = await SecureApiService.getProviderAds();
      final ads = data.map((json) => ProviderAd.fromJson(json)).toList();

      if (mounted) {
        setState(() {
          _providerAds = ads;
          _isLoading = false;
        });

        if (widget.autoPlay && _providerAds.length > 1) {
          _startAutoPlay();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    if (_providerAds.length <= 1) return;
    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (timer) {
      if (!mounted) return;
      final next = (_currentPage + 1) % _providerAds.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  @override
  void didUpdateWidget(covariant AdsBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    // restart autoplay if needed when widget params change
    if (widget.autoPlay != oldWidget.autoPlay ||
        widget.autoPlayInterval != oldWidget.autoPlayInterval) {
      _stopAutoPlay();
      if (widget.autoPlay && _providerAds.length > 1) _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ),
      );
    }

    if (_error != null || _providerAds.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.grey.shade400, size: 48),
              const SizedBox(height: 8),
              Text(
                _error != null ? 'Error loading ads' : 'No ads available',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    final showDots = _providerAds.length > 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: widget.height,
          child: GestureDetector(
            onTapDown: (_) {
              // pause autoplay while user interacts
              _stopAutoPlay();
            },
            onTapUp: (_) {
              if (widget.autoPlay && _providerAds.length > 1) _startAutoPlay();
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: PageView.builder(
                controller: _pageController,
                itemCount: _providerAds.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final ad = _providerAds[index];
                  final imageUrl = ad.getImageUrl();

                  Widget imageWidget;
                  if (imageUrl.isNotEmpty) {
                    imageWidget = Image.network(
                      imageUrl,
                      fit: widget.fit,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey.shade200,
                          child: Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (ctx, error, stack) {
                        return _fallbackImage();
                      },
                    );
                  } else {
                    imageWidget = _fallbackImage();
                  }

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ProviderAdDetailPage(providerAd: ad),
                        ),
                      );
                    },
                    child: SizedBox.expand(child: imageWidget),
                  );
                },
              ),
            ),
          ),
        ),

        if (showDots) const SizedBox(height: 8),

        // Dots indicator
        if (showDots)
          _DotsIndicator(
            count: _providerAds.length,
            currentIndex: _currentPage,
            onDotTapped: (i) {
              _pageController.animateToPage(
                i,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
              );
            },
          ),
      ],
    );
  }

  Widget _fallbackImage() => Container(
    color: Colors.grey.shade300,
    child: const Center(
      child: Icon(Icons.broken_image, size: 36, color: Colors.black26),
    ),
  );
}

/// Small, customizable dots indicator with tapping support.
class _DotsIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  final void Function(int index)? onDotTapped;
  final double dotSize;
  final double activeDotWidth;
  final Duration animationDuration;

  const _DotsIndicator({
    required this.count,
    required this.currentIndex,
    this.onDotTapped,
    this.dotSize = 8,
    this.activeDotWidth = 20,
    this.animationDuration = const Duration(milliseconds: 250),
  });

  @override
  Widget build(BuildContext context) {
    final dots = List<Widget>.generate(count, (i) {
      final isActive = i == currentIndex;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onDotTapped?.call(i),
        child: AnimatedContainer(
          duration: animationDuration,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? activeDotWidth : dotSize,
          height: dotSize,
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color:
                isActive
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    });

    return SizedBox(
      height: 20,
      child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: dots)),
    );
  }
}
