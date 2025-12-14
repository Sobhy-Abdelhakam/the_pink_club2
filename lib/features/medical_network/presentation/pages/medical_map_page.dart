// Fixed version with smaller markers and Clean Architecture integration
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:the_pink_club2/core/di/injection_container.dart';
import 'package:the_pink_club2/core/utils/color.dart';
import 'package:the_pink_club2/features/medical_network/domain/entities/medical_provider.dart';
import 'package:the_pink_club2/features/medical_network/presentation/bloc/medical_network_bloc.dart';
import 'package:the_pink_club2/features/medical_network/presentation/bloc/medical_network_event.dart';
import 'package:the_pink_club2/features/medical_network/presentation/bloc/medical_network_state.dart';
import 'package:url_launcher/url_launcher.dart';


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
  bool _isDisposed = false;
  // bool _showFilterDropdown = false; // Not used currently

  // Marker icon mapping (type -> asset)
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

  // Cache for BitmapDescriptors
  final Map<String, BitmapDescriptor> _iconCache = {};
  BitmapDescriptor? _smallDefaultMarker;

  // Filter state
  final Set<String> _selectedTypes = {};

  // Debouncer or flag for marker generation
  bool _isGeneratingMarkers = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await _ensureLocationReady();
      await _getCurrentLocation();
    } catch (e) {
      debugPrint('Error in initialization: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (_isDisposed || !mounted) return;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
         // Optionally prompt user, but let's just fallback or wait for user action
         // _showEnableLocationDialog(); 
         // For auto-init we try without forcing dialog loop
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted && !_isDisposed) {
          setState(() {
            _currentLocation = const LatLng(30.0444, 31.2357); // Cairo fallback
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
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 20),
      );

      if (mounted && !_isDisposed) {
        final LatLng target = LatLng(
          currentPosition.latitude,
          currentPosition.longitude,
        );
        setState(() {
          _currentLocation = target;
        });
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
      if (mounted && !_isDisposed) {
        setState(() {
            _currentLocation = const LatLng(30.0444, 31.2357);
        });
      }
    }
  }

  Future<BitmapDescriptor> _getSmallDefaultMarker() async {
    if (_smallDefaultMarker != null) return _smallDefaultMarker!;
    try {
      _smallDefaultMarker = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 20)),
        'assets/icons/clinics.png',
      );
    } catch (e) {
      _smallDefaultMarker = BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueRose,
      );
    }
    return _smallDefaultMarker!;
  }

  Future<BitmapDescriptor> _resolveMarkerIcon(String? type) async {
    try {
      String? normalizedType = type;
      if (type != null && _englishToArabic.containsKey(type)) {
        normalizedType = _englishToArabic[type];
      }

      final String? path =
          normalizedType != null ? _imageMap[normalizedType] : null;
      if (path == null) {
        return await _getSmallDefaultMarker();
      }

      if (_iconCache.containsKey(path)) return _iconCache[path]!;

      final icon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(80, 80)),
        path,
      );
      _iconCache[path] = icon;
      return icon;
    } catch (e) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose);
    }
  }

  /// Generates markers from the list of providers incrementally
  Future<void> _generateMarkers(List<MedicalProvider> providers) async {
    if (_isGeneratingMarkers) return; // Debounce
    _isGeneratingMarkers = true;

    // Clear existing if needed, or update. For simplicity (filtering), clear and rebuild.
    // If we want to optimize, we could diff, but strict filtering implies clearing hidden ones.
    if (!mounted || _isDisposed) {
        _isGeneratingMarkers = false;
        return;
    }

    final Set<Marker> newMarkers = {};
    const int batchSize = 50;

    // Pre-resolve icons might be tricky if we don't know types.
    // We just do it in the loop.

    try {
        for (int i = 0; i < providers.length; i += batchSize) {
            if (_isDisposed || !mounted) break;
            
            final batch = providers.skip(i).take(batchSize);
            for (final provider in batch) {
                final icon = await _resolveMarkerIcon(provider.type);
                
                final marker = Marker(
                    markerId: MarkerId(provider.id),
                    position: LatLng(provider.latitude, provider.longitude),
                    icon: icon,
                    infoWindow: InfoWindow(
                        title: provider.name.length > 50
                            ? '${provider.name.substring(0, 47)}...'
                            : provider.name,
                        snippet: provider.discount != 'N/A' && provider.discount != 'غير متوفر'
                            ? 'خصم: ${provider.discount}' 
                            : null,
                        onTap: () {
                            _showPopup(provider);
                        },
                    ),
                );
                newMarkers.add(marker);
            }
            // Yield for a frame to keep UI responsive
            await Future.delayed(const Duration(milliseconds: 1));
        }

        if (mounted && !_isDisposed) {
            setState(() {
                _markers.clear();
                _markers.addAll(newMarkers);
            });
        }
    } finally {
        _isGeneratingMarkers = false;
    }
  }


  void _showPopup(MedicalProvider provider) {
    if (_isDisposed || !mounted) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                provider.name,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 8),
              _buildInfoRow('الخصم:', provider.discount),
              _buildInfoRow('رقم الهاتف:', provider.phone),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _makePhoneCall(provider.phone),
                      icon: const Icon(Icons.phone, color: Colors.white, size: 18),
                      label: const Text(
                        "اتصال",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openLocationOnMap(provider.latitude, provider.longitude),
                      icon: const Icon(Icons.map, color: Colors.white, size: 18),
                      label: const Text(
                        "الموقع",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
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
      }
    } catch (e) {
      debugPrint('Error making phone call: $e');
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

  Future<bool> _ensureLocationReady() async {
     // Basic check reuse
     bool enabled = await Geolocator.isLocationServiceEnabled();
     return enabled;
     // Detailed permission logic is in _getCurrentLocation
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) return const SizedBox.shrink();

    return BlocProvider(
      create: (_) => sl<MedicalNetworkBloc>()..add(LoadMedicalProvidersEvent()),
      child: BlocConsumer<MedicalNetworkBloc, MedicalNetworkState>(
        listener: (context, state) {
          if (state is MedicalNetworkLoaded) {
            _generateMarkers(state.filteredProviders);
          } else if (state is MedicalNetworkError) {
             // Show error snackbar or dialog logic removed from build
             // We can show a snackbar here
             ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text(state.message)),
             );
          }
        },
        builder: (context, state) {
           final isLoading = state is MedicalNetworkLoading;

           return Scaffold(
      body: Stack(
        children: [
          if (_currentLocation == null)
            const Center(child: CircularProgressIndicator())
          else
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation!,
                zoom: 12,
              ),
              onMapCreated: (controller) {
                if (!_isDisposed && mounted) {
                  _mapController = controller;
                }
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: _markers,
              compassEnabled: true,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              tiltGesturesEnabled: false,
            ),
          
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),

          // Filter UI
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 12,
            right: 12,
            child: _buildFilterBar(context),
          ),
          
          // My Location Button
          Positioned(
            bottom: 24,
            left: 16,
            child: FloatingActionButton(
                heroTag: 'my_location_btn',
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.my_location, color: Colors.white),
                onPressed: _getCurrentLocation,
            ),
          )
        ],
      ),
    );
        },
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
      return Material(
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
                                                            const EdgeInsets
                                                                .symmetric(
                                                              horizontal: 8,
                                                              vertical: 4,
                                                            ),
                                                        child: Text(
                                                          _englishToArabic[t] ?? t, // Display Arabic
                                                          style: const TextStyle(
                                                            color:
                                                                Color(
                                                                  0xFFd31f75,
                                                                ),
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                              _selectedTypes.remove(t);
                                                          });
                                                          context.read<MedicalNetworkBloc>().add(
                                                              FilterMedicalProvidersEvent(_selectedTypes)
                                                          );
                                                        },
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                right: 4,
                                                                left: 8,
                                                              ),
                                                          child: Icon(
                                                            Icons.close,
                                                            size: 14,
                                                            color:
                                                                Color(
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
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_drop_down_circle_outlined,
                        color: Color(0xFFd31f75),
                      ),
                      onPressed: () => _showFilterDialog(context),
                    ),
                  ],
                ),
              ),
            );
  }

  void _showFilterDialog(BuildContext ancestorContext) {
      if (_isDisposed || !mounted) return;

      showDialog(
          context: context,
          builder: (context) {
              return StatefulBuilder(
                builder: (context, setDialogState) {
                  return AlertDialog(
                      title: const Text('تصفية الخدمات', textAlign: TextAlign.right),
                      content: SingleChildScrollView(
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: _englishToArabic.keys.map((englishType) {
                                  final arabicType = _englishToArabic[englishType]!;
                                  final isSelected = _selectedTypes.contains(englishType);
                                  return CheckboxListTile(
                                      title: Text(arabicType, textAlign: TextAlign.right),
                                      value: isSelected,
                                      activeColor: AppColors.primary,
                                      onChanged: (bool? value) {
                                          setDialogState(() {
                                              if (value == true) {
                                                  _selectedTypes.add(englishType);
                                              } else {
                                                  _selectedTypes.remove(englishType);
                                              }
                                          });
                                          // Update parent state too so the bar updates when dialog closes
                                          setState(() {});
                                      },
                                  );
                              }).toList(),
                          ),
                      ),
                      actions: [
                          TextButton(
                              onPressed: () {
                                  Navigator.pop(context);
                                  // Dispatch event
                                  ancestorContext.read<MedicalNetworkBloc>().add(
                                      FilterMedicalProvidersEvent(_selectedTypes)
                                  );
                              },
                              child: const Text('تم'),
                          ),
                      ],
                  );
                }
              );
          },
      );
  }

}
