import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/ads_repository.dart';
import 'ads_event.dart';
import 'ads_state.dart';

class AdsBloc extends Bloc<AdsEvent, AdsState> {
  final AdsRepository repository;

  AdsBloc({required this.repository}) : super(AdsInitial()) {
    on<LoadAdsEvent>(_onLoadAds);
  }

  Future<void> _onLoadAds(LoadAdsEvent event, Emitter<AdsState> emit) async {
    emit(AdsLoading());
    try {
      final ads = await repository.fetchAds();
      emit(AdsLoaded(ads));
    } catch (e) {
      emit(AdsError(e.toString()));
    }
  }
}
