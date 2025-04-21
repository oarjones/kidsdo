import 'package:dartz/dartz.dart';
import 'package:kidsdo/core/errors/failures.dart';
import 'package:kidsdo/domain/entities/parent.dart';

/// Interfaz para el repositorio de autenticación
abstract class IAuthRepository {
  /// Registra un nuevo usuario padre con email y contraseña
  Future<Either<Failure, Parent>> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  /// Inicia sesión con email y contraseña
  Future<Either<Failure, Parent>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Inicia sesión con Google
  Future<Either<Failure, Parent>> signInWithGoogle();

  /// Cierra la sesión actual
  Future<Either<Failure, void>> signOut();

  /// Envía un correo para restablecer la contraseña
  Future<Either<Failure, void>> resetPassword(String email);

  /// Obtiene el usuario actualmente autenticado
  Future<Either<Failure, Parent?>> getCurrentUser();

  /// Verifica si hay un usuario autenticado
  Future<bool> isSignedIn();

  /// Actualiza el perfil del usuario autenticado
  Future<Either<Failure, void>> updateUserProfile({
    String? displayName,
    String? photoUrl,
  });
}
