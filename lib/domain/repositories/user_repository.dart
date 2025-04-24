import 'package:dartz/dartz.dart';
import 'package:kidsdo/core/errors/failures.dart';
import 'package:kidsdo/domain/entities/base_user.dart';
import 'package:kidsdo/domain/entities/child.dart';
import 'package:kidsdo/domain/entities/parent.dart';

/// Interfaz para el repositorio de usuarios
abstract class IUserRepository {
  /// Guarda un usuario padre en la base de datos
  Future<Either<Failure, void>> saveParent(Parent parent);

  /// Guarda un usuario hijo en la base de datos
  Future<Either<Failure, void>> saveChild(Child child);

  /// Obtiene un usuario por su id
  Future<Either<Failure, BaseUser>> getUserById(String userId);

  /// Obtiene un usuario padre por su id
  Future<Either<Failure, Parent>> getParentById(String parentId);

  /// Obtiene el usuario padre actual a partir de Auth
  Future<Either<Failure, Parent?>> getCurrentParentFromAuth();

  /// Obtiene un usuario hijo por su id
  Future<Either<Failure, Child>> getChildById(String childId);

  /// Obtiene todos los hijos de un padre
  Future<Either<Failure, List<Child>>> getChildrenByParentId(String parentId);

  /// Actualiza los puntos de un niño
  Future<Either<Failure, void>> updateChildPoints(String childId, int points);

  /// Actualiza el nivel de un niño
  Future<Either<Failure, void>> updateChildLevel(String childId, int level);

  /// Actualiza la configuración de un usuario
  Future<Either<Failure, void>> updateUserSettings(
    String userId,
    Map<String, dynamic> settings,
  );
}
