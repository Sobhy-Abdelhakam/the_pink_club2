import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/concierge_service.dart';
import '../repositories/concierge_repository.dart';

class GetConciergeServices implements UseCase<List<ConciergeService>, String> {
  final ConciergeRepository repository;

  GetConciergeServices(this.repository);

  @override
  Future<Either<Failure, List<ConciergeService>>> call(String lang) async {
    return await repository.getServices(lang);
  }
}
