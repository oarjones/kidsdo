import 'package:dartz/dartz.dart';
import 'package:kidsdo/core/errors/failures.dart';
import 'package:kidsdo/domain/entities/family.dart';

/// Interfaz para el repositorio de familias
abstract class IFamilyRepository {
  /// Crea una nueva familia
  Future<Either<Failure, Family>> createFamily({
    required String name,
    required String createdBy,
  });

  /// Obtiene una familia por su id
  Future<Either<Failure, Family>> getFamilyById(String familyId);

  /// Obtiene una familia por su código de invitación
  Future<Either<Failure, Family>> getFamilyByInviteCode(String inviteCode);

  /// Actualiza una familia
  Future<Either<Failure, void>> updateFamily(Family family);

  /// Agrega un miembro a una familia
  Future<Either<Failure, void>> addMemberToFamily({
    required String familyId,
    required String userId,
  });

  /// Elimina un miembro de una familia
  Future<Either<Failure, void>> removeMemberFromFamily({
    required String familyId,
    required String userId,
  });

  /// Genera un nuevo código de invitación para una familia
  Future<Either<Failure, String>> generateFamilyInviteCode(String familyId);
}
