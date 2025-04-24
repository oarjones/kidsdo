import 'package:dartz/dartz.dart';
import 'package:kidsdo/core/errors/failures.dart';
import 'package:kidsdo/domain/entities/family_child.dart';

/// Interfaz para el repositorio de perfiles infantiles
abstract class IFamilyChildRepository {
  /// Crea un nuevo perfil infantil
  Future<Either<Failure, FamilyChild>> createChild({
    required String familyId,
    required String name,
    required DateTime birthDate,
    String? avatarUrl,
    required String createdBy,
    required Map<String, dynamic> settings,
  });

  /// Obtiene un perfil infantil por su ID
  Future<Either<Failure, FamilyChild>> getChildById(String childId);

  /// Obtiene todos los perfiles infantiles de una familia
  Future<Either<Failure, List<FamilyChild>>> getChildrenByFamilyId(
      String familyId);

  /// Obtiene todos los perfiles infantiles creados por un padre/madre
  Future<Either<Failure, List<FamilyChild>>> getChildrenByCreator(
      String creatorId);

  /// Actualiza un perfil infantil
  Future<Either<Failure, void>> updateChild(FamilyChild child);

  /// Elimina un perfil infantil
  Future<Either<Failure, void>> deleteChild(String childId);

  /// Actualiza los puntos de un niño
  Future<Either<Failure, void>> updateChildPoints(String childId, int points);

  /// Actualiza el nivel de un niño
  Future<Either<Failure, void>> updateChildLevel(String childId, int level);

  /// Actualiza la configuración de un niño
  Future<Either<Failure, void>> updateChildSettings(
    String childId,
    Map<String, dynamic> settings,
  );
}
