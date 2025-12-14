import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/service_entity.dart';
import '../repositories/service_repository.dart';

class GetServices implements UseCase<List<ServiceEntity>, GetServicesParams> {
  final ServiceRepository repository;

  GetServices(this.repository);

  @override
  Future<Either<Failure, List<ServiceEntity>>> call(GetServicesParams params) async {
    return await repository.getServices(params.type, params.lang);
  }
}

class GetServicesParams extends Equatable {
  final String type;
  final String lang;

  const GetServicesParams({required this.type, required this.lang});

  @override
  List<Object> get props => [type, lang];
}
