// Fixed version with smaller markers
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../widget/color.dart';

class MapData extends StatefulWidget {
  const MapData({super.key});

  @override
  State<MapData> createState() => _MapDataState();
}

class _MapDataState extends State<MapData> {
  // Location & map
  LatLng? _currentLocation;
  GoogleMapController? _mapController;

  // Data & UI state
  final Set<Marker> _markers = {};
  bool _isOffline = false;
  bool _showLegend = false;
  bool _isLoading = false;
  bool _isDisposed = false;
  bool _showFilterDropdown = false;

  // Networking
  final String _url = "https://providers.euro-assist.com/api/arabic-providers";
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Marker icon mapping (type -> asset) - Reduced to only Arabic types to avoid duplicates
  final Map<String, String> _imageMap = const {
    'صيدلية': 'assets/icons/pharmacy.png',
    'مستشفى': 'assets/icons/hospital.png',
    'معمل تحاليل': 'assets/icons/laboratory.png',
    'مركز أشعة': 'assets/icons/scan.png',
    'علاج طبيعي': 'assets/icons/Physiotherapy.png',
    'مركز متخصص': 'assets/icons/Specialized Centers.png',
    'عيادة': 'assets/icons/clinics.png',
    'محل نظارات': 'assets/icons/optics.png',
  };

  // English to Arabic mapping for translation
  final Map<String, String> _englishToArabic = const {
    'Pharmacy': 'صيدلية',
    'Hospital': 'مستشفى',
    'Laboratories': 'معمل تحاليل',
    'Scan Centers': 'مركز أشعة',
    'Physiotherapy': 'علاج طبيعي',
    'Specialized Centers': 'مركز متخصص',
    'clinics': 'عيادة',
    'Optics': 'محل نظارات',
  };

  // Cache for BitmapDescriptors so we don't reload assets for every marker
  final Map<String, BitmapDescriptor> _iconCache = {};

  // Smaller default marker
  BitmapDescriptor? _smallDefaultMarker;

  // Change filter state to single selection
  Set<String> _selectedTypes = {};
  List<dynamic>? _allMarkerData; // Cache for all marker data

  @override
  void initState() {
    super.initState();
    _selectedTypes = {}; // Show all by default
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      _setupConnectivityListener();
      // Ensure location services and permissions are ready on launch
      await _ensureLocationReady();
      await _getCurrentLocation();
      await _fetchMarkers();
    } catch (e) {
      debugPrint('Error in initialization: $e');
      if (mounted && !_isDisposed) {
        _showErrorDialog(
          "حدث خطأ أثناء تحميل التطبيق. يرجى المحاولة مرة أخرى.",
        );
      }
    }
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (_isDisposed || !mounted) return;

      final hasConnection =
          results.isNotEmpty && results.first != ConnectivityResult.none;

      if (hasConnection) {
        if (_isOffline) {
          setState(() => _isOffline = false);
          _fetchMarkers();
        }
      } else {
        if (!_isOffline) {
          setState(() => _isOffline = true);
        }
        if (_markers.isEmpty) {
          _showRetryDialog(
            "لا يوجد اتصال بالإنترنت. يرجى تشغيله لإعادة تحميل البيانات.",
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    try {
      _connectivitySubscription?.cancel();
      _mapController?.dispose();
    } catch (e) {
      debugPrint('Error in dispose: $e');
    }
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (_isDisposed || !mounted) return;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await _showEnableLocationDialog();
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          if (mounted && !_isDisposed) {
            setState(() {
              _currentLocation = const LatLng(30.0444, 31.2357); // fallback
            });
          }
          return;
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        await _showEnablePermissionDialog();
        permission = await Geolocator.checkPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted && !_isDisposed) {
          setState(() {
            _currentLocation = const LatLng(30.0444, 31.2357);
          });
        }
        return;
      }

      // Try to get last known position first (faster)
      Position? lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null && mounted && !_isDisposed) {
        setState(() {
          _currentLocation = LatLng(
            lastPosition.latitude,
            lastPosition.longitude,
          );
        });
      }

