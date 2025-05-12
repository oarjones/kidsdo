import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseException; // Solo para el tipo

import 'package:kidsdo/core/errors/failures.dart';
import 'package:kidsdo/data/datasources/remote/reward_remote_datasource.dart';
import 'package:kidsdo/data/models/reward_model.dart';
import 'package:kidsdo/domain/entities/reward.dart';
import 'package:kidsdo/domain/repositories/reward_repository.dart';
import 'package:kidsdo/presentation/controllers/session_controller.dart'; // Para createdBy y familyId
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

class RewardRepositoryImpl implements IRewardRepository {
  final IRewardRemoteDataSource _remoteDataSource;
  final SessionController
      _sessionController; // Para obtener el familyId y userId del padre
  final Uuid _uuid;
  final Logger _logger;

  RewardRepositoryImpl({
    required IRewardRemoteDataSource remoteDataSource,
    required SessionController sessionController,
    required Uuid uuid,
    required Logger logger,
  })  : _remoteDataSource = remoteDataSource,
        _sessionController = sessionController,
        _uuid = uuid,
        _logger = logger;

  @override
  Future<Either<Failure, Reward>> createReward(Reward reward) async {
    try {
      final parent = _sessionController.currentUser.value;
      if (parent == null || parent.familyId == null) {
        _logger.w('Cannot create reward: Parent or familyId is null.');
        return const Left(AuthFailure(
            message: 'Usuario no autenticado o sin familia asociada.'));
      }

      final now = DateTime.now();
      final rewardId = _uuid.v4(); // Generar ID único

      final rewardToCreate = reward.copyWith(
        id: rewardId,
        familyId: parent.familyId!,
        createdBy: parent.uid,
        createdAt: now,
        updatedAt: now,
      );

      final rewardModel = RewardModel.fromEntity(rewardToCreate);
      final createdRewardModel =
          await _remoteDataSource.createReward(rewardModel);
      return Right(
          createdRewardModel); // La entidad ya es `Reward` gracias a `RewardModel extends Reward`
    } on FirebaseException catch (e) {
      _logger.e(
          'RewardRepositoryImpl - FirebaseException creating reward: ${e.code} - ${e.message}');
      return Left(ServerFailure(
          message: e.message ?? 'Error del servidor al crear recompensa.'));
    } catch (e) {
      _logger.e('RewardRepositoryImpl - Exception creating reward: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<Reward>>> getRewardsStream(String familyId) {
    _logger.d('getRewardsStream for family: $familyId');
    try {
      return _remoteDataSource.getRewardsStream(familyId).map((rewardModels) {
        // Los modelos ya son entidades Reward
        return Right<Failure, List<Reward>>(rewardModels);
      }).handleError((error) {
        _logger.e('Error in getRewardsStream from repository: $error');
        if (error is FirebaseException) {
          return Stream.value(Left<Failure, List<Reward>>(ServerFailure(
              message: error.message ??
                  'Error de Firebase al obtener recompensas.')));
        }
        return Stream.value(Left<Failure, List<Reward>>(ServerFailure(
            message:
                'Error al obtener recompensas en tiempo real: ${error.toString()}')));
      });
    } catch (e) {
      _logger.e('Synchronous error setting up getRewardsStream: $e');
      return Stream.value(Left(ServerFailure(
          message: 'Error al iniciar stream de recompensas: ${e.toString()}')));
    }
  }

  @override
  Future<Either<Failure, List<Reward>>> getRewardsOnce(String familyId) async {
    _logger.d('getRewardsOnce for family: $familyId');
    try {
      final rewardModels = await _remoteDataSource.getRewardsOnce(familyId);
      // Los modelos ya son entidades Reward
      return Right(rewardModels);
    } on FirebaseException catch (e) {
      _logger.e(
          'RewardRepositoryImpl - FirebaseException getting rewards once: ${e.code} - ${e.message}');
      return Left(ServerFailure(
          message: e.message ?? 'Error del servidor al obtener recompensas.'));
    } catch (e) {
      _logger.e('RewardRepositoryImpl - Exception getting rewards once: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reward>> updateReward(Reward reward) async {
    try {
      final parent = _sessionController.currentUser.value;
      if (parent == null ||
          parent.familyId == null ||
          parent.familyId != reward.familyId) {
        _logger.w('Cannot update reward: Auth issue or familyId mismatch.');
        return const Left(AuthFailure(
            message: 'No autorizado para modificar esta recompensa.'));
      }

      final rewardToUpdate = reward.copyWith(updatedAt: DateTime.now());
      final rewardModel = RewardModel.fromEntity(rewardToUpdate);
      final updatedRewardModel =
          await _remoteDataSource.updateReward(rewardModel);
      return Right(updatedRewardModel);
    } on FirebaseException catch (e) {
      _logger.e(
          'RewardRepositoryImpl - FirebaseException updating reward: ${e.code} - ${e.message}');
      return Left(ServerFailure(
          message:
              e.message ?? 'Error del servidor al actualizar recompensa.'));
    } catch (e) {
      _logger.e('RewardRepositoryImpl - Exception updating reward: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReward(
      {required String familyId, required String rewardId}) async {
    try {
      final parent = _sessionController.currentUser.value;
      if (parent == null ||
          parent.familyId == null ||
          parent.familyId != familyId) {
        _logger.w('Cannot delete reward: Auth issue or familyId mismatch.');
        return const Left(AuthFailure(
            message: 'No autorizado para eliminar esta recompensa.'));
      }
      await _remoteDataSource.deleteReward(
          familyId: familyId, rewardId: rewardId);
      return const Right(null);
    } on FirebaseException catch (e) {
      _logger.e(
          'RewardRepositoryImpl - FirebaseException deleting reward: ${e.code} - ${e.message}');
      return Left(ServerFailure(
          message: e.message ?? 'Error del servidor al eliminar recompensa.'));
    } catch (e) {
      _logger.e('RewardRepositoryImpl - Exception deleting reward: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Reward>>> getPredefinedRewards(
      {String? category}) async {
    try {
      // Este método recuperaría desde la colección 'predefined_rewards'
      // y los transformaría en entidades 'Reward' para la UI.
      // La transformación es necesaria porque PredefinedReward tiene nombres/descripciones i18n
      // y la entidad Reward espera un solo string (el idioma actual).
      // El 'familyId' y 'createdBy' estarían vacíos o serían especiales.
      // Alternativamente, podrías tener una entidad y modelo 'PredefinedRewardEntity/Model' separados
      // si la estructura es muy diferente.
      // Por ahora, vamos a simular que el datasource los adapta.
      final List<RewardModel> predefinedRewardModels =
          await _remoteDataSource.getPredefinedRewards(category: category);
      return Right(predefinedRewardModels);
    } on FirebaseException catch (e) {
      _logger.e(
          'RewardRepositoryImpl - FirebaseException getting predefined rewards: ${e.code} - ${e.message}');
      return Left(ServerFailure(
          message: e.message ??
              'Error del servidor al obtener recompensas predefinidas.'));
    } catch (e) {
      _logger
          .e('RewardRepositoryImpl - Exception getting predefined rewards: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
