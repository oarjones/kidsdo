import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kidsdo/core/errors/failures.dart';
import 'package:kidsdo/data/datasources/remote/challenge_remote_datasource.dart';
import 'package:kidsdo/data/models/challenge_model.dart';
import 'package:kidsdo/data/models/assigned_challenge_model.dart';
import 'package:kidsdo/domain/entities/challenge.dart';
import 'package:kidsdo/domain/entities/assigned_challenge.dart';
import 'package:kidsdo/domain/repositories/challenge_repository.dart';

class ChallengeRepositoryImpl implements IChallengeRepository {
  final IChallengeRemoteDataSource _challengeRemoteDataSource;

  ChallengeRepositoryImpl({
    required IChallengeRemoteDataSource challengeRemoteDataSource,
  }) : _challengeRemoteDataSource = challengeRemoteDataSource;

  @override
  Future<Either<Failure, List<Challenge>>> getChallengesByFamily(
      String familyId) async {
    try {
      final challenges =
          await _challengeRemoteDataSource.getChallengesByFamily(familyId);
      return Right(challenges);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Challenge>>> getPredefinedChallenges() async {
    try {
      final challenges =
          await _challengeRemoteDataSource.getPredefinedChallenges();
      return Right(challenges);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Challenge>> getChallengeById(
      String challengeId) async {
    try {
      final challenge =
          await _challengeRemoteDataSource.getChallengeById(challengeId);
      return Right(challenge);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        return const Left(NotFoundFailure(message: 'Reto no encontrado'));
      }
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Challenge>> createChallenge(
      Challenge challenge) async {
    try {
      final challengeModel = await _challengeRemoteDataSource
          .createChallenge(ChallengeModel.fromEntity(challenge));
      return Right(challengeModel);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateChallenge(Challenge challenge) async {
    try {
      await _challengeRemoteDataSource
          .updateChallenge(ChallengeModel.fromEntity(challenge));
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChallenge(String challengeId) async {
    try {
      await _challengeRemoteDataSource.deleteChallenge(challengeId);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AssignedChallenge>> assignChallengeToChild({
    required String challengeId,
    required String childId,
    required String familyId,
    required DateTime startDate,
    DateTime? endDate,
    bool isContinuous = false,
  }) async {
    try {
      final assignedChallenge =
          await _challengeRemoteDataSource.assignChallengeToChild(
        challengeId: challengeId,
        childId: childId,
        familyId: familyId,
        startDate: startDate,
        endDate: endDate,
        isContinuous: isContinuous,
      );
      return Right(assignedChallenge);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AssignedChallenge>>> getAssignedChallengesByChild(
      String childId) async {
    try {
      final assignedChallenges = await _challengeRemoteDataSource
          .getAssignedChallengesByChild(childId);
      return Right(assignedChallenges);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AssignedChallenge>> getAssignedChallengeById(
      String assignedChallengeId) async {
    try {
      final assignedChallenge = await _challengeRemoteDataSource
          .getAssignedChallengeById(assignedChallengeId);
      return Right(assignedChallenge);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        return const Left(
            NotFoundFailure(message: 'Reto asignado no encontrado'));
      }
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateAssignedChallenge(
      AssignedChallenge assignedChallenge) async {
    try {
      await _challengeRemoteDataSource.updateAssignedChallenge(
          AssignedChallengeModel.fromEntity(assignedChallenge));
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAssignedChallenge(
      String assignedChallengeId) async {
    try {
      await _challengeRemoteDataSource
          .deleteAssignedChallenge(assignedChallengeId);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> evaluateExecution({
    required String assignedChallengeId,
    required int executionIndex,
    required AssignedChallengeStatus status,
    required int points,
    String? note,
  }) async {
    try {
      await _challengeRemoteDataSource.evaluateExecution(
        assignedChallengeId: assignedChallengeId,
        executionIndex: executionIndex,
        status: status,
        points: points,
        note: note,
      );
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createNextExecution({
    required String assignedChallengeId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      await _challengeRemoteDataSource.createNextExecution(
        assignedChallengeId: assignedChallengeId,
        startDate: startDate,
        endDate: endDate,
      );
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // @override
  // @Deprecated('Use evaluateExecution instead')
  // Future<Either<Failure, void>> evaluateAssignedChallenge({
  //   required String assignedChallengeId,
  //   required AssignedChallengeStatus status,
  //   required int points,
  //   String? note,
  // }) async {
  //   try {
  //     await _challengeRemoteDataSource.evaluateAssignedChallenge(
  //       assignedChallengeId: assignedChallengeId,
  //       status: status,
  //       points: points,
  //       note: note,
  //     );
  //     return const Right(null);
  //   } on FirebaseException catch (e) {
  //     return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
  //   } catch (e) {
  //     return Left(ServerFailure(message: e.toString()));
  //   }
  // }
}
