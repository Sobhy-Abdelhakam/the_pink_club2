import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../network/api_client.dart';
import '../../features/concierge/data/datasources/concierge_remote_data_source.dart';
import '../../features/concierge/data/repositories/concierge_repository_impl.dart';
import '../../features/concierge/domain/repositories/concierge_repository.dart';
import '../../features/concierge/domain/usecases/get_concierge_services.dart';
import '../../features/concierge/presentation/bloc/concierge_bloc.dart';

import '../../features/services/data/datasources/service_remote_data_source.dart';
import '../../features/services/data/repositories/service_repository_impl.dart';
import '../../features/services/domain/repositories/service_repository.dart';
import '../../features/services/domain/usecases/get_services.dart';
import '../../features/services/presentation/bloc/services_bloc.dart';

import '../../features/medical_network/data/datasources/medical_network_remote_data_source.dart';
import '../../features/medical_network/data/repositories/medical_network_repository_impl.dart';
import '../../features/medical_network/domain/repositories/medical_network_repository.dart';
import '../../features/medical_network/domain/usecases/get_medical_providers.dart';
import '../../features/medical_network/presentation/bloc/medical_network_bloc.dart';

import '../../features/home/data/repositories/ads_repository_impl.dart';
import '../../features/home/domain/repositories/ads_repository.dart';
import '../../features/home/presentation/bloc/ads_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Concierge
  // Services Feature
  sl.registerFactory(
    () => ServicesBloc(getServices: sl()),
  );
  sl.registerLazySingleton(() => GetServices(sl()));
  sl.registerLazySingleton<ServiceRepository>(
    () => ServiceRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ServiceRemoteDataSource>(
    () => ServiceRemoteDataSourceImpl(apiClient: sl()),
  );

  // Medical Network Feature
  sl.registerFactory(
    () => MedicalNetworkBloc(getMedicalProviders: sl()),
  );
  sl.registerLazySingleton(() => GetMedicalProviders(sl()));
  sl.registerLazySingleton<MedicalNetworkRepository>(
    () => MedicalNetworkRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<MedicalNetworkRemoteDataSource>(
    () => MedicalNetworkRemoteDataSourceImpl(client: sl()),
  );

  // Home Feature (Ads)
  sl.registerFactory(
    () => AdsBloc(repository: sl()),
  );
  sl.registerLazySingleton<AdsRepository>(
    () => AdsRepositoryImpl(client: sl()),
  );

  // Concierge Feature (Existing)
  sl.registerFactory(
    () => ConciergeBloc(getConciergeServices: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetConciergeServices(sl()));

  // Repository
  sl.registerLazySingleton<ConciergeRepository>(
    () => ConciergeRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ConciergeRemoteDataSource>(
    () => ConciergeRemoteDataSourceImpl(apiClient: sl()),
  );

  //! Core
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(client: sl(), storage: sl()),
  );

  //! External
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => const FlutterSecureStorage());
}