      // Then get current position
      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy:
            LocationAccuracy
                .medium, // Changed from high to medium for better performance
        timeLimit: const Duration(seconds: 20), // Add timeout
      );

      if (mounted && !_isDisposed) {
        final LatLng target = LatLng(
          currentPosition.latitude,
          currentPosition.longitude,
        );
        setState(() {
          _currentLocation = target;
        });
        // Animate to current location if map is ready
        if (_mapController != null) {
          try {
            await _mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(target, 15),
            );
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('Location error: $e');
      // Always set fallback location
      if (mounted && !_isDisposed) {
        setState(() {
          _currentLocation = const LatLng(30.0444, 31.2357);
        });
      }
    }
  }

  Future<BitmapDescriptor> _getSmallDefaultMarker() async {
    if (_smallDefaultMarker != null) return _smallDefaultMarker!;

    // Create a small custom marker using an existing icon
    try {
      _smallDefaultMarker = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 20)), // Made smaller
        'assets/icons/clinics.png', // Use clinics icon as small default
      );
    } catch (e) {
      // Fallback to default marker with custom hue
      _smallDefaultMarker = BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueRose,
      );
    }

    return _smallDefaultMarker!;
  }

  Future<BitmapDescriptor> _resolveMarkerIcon(String? type) async {
    try {
      // Normalize type - convert English to Arabic if needed
      String? normalizedType = type;
      if (type != null && _englishToArabic.containsKey(type)) {
        normalizedType = _englishToArabic[type];
      }

      final String? path =
          normalizedType != null ? _imageMap[normalizedType] : null;
      if (path == null) {
        // Use a smaller default marker
        return await _getSmallDefaultMarker();
      }

      if (_iconCache.containsKey(path)) return _iconCache[path]!;

      // Use a much smaller icon size to reduce marker size significantly
      final icon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(80, 80)),
        path,
      );
      _iconCache[path] = icon;
      return icon;
    } catch (e) {
      debugPrint('Icon loading error for type $type: $e');
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose);
    }
  }

  // Force refresh all markers with new sizes (removed old offline refresh usage)

  Future<void> _fetchMarkers({bool forceNetwork = false}) async {
    if (_isLoading || _isDisposed || !mounted) return;
    _iconCache.clear();
    _smallDefaultMarker = null;
    _markers.clear();
    setState(() => _isLoading = true);
    try {
      if (_allMarkerData == null || forceNetwork) {
        final response = await http
            .get(Uri.parse(_url), headers: {'Accept': 'application/json'})
            .timeout(const Duration(seconds: 30));
        if (!mounted || _isDisposed) return;
        if (response.statusCode == 200) {
          _allMarkerData = jsonDecode(utf8.decode(response.bodyBytes));
        } else {
          setState(() => _isLoading = false);
          debugPrint('API Error: Status code  [1m${response.statusCode} [0m');
          _showRetryDialog(
            "حدث خطأ أثناء تحميل البيانات. الكود: ${response.statusCode}",
          );
          return;
        }
      }
      final List<dynamic> data = _allMarkerData ?? [];
      if (data.isEmpty) {
        setState(() => _isLoading = false);
        _showRetryDialog("لا توجد بيانات متاحة من الخادم.");
        return;
      }
      final Set<Marker> loaded = {};
      int idx = 0;
      int skippedCount = 0;
      const int batchSize = 50;
      for (int i = 0; i < data.length; i += batchSize) {
        if (_isDisposed || !mounted) break;
        final batch = data.skip(i).take(batchSize);
        for (final item in batch) {
          if (_isDisposed || !mounted) break;
          try {
            final num? latN = item['latitude'];
            final num? lngN = item['longitude'];
            if (latN == null || lngN == null) {
              skippedCount++;
              continue;
            }
            final double lat = latN.toDouble();
            final double lng = lngN.toDouble();
            if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
              skippedCount++;
              continue;
            }
            final String id = (item['id'] ?? '${lat}_${lng}_$idx').toString();
            final String title = (item['name'] ?? 'غير معروف').toString();
            final String phone = (item['phone'] ?? 'غير متوفر').toString();
            final String discount =
                (item['discount_pct'] ?? 'غير متوفر').toString();
            final String? type = item['type']?.toString();
            String? normalizedType = type;
            if (type != null && _englishToArabic.containsKey(type)) {
              normalizedType = _englishToArabic[type];
            }
            if (_selectedTypes.isNotEmpty &&
                (normalizedType == null ||
                    !_selectedTypes.contains(normalizedType))) {
              continue;
            }
            final BitmapDescriptor icon = await _resolveMarkerIcon(type);
            loaded.add(
              Marker(
                markerId: MarkerId(id),
                position: LatLng(lat, lng),
                icon: icon,
                infoWindow: InfoWindow(
                  title:
                      title.length > 50
                          ? '${title.substring(0, 47)}...'
                          : title,
                  snippet: discount != 'غير متوفر' ? 'خصم: $discount' : null,
                  onTap: () {
                    _showPopup(title, discount, phone, lat, lng);
                  },
                ),
              ),
            );
            idx++;
          } catch (e) {
            debugPrint('Error creating marker for item $idx: $e');
            skippedCount++;
          }
        }
        await Future.delayed(const Duration(milliseconds: 1));
      }
      if (mounted && !_isDisposed) {
        setState(() {
          _markers
            ..clear()
            ..addAll(loaded);
          _isLoading = false;
        });
      }
      debugPrint(
        'Created  [1m${_markers.length} [0m markers on map (skipped $skippedCount items)',
      );
      // Only show error dialog if this is the initial fetch (not filtering)
      // if (_markers.isEmpty && mounted && !_isDisposed) {
      //   _showRetryDialog("لا توجد نقاط متاحة حالياً. يرجى المحاولة لاحقاً.");
      // }
    } on TimeoutException {
      if (mounted && !_isDisposed) {
        setState(() => _isLoading = false);
      }
      _showRetryDialog("انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى.");
    } catch (e) {
      if (mounted && !_isDisposed) {
        setState(() => _isLoading = false);
      }
      debugPrint('Fetch markers error: $e');
      _showRetryDialog("حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.");
    }
  }

  void _showPopup(
    String title,
    String discount,
    String phone,
    double lat,
    double lng,
  ) {
    if (_isDisposed || !mounted) return;

    try {
      showDialog(
        context: context,
        builder:
            (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Divider(color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    _buildInfoRow('الخصم:', discount),
                    _buildInfoRow('رقم الهاتف:', phone),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _makePhoneCall(phone),
                            icon: const Icon(
                              Icons.phone,
                              color: Color(0xFFd31f75),
                              size: 18,
                            ),
                            label: const Text(
                              "اتصال",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _openLocationOnMap(lat, lng),
                            icon: const Icon(
                              Icons.map,
                              color: Color(0xFFd31f75),
                              size: 18,
                            ),
                            label: const Text(
                              "الموقع",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      );
    } catch (e) {
      debugPrint('Error showing popup: $e');
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final sanitized = phoneNumber.replaceAll(RegExp(r'[^\d\+]'), '');
    final Uri phoneUri = Uri.parse("tel:$sanitized");
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted && !_isDisposed) {
          _showErrorDialog("لا يمكن إجراء المكالمة");
        }
      }
    } catch (e) {
      debugPrint('Error making phone call: $e');
      if (mounted && !_isDisposed) {
        _showErrorDialog("لا يمكن إجراء المكالمة");
      }
    }
  }

  Future<void> _openLocationOnMap(double latitude, double longitude) async {
    final String url = "http://maps.google.com/?q=$latitude,$longitude";
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await Clipboard.setData(ClipboardData(text: url));
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: url));
    }
  }

  void _showRetryDialog(String message) {
    if (_isDisposed || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Text("خطأ"),
            content: Text(message, textAlign: TextAlign.right),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _fetchMarkers();
                },
                child: const Text("إعادة المحاولة"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("إلغاء"),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    if (_isDisposed || !mounted) return;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("خطأ"),
            content: Text(message, textAlign: TextAlign.right),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("موافق"),
              ),
            ],
          ),
    );
  }

  String _translateType(String type) {
    // Use the mapping or return original if not found
    return _englishToArabic[type] ?? type;
  }

  Future<bool> _ensureLocationReady() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await _showEnableLocationDialog();
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        await _showEnablePermissionDialog();
        permission = await Geolocator.checkPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('Error ensuring location ready: $e');
      return false;
    }
  }

  Future<void> _goToMyLocation() async {
    if (!mounted || _isDisposed) return;
    final ok = await _ensureLocationReady();
    if (!ok) return;
    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 20),
      );
      final LatLng target = LatLng(position.latitude, position.longitude);
      if (mounted && !_isDisposed) {
        setState(() => _currentLocation = target);
      }
      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(target, 15),
        );
      }
    } catch (e) {
      debugPrint('Error moving to my location: $e');
    }
  }

  Future<void> _showEnableLocationDialog() async {
    if (_isDisposed || !mounted) return;
    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("تشغيل الموقع"),
            content: const Text(
              "خدمة تحديد الموقع متوقفة. هل تريد تشغيلها من الإعدادات؟",
              textAlign: TextAlign.right,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("إلغاء"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    await Geolocator.openLocationSettings();
                  } catch (_) {}
                },
                child: const Text("فتح الإعدادات"),
              ),
            ],
          ),
    );
  }

  Future<void> _showEnablePermissionDialog() async {
    if (_isDisposed || !mounted) return;
    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("أذونات الموقع"),
            content: const Text(
              "تم رفض إذن الموقع نهائياً. يرجى السماح به من إعدادات التطبيق.",
              textAlign: TextAlign.right,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("إلغاء"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    await Geolocator.openAppSettings();
                  } catch (_) {}
                },
                child: const Text("فتح الإعدادات"),
              ),
            ],
          ),
    );
  }

  // Removed old bottom sheet filter (single-select)

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) return const SizedBox.shrink();

    final themePrimary = AppColors.primary;

    return Scaffold(
      body: Stack(
        children: [
          if (_currentLocation == null)
            const Center(child: CircularProgressIndicator())
          else
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation!,
                zoom: 12, // Reduced initial zoom for better performance
              ),
              onMapCreated: (controller) {
                if (!_isDisposed && mounted) {
                  try {
                    _mapController = controller;
                  } catch (e) {
                    debugPrint('Error setting map controller: $e');
                  }
                }
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: _markers,
              // Add these for better performance
              compassEnabled: true,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              tiltGesturesEnabled: false, // Disable tilt to improve performance
            ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
          // Top filter input-like bar (over the map)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 12,
            right: 12,
            child: Material(
              color: Colors.white,
              elevation: 4,
              borderRadius: BorderRadius.circular(28),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.filter_alt_outlined,
                      color: Color(0xFFd31f75),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child:
                            _selectedTypes.isEmpty
                                ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Text(
                                    'اختر نوع الخدمة... (متعدد)',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                )
                                : ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxHeight: 32,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children:
                                        _selectedTypes
                                            .map(
                                              (t) => Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 6,
                                                ),
                                                child: Material(
                                                  color: const Color(
                                                    0x14d31f75,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 4,
                                                            ),
                                                        child: Text(
                                                          _translateType(t),
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                color: Color(
                                                                  0xFFd31f75,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            _selectedTypes
                                                                .remove(t);
                                                          });
                                                          _fetchMarkers();
                                                        },
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                horizontal: 6,
                                                                vertical: 4,
                                                              ),
                                                          child: Icon(
                                                            Icons.close,
                                                            size: 18,
                                                            color: Color(
                                                              0xFFd31f75,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        setState(() {
                          _showFilterDropdown = !_showFilterDropdown;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(
                          _showFilterDropdown
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: const Color(0xFFd31f75),
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom-left My Location button
          Positioned(
            left: 12,
            bottom: 16,
            child: Material(
              color: Colors.white,
              elevation: 4,
              borderRadius: BorderRadius.circular(28),
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: _goToMyLocation,
                child: Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.my_location,
                    size: 28,
                    color: Color(0xFFd31f75),
                  ),
                ),
              ),
            ),
          ),
          if (_showLegend)
            Positioned(
              bottom: 70,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 10,
                  bottom: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(color: themePrimary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ماذا تعني الرموز ؟',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFd31f75),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (mounted && !_isDisposed) {
                              setState(() => _showLegend = false);
                            }
                          },
                          icon: Icon(
                            Icons.cancel,
                            size: 20,
                            color: Color(0xFFd31f75),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    //const SizedBox(height: 12),
                    Divider(height: 1, color: Colors.grey[300]),
                    const SizedBox(height: 12),

                    // Use ListView.builder for better performance with many items
                    SizedBox(
                      height: 300, // Fixed height to prevent overflow
                      child: ListView.builder(
                        itemCount: _imageMap.length,
                        itemBuilder: (context, index) {
                          final entry = _imageMap.entries.elementAt(index);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      entry.value,
                                      width: 24, // Reduced size
                                      height: 24,
                                      fit: BoxFit.contain,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Icon(
                                          Icons.location_on,
                                          size: 24,
                                          color: Color(0xFFd31f75),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _translateType(entry.key),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: themePrimary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Removed old search icon button; replaced by full-width input bar above
          // Light barrier to close when tapping outside
          if (_showFilterDropdown)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() => _showFilterDropdown = false);
                },
                child: Container(color: Colors.black.withOpacity(0.05)),
              ),
            ),
          // Dropdown panel from top (multi-select)
          if (_showFilterDropdown)
            Positioned(
              top: MediaQuery.of(context).padding.top + 64,
              right: 12,
              left: 12,
              child: Material(
                color: Colors.white,
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.55,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'اختر نوع الخدمة (يمكن اختيار أكثر من نوع):',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Color(0xFFd31f75),
                            ),
                            onPressed:
                                () =>
                                    setState(() => _showFilterDropdown = false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.3,
                          shrinkWrap: true,
                          children: [
                            _buildFilterGridChip(
                              label: 'الكل',
                              icon: const Icon(
                                Icons.layers,
                                size: 22,
                                color: Color(0xFFd31f75),
                              ),
                              selected: _selectedTypes.isEmpty,
                              onTap: () {
                                setState(() {
                                  _selectedTypes.clear();
                                });
                                _fetchMarkers();
                              },
                            ),
                            ..._imageMap.keys.map(
                              (type) => _buildFilterGridChip(
                                label: _translateType(type),
                                icon: Image.asset(
                                  _imageMap[type]!,
                                  width: 22,
                                  height: 22,
                                  fit: BoxFit.contain,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(
                                            Icons.location_on,
                                            size: 22,
                                            color: Color(0xFFd31f75),
                                          ),
                                ),
                                selected: _selectedTypes.contains(type),
                                onTap: () {
                                  setState(() {
                                    if (_selectedTypes.contains(type)) {
                                      _selectedTypes.remove(type);
                                    } else {
                                      _selectedTypes.add(type);
                                    }
                                  });
                                  // Do not fetch here to allow multiple toggles before applying
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _fetchMarkers();
                                setState(() {
                                  _showFilterDropdown = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFd31f75),
                              ),
                              child: const Text(
                                'تطبيق',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedTypes.clear();
                                  _showFilterDropdown = false;
                                });
                                _fetchMarkers();
                              },
                              child: const Text('مسح الكل'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Widget _buildFilterGridChip({
  required String label,
  required Widget icon,
  required bool selected,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.white,
    elevation: 4,
    shadowColor: Colors.black.withOpacity(0.12),
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFFd31f75) : Colors.transparent,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: const Color(0xFFd31f75),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
