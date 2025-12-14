import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/color.dart';
import '../bloc/ads_bloc.dart';
import '../bloc/ads_event.dart';
import '../bloc/ads_state.dart';
import '../pages/provider_ad_detail_page.dart';

class AdsBanner extends StatefulWidget {
  final double height;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final double borderRadius;
  final BoxFit fit;

  const AdsBanner({
    super.key,
    this.height = 200,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.borderRadius = 16,
    this.fit = BoxFit.fill,
  });

  @override
  State<AdsBanner> createState() => _AdsBannerState();
}

class _AdsBannerState extends State<AdsBanner> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _timer;
  late AdsBloc _adsBloc;

  @override
  void initState() {
    super.initState();
    _adsBloc = sl<AdsBloc>()..add(LoadAdsEvent());
  }

  void _startAutoPlay(int itemCount) {
    _timer?.cancel();
    _timer = Timer.periodic(widget.autoPlayInterval, (timer) {
      if (_pageController.hasClients && itemCount > 0) {
        int nextPage = _currentIndex + 1;
        if (nextPage >= itemCount) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _adsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _adsBloc,
      child: BlocBuilder<AdsBloc, AdsState>(
        builder: (context, state) {
          if (state is AdsLoading) {
            return SizedBox(
              height: widget.height,
              child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            );
          } else if (state is AdsLoaded) {
            if (state.ads.isEmpty) return const SizedBox.shrink();

            if (widget.autoPlay) _startAutoPlay(state.ads.length);

            return SizedBox(
              height: widget.height,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: state.ads.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final ad = state.ads[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProviderAdDetailPage(providerAd: ad),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(widget.borderRadius),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(widget.borderRadius),
                            child: CachedNetworkImage(
                              imageUrl: ad.getImageUrl(),
                              fit: widget.fit,
                              placeholder: (context, url) => Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: CircularProgressIndicator(color: AppColors.primary),
                                ),
                              ),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (state.ads.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: SmoothPageIndicator(
                          controller: _pageController,
                          count: state.ads.length,
                          effect: ExpandingDotsEffect(
                            activeDotColor: AppColors.primary,
                            dotColor: Colors.white.withValues(alpha: 0.5),
                            dotHeight: 8,
                            dotWidth: 8,
                            expansionFactor: 3,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          } else if (state is AdsError) {
             return SizedBox(
              height: widget.height,
              child: const Center(child: Text('Failed to load ads')), // Basic error handling
            );
          }
          return SizedBox(height: widget.height);
        },
      ),
    );
  }
}
