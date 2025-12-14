import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/medical_provider.dart';
import '../repositories/medical_network_repository.dart';

class GetMedicalProviders implements UseCase<List<MedicalProvider>, NoParams> {
  final MedicalNetworkRepository repository;

  GetMedicalProviders(this.repository);

  @override
  Future<Either<Failure, List<MedicalProvider>>> call(NoParams params) async {
    return await repository.getProviders();
  }
}
