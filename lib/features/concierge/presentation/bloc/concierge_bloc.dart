import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_concierge_services.dart';
import 'concierge_event.dart';
import 'concierge_state.dart';

class ConciergeBloc extends Bloc<ConciergeEvent, ConciergeState> {
  final GetConciergeServices getConciergeServices;

  ConciergeBloc({required this.getConciergeServices}) : super(ConciergeInitial()) {
    on<GetConciergeServicesEvent>((event, emit) async {
      emit(ConciergeLoading());
      final result = await getConciergeServices(event.lang);
      result.fold(
        (failure) => emit(ConciergeError(failure.message)),
        (services) => emit(ConciergeLoaded(services)),
      );
    });
  }
}
