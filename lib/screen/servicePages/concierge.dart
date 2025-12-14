import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Services/data_service.dart';
import '../../widget/color.dart';
import '../../widget/clean_service_appbar.dart';

class ConciergeServicesPage extends StatefulWidget {
  const ConciergeServicesPage({Key? key}) : super(key: key);

  @override
  _ConciergeServicesPageState createState() => _ConciergeServicesPageState();
}

class _ConciergeServicesPageState extends State<ConciergeServicesPage>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List<Map<String, dynamic>> _services = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _shouldRetry = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_services.isEmpty) {
      _services = _getDefaultServices(AppLocalizations.of(context)!);
      _isLoading = false;
      _loadConciergeServices();
    }
  }

  void _initializeAnimations() {
    _waveController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);


    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_fadeController);
  }

  Future<void> _loadConciergeServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _shouldRetry = false;
    });

    try {
      final services = await SecureApiService.getConciergeServices(context);
      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      final loc = AppLocalizations.of(context)!;
      setState(() {
        _isLoading = false;
        _errorMessage = loc.loadServicesError;
        _shouldRetry = true;
      });
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final displayed =
        _services.isNotEmpty ? _services : _getDefaultServices(loc);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildGirlishAppBar(loc),
      body: Stack(
        children: [
          // _buildSoftBackgroundWave(),
          SafeArea(child: _buildContent(displayed)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildGirlishAppBar(AppLocalizations loc) {
    return CleanServiceAppBar(
      title: loc.conciergeServices,
    );
  }
  // -------------------------------------------------------------
  // Main Content
  // -------------------------------------------------------------
  Widget _buildContent(List<Map<String, dynamic>> services) {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (_, __) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Column(
            children: [
              if (_errorMessage.isNotEmpty) _buildErrorBanner(),
              Expanded(
                child:
                    _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFD31F75),
                          ),
                        )
                        : RefreshIndicator(
                          onRefresh: _loadConciergeServices,
                          color: Colors.pink.shade400,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: GridView.builder(
                              itemCount: services.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 20,
                                    childAspectRatio: .88,
                                  ),
                              itemBuilder:
                                  (_, i) =>
                                      _buildGirlishServiceCard(i, services),
                            ),
                          ),
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // Error Banner
  // -------------------------------------------------------------
  Widget _buildErrorBanner() {
    return GestureDetector(
      onTap: _shouldRetry ? _loadConciergeServices : null,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _errorMessage,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (_shouldRetry)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.refresh, color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  // Clean, minimal service card matching new design system
  Widget _buildGirlishServiceCard(int index, List<Map<String, dynamic>> list) {
    final service = list[index];
    final color = _parseColor(service['color']);
    final icon = _getIconFromString(service['icon']);

    return InkWell(
      onTap: () => _showServiceDetails(service),
      borderRadius: BorderRadius.circular(18),
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
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and arrow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, size: 28, color: color),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                service['title'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Expanded(
                child: Text(
                  service['description'],
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary.withOpacity(0.8),
                    height: 1.4,
                  ),
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
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back,
                      size: 12,
                      color: color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'عرض',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Bottom Sheet (UI only updated)
  // -------------------------------------------------------------
  void _showServiceDetails(Map<String, dynamic> service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.shade200.withOpacity(.3),
                blurRadius: 25,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 60,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          service['title'] ?? '',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),

                  const Divider(height: 30),

                  Text(
                    service['description'] ?? '',
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),

                  if (service['features'] != null &&
                      service['features'].isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context)!.keyFeatures,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.pink.shade400,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ...service['features'].map<Widget>(
                      (feature) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              color: Colors.pink.shade400,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                feature,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        final Uri phoneUri = Uri(
                          scheme: 'tel',
                          path: '+20233001166',
                        );
                        if (await canLaunchUrl(phoneUri)) {
                          launchUrl(phoneUri);
                        }
                      },
                      child: const Text(
                        'احجز الآن',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // Utils
  // -------------------------------------------------------------
  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (_) {
      return Colors.pink.shade300;
    }
  }

  IconData _getIconFromString(String name) {
    switch (name) {
      case 'hotel':
        return FontAwesomeIcons.hotel;
      case 'plane':
        return FontAwesomeIcons.plane;
      case 'calendar-check':
        return FontAwesomeIcons.calendarCheck;
      case 'car-side':
        return FontAwesomeIcons.carSide;
      case 'utensils':
        return FontAwesomeIcons.utensils;
      case 'user-tie':
        return FontAwesomeIcons.userTie;
      default:
        return FontAwesomeIcons.questionCircle;
    }
  }

  List<Map<String, dynamic>> _getDefaultServices(AppLocalizations loc) {
    return [
      {
        'title': loc.hotelBooking,
        'icon': 'hotel',
        'color': '#E91E63',
        'description': loc.hotelDesc,
        'price': 0.0,
        'duration': '',
        'features': [
          'حجوزات فندقية بأسعار مميزة',
          'تغطية عالمية',
          'خدمة 24/7',
          'أسعار تنافسية',
        ],
      },
      {
        'title': loc.flightTickets,
        'icon': 'plane',
        'color': '#9C27B0',
        'description': loc.flightDesc,
        'price': 0.0,
        'duration': '',
        'features': [
          'تذاكر طيران بخصومات حصرية',
          'جميع الخطوط الجوية',
          'أسعار منافسة',
          'حجز سريع',
        ],
      },
      {
        'title': loc.eventPlanning,
        'icon': 'calendar-check',
        'color': '#673AB7',
        'description': loc.eventDesc,
        'price': 0.0,
        'duration': '',
        'features': [
          'تنظيم كامل للفعاليات',
          'لمسة احترافية',
          'تخطيط شامل',
          'متابعة مستمرة',
        ],
      },
      {
        'title': loc.driverServices,
        'icon': 'car-side',
        'color': '#3F51B5',
        'description': loc.driverDesc,
        'price': 0.0,
        'duration': '',
        'features': [
          'سائق خاص بسيارة فاخرة',
          'متاح 24/7',
          'خدمة احترافية',
          'أمان تام',
        ],
      },
      {
        'title': loc.restaurantBooking,
        'icon': 'utensils',
        'color': '#2196F3',
        'description': loc.restaurantDesc,
        'price': 0.0,
        'duration': '',
        'features': [
          'افضل المطاعم',
          'أفضل الطاولات',
          'خدمة متميزة',
          'تجربة فريدة',
        ],
      },
      {
        'title': loc.personalServices,
        'icon': 'user-tie',
        'color': '#00BCD4',
        'description': loc.personalDesc,
        'price': 0.0,
        'duration': '',
        'features': [
          'تنفيذ المهام الشخصية',
          'سرية تامة',
          'خدمة مخصصة',
          'جودة عالية',
        ],
      },
    ];
  }
}
