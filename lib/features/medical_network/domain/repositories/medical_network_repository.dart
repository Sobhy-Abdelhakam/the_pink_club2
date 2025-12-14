import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/medical_provider.dart';

abstract class MedicalNetworkRepository {
  Future<Either<Failure, List<MedicalProvider>>> getProviders();
}
