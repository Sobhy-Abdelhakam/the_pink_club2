import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/concierge_service.dart';

abstract class ConciergeRepository {
  Future<Either<Failure, List<ConciergeService>>> getServices(String lang);
}
