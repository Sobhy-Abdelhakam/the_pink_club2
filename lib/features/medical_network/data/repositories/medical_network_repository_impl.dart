import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/medical_provider.dart';
import '../../domain/repositories/medical_network_repository.dart';
import '../datasources/medical_network_remote_data_source.dart';

class MedicalNetworkRepositoryImpl implements MedicalNetworkRepository {
  final MedicalNetworkRemoteDataSource remoteDataSource;

  MedicalNetworkRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<MedicalProvider>>> getProviders() async {
    try {
      final providers = await remoteDataSource.getProviders();
      // Filter out invalid coordinates here to keep Domain clean
      final validProviders = providers.where((p) {
        return p.latitude >= -90 &&
            p.latitude <= 90 &&
            p.longitude >= -180 &&
            p.longitude <= 180 &&
            (p.latitude != 0.0 || p.longitude != 0.0);
      }).toList();
      return Right(validProviders);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
