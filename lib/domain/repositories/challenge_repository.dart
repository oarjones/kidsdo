import 'package:dartz/dartz.dart';
import 'package:kidsdo/core/errors/failures.dart';
import 'package:kidsdo/domain/entities/challenge.dart';
import 'package:kidsdo/domain/entities/assigned_challenge.dart';

/// Interfaz para el repositorio de retos
abstract class IChallengeRepository {
  /// Obtiene todos los retos para una familia
  Future<Either<Failure, List<Challenge>>> getChallengesByFamily(
      String familyId);

  /// Obtiene retos predefinidos (templates)
  Future<Either<Failure, List<Challenge>>> getPredefinedChallenges();

  /// Obtiene un reto por su id
  Future<Either<Failure, Challenge>> getChallengeById(String challengeId);

  /// Crea un nuevo reto
  Future<Either<Failure, Challenge>> createChallenge(Challenge challenge);

  /// Actualiza un reto existente
  Future<Either<Failure, void>> updateChallenge(Challenge challenge);

  /// Elimina un reto
  Future<Either<Failure, void>> deleteChallenge(String challengeId);

  /// Asigna un reto a un niño
  Future<Either<Failure, AssignedChallenge>> assignChallengeToChild({
    required String challengeId,
    required String childId,
    required String familyId,
    required DateTime startDate,
    required DateTime endDate,
    required String evaluationFrequency,
  });

  /// Obtiene los retos asignados a un niño
  Future<Either<Failure, List<AssignedChallenge>>> getAssignedChallengesByChild(
      String childId);

  /// Obtiene un reto asignado por su id
  Future<Either<Failure, AssignedChallenge>> getAssignedChallengeById(
      String assignedChallengeId);

  /// Actualiza un reto asignado
  Future<Either<Failure, void>> updateAssignedChallenge(
      AssignedChallenge assignedChallenge);

  /// Elimina un reto asignado
  Future<Either<Failure, void>> deleteAssignedChallenge(
      String assignedChallengeId);

  /// Evalúa un reto asignado
  Future<Either<Failure, void>> evaluateAssignedChallenge({
    required String assignedChallengeId,
    required AssignedChallengeStatus status,
    required int points,
    String? note,
  });
}
