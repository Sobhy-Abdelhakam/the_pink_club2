import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_medical_providers.dart';
import 'medical_network_event.dart';
import 'medical_network_state.dart';

class MedicalNetworkBloc extends Bloc<MedicalNetworkEvent, MedicalNetworkState> {
  final GetMedicalProviders getMedicalProviders;

  // Translation map for filtering logic (Arabic backend -> English keys if needed or vice versa)
  // Logic: The backend returns Arabic types. The filter UI usually has keys.
  // The entities have `type` in Arabic (or whatever backend sends).
  // We assume the filter event sends types that match the entity.type OR we handle translation here.
  // For simplicity, we assume filter sends matching strings.
  
  // Actually, map.dart had `_englishToArabic`.
  // Ideally, the UI sends the value it wants to filter by.
  // If UI filter sends 'Pharmacy', we need to match 'صيدلية'.
  // This translation is Business Logic if it affects data filtering.
  // But `map.dart` had it.
  // Let's copy the mapping here to support English inputs if needed, or rely on UI sending correct values.
  static const Map<String, String> _englishToArabic = {
    'Pharmacy': 'صيدلية',
    'Hospital': 'مستشفى',
    'Laboratories': 'معمل تحاليل',
    'Scan Centers': 'مركز أشعة',
    'Physiotherapy': 'علاج طبيعي',
    'Specialized Centers': 'مركز متخصص',
    'clinics': 'عيادة',
    'Optics': 'محل نظارات',
  };

  MedicalNetworkBloc({required this.getMedicalProviders})
      : super(MedicalNetworkInitial()) {
    on<LoadMedicalProvidersEvent>(_onLoadProviders);
    on<FilterMedicalProvidersEvent>(_onFilterProviders);
  }

  Future<void> _onLoadProviders(
    LoadMedicalProvidersEvent event,
    Emitter<MedicalNetworkState> emit,
  ) async {
    emit(MedicalNetworkLoading());
    final result = await getMedicalProviders(NoParams());
    result.fold(
      (failure) => emit(MedicalNetworkError(failure.message)),
      (providers) {
        emit(MedicalNetworkLoaded(
          allProviders: providers,
          filteredProviders: providers,
        ));
      },
    );
  }

  void _onFilterProviders(
    FilterMedicalProvidersEvent event,
    Emitter<MedicalNetworkState> emit,
  ) {
    if (state is MedicalNetworkLoaded) {
      final currentState = state as MedicalNetworkLoaded;
      final selected = event.selectedTypes;

      if (selected.isEmpty) {
        emit(MedicalNetworkLoaded(
          allProviders: currentState.allProviders,
          filteredProviders: currentState.allProviders,
        ));
        return;
      }

      // Prepare translation lookup
      final effectiveSelected = selected.map((s) => _englishToArabic[s] ?? s).toSet();

      final filtered = currentState.allProviders.where((provider) {
        // provider.type comes from backend (likely Arabic)
        // effectiveSelected has Arabic terms
        // Exact match or contains? Backend data usually not normalized.
        // Assuming map.dart logic: `if (type != null && ...)`
        final type = provider.type;
        // Check if provider.type matches any selected type.
        // Since we don't know exact strings, we might need a robust check.
        // map.dart normalized using _englishToArabic.
        
        // Simpler approach: Check if translation or direct match exists
        return effectiveSelected.contains(type);
      }).toList();

      emit(MedicalNetworkLoaded(
        allProviders: currentState.allProviders,
        filteredProviders: filtered,
      ));
    }
  }
}
