import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kidsdo/core/errors/failures.dart';
import 'package:kidsdo/data/datasources/remote/auth_remote_datasource.dart';
import 'package:kidsdo/data/datasources/remote/user_remote_datasource.dart';
import 'package:kidsdo/data/models/parent_model.dart';
import 'package:kidsdo/domain/entities/parent.dart';
import 'package:kidsdo/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource _authRemoteDataSource;
  final IUserRemoteDataSource _userRemoteDataSource;

  AuthRepositoryImpl({
    required IAuthRemoteDataSource authRemoteDataSource,
    required IUserRemoteDataSource userRemoteDataSource,
  })  : _authRemoteDataSource = authRemoteDataSource,
        _userRemoteDataSource = userRemoteDataSource;

  @override
  Future<Either<Failure, Parent>> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Registrar el usuario en Firebase Auth
      final firebaseUser = await _authRemoteDataSource.registerWithEmail(
        email: email,
        password: password,
      );

      // Actualizar el displayName
      await _authRemoteDataSource.updateUserProfile(displayName: displayName);

      // Crear el modelo de padre
      final parentModel = ParentModel(
        uid: firebaseUser.uid,
        displayName: displayName,
        email: email,
        createdAt: DateTime.now(),
        settings: const {
          'theme': 'default',
          'notifications': true,
          'soundEffects': true,
        },
      );

      // Guardar el padre en Firestore
      await _userRemoteDataSource.saveParent(parentModel);

      return Right(parentModel);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: _mapFirebaseAuthErrorToMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Parent>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Iniciar sesión en Firebase Auth
      final firebaseUser = await _authRemoteDataSource.signInWithEmail(
        email: email,
        password: password,
      );

      // Obtener los datos del padre desde Firestore
      final parentModel =
          await _userRemoteDataSource.getParentById(firebaseUser.uid);

      return Right(parentModel);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: _mapFirebaseAuthErrorToMessage(e)));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Parent>> signInWithGoogle() async {
    try {
      // Iniciar sesión con Google
      final firebaseUser = await _authRemoteDataSource.signInWithGoogle();

      try {
        // Intentar obtener el usuario existente
        final parentModel =
            await _userRemoteDataSource.getParentById(firebaseUser.uid);

        return Right(parentModel);
      } on FirebaseException {
        // Si el usuario no existe, crearlo
        final parentModel = ParentModel(
          uid: firebaseUser.uid,
          displayName: firebaseUser.displayName ?? 'Usuario',
          email: firebaseUser.email ?? '',
          avatarUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
          settings: const {
            'theme': 'default',
            'notifications': true,
            'soundEffects': true,
          },
        );

        // Guardar el padre en Firestore
        await _userRemoteDataSource.saveParent(parentModel);

        return Right(parentModel);
      }
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: _mapFirebaseAuthErrorToMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _authRemoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await _authRemoteDataSource.resetPassword(email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: _mapFirebaseAuthErrorToMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Parent?>> getCurrentUser() async {
    try {
      final firebaseUser = await _authRemoteDataSource.getCurrentUser();

      if (firebaseUser == null) {
        return const Right(null);
      }

      try {
        final parentModel =
            await _userRemoteDataSource.getParentById(firebaseUser.uid);
        return Right(parentModel);
      } on FirebaseException {
        return const Right(null);
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      final user = await _authRemoteDataSource.getCurrentUser();
      return user != null;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      await _authRemoteDataSource.updateUserProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );

      // Si se actualiza el perfil, también actualizar en Firestore
      final user = await _authRemoteDataSource.getCurrentUser();
      if (user != null) {
        try {
          final parentModel =
              await _userRemoteDataSource.getParentById(user.uid);

          await _userRemoteDataSource.saveParent(
            parentModel.copyWith(
              displayName: displayName ?? parentModel.displayName,
              avatarUrl: photoUrl ?? parentModel.avatarUrl,
            ) as ParentModel,
          );
        } catch (_) {
          // Ignore errors when updating Firestore, Auth update was successful
        }
      }

      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: _mapFirebaseAuthErrorToMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // Método privado para mapear errores de Firebase Auth a mensajes más amigables
  String _mapFirebaseAuthErrorToMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe un usuario con este correo electrónico';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo electrónico';
      case 'weak-password':
        return 'La contraseña es demasiado débil';
      case 'invalid-email':
        return 'El correo electrónico no es válido';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      case 'user-disabled':
        return 'Este usuario ha sido deshabilitado';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Inténtalo más tarde';
      default:
        return e.message ?? 'Error de autenticación';
    }
  }
}
