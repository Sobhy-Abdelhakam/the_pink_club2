import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_services.dart';
import 'services_event.dart';
import 'services_state.dart';

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  final GetServices getServices;

  ServicesBloc({required this.getServices}) : super(ServicesInitial()) {
    on<GetServicesEvent>((event, emit) async {
      emit(ServicesLoading());
      final result = await getServices(
        GetServicesParams(type: event.type, lang: event.lang),
      );
      result.fold(
        (failure) => emit(ServicesError(failure.message)),
        (services) => emit(ServicesLoaded(services)),
      );
    });
  }
}
