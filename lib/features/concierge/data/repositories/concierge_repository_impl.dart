import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/concierge_service.dart';
import '../../domain/repositories/concierge_repository.dart';
import '../datasources/concierge_remote_data_source.dart';

class ConciergeRepositoryImpl implements ConciergeRepository {
  final ConciergeRemoteDataSource remoteDataSource;

  ConciergeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ConciergeService>>> getServices(String lang) async {
    try {
      final services = await remoteDataSource.getServices(lang);
      return Right(services);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
