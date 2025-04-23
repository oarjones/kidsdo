import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

abstract class IAuthRemoteDataSource {
  /// Registra un nuevo usuario con email y contraseña
  Future<User> registerWithEmail({
    required String email,
    required String password,
  });

  /// Inicia sesión con email y contraseña
  Future<User> signInWithEmail({
    required String email,
    required String password,
  });

  /// Inicia sesión con Google
  Future<User> signInWithGoogle();

  /// Cierra la sesión actual
  Future<void> signOut();

  /// Envía un correo para restablecer la contraseña
  Future<void> resetPassword(String email);

  /// Obtiene el usuario actualmente autenticado
  Future<User?> getCurrentUser();

  /// Actualiza el perfil del usuario autenticado
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
  });
}

class AuthRemoteDataSource implements IAuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  final Logger logger = Get.find<Logger>();

  AuthRemoteDataSource({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

  @override
  Future<User> registerWithEmail({
    required String email,
    required String password,
  }) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential.user == null) {
      throw FirebaseAuthException(
        code: 'user-creation-failed',
        message: 'No se pudo crear el usuario',
      );
    }

    return userCredential.user!;
  }

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential.user == null) {
      throw FirebaseAuthException(
        code: 'sign-in-failed',
        message: 'No se pudo iniciar sesión',
      );
    }

    return userCredential.user!;
  }

  @override
  Future<User> signInWithGoogle() async {
    try {
      logger.i("Iniciando proceso de autenticación con Google...");

      // Iniciar el flujo de autenticación de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        logger.i("El usuario canceló el inicio de sesión con Google");
        throw FirebaseAuthException(
          code: 'google-sign-in-canceled',
          message: 'El inicio de sesión con Google fue cancelado',
        );
      }

      logger.i("Usuario de Google obtenido: ${googleUser.email}");

      // Obtener detalles de autenticación de la solicitud
      logger.i("Obteniendo tokens de autenticación...");
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      logger.i(
          "Token de acceso obtenido: ${googleAuth.accessToken?.substring(0, 10)}...");
      logger.i("Token ID obtenido: ${googleAuth.idToken?.substring(0, 10)}...");

      // Verificar que tengamos tokens válidos
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        logger.i("Error: No se pudieron obtener tokens válidos de Google");
        throw FirebaseAuthException(
          code: 'google-sign-in-no-tokens',
          message:
              'No se pudieron obtener tokens válidos para la autenticación con Google',
        );
      }

      // Crear una nueva credencial
      logger.i("Creando credencial de Firebase con tokens de Google...");
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken!,
        idToken: googleAuth.idToken!,
      );

      // Iniciar sesión con la credencial
      logger.i("Iniciando sesión en Firebase con credencial de Google...");
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        logger.i(
            "Error: Firebase devolvió un usuario nulo después de la autenticación");
        throw FirebaseAuthException(
          code: 'google-sign-in-failed',
          message: 'No se pudo iniciar sesión con Google',
        );
      }

      logger.i(
          "Inicio de sesión con Google exitoso para usuario: ${userCredential.user!.email}");
      return userCredential.user!;
    } catch (e) {
      // Registrar el error para depuración
      logger.i('Error en signInWithGoogle: $e');

      if (e is FirebaseAuthException) {
        rethrow;
      }

      // En modo de desarrollo, imprimimos detalles adicionales de depuración
      if (e is PlatformException) {
        logger.i('PlatformException detallada:');
        logger.i('  Código: ${e.code}');
        logger.i('  Mensaje: ${e.message}');
        logger.i('  Detalles: ${e.details}');
      }

      throw FirebaseAuthException(
        code: 'google-sign-in-error',
        message: 'Error al iniciar sesión con Google: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<User?> getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  @override
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No hay usuario autenticado',
      );
    }

    await user.updateDisplayName(displayName);
    await user.updatePhotoURL(photoUrl);
  }
}
