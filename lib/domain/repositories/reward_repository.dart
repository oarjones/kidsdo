import 'package:dartz/dartz.dart';
import 'package:kidsdo/core/errors/failures.dart'; // Asegúrate que la ruta sea correcta
import 'package:kidsdo/domain/entities/reward.dart'; // Asegúrate que la ruta sea correcta

abstract class IRewardRepository {
  Future<Either<Failure, Reward>> createReward(Reward reward);
  Stream<Either<Failure, List<Reward>>> getRewardsStream(
      String familyId); // Para actualizaciones en tiempo real
  Future<Either<Failure, List<Reward>>> getRewardsOnce(
      String familyId); // Para obtener una vez
  Future<Either<Failure, Reward>> updateReward(Reward reward);
  Future<Either<Failure, void>> deleteReward(
      {required String familyId, required String rewardId});
  Future<Either<Failure, List<Reward>>> getPredefinedRewards(
      {String? category}); // Para filtrar por categoría
}
