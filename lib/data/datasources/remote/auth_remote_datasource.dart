import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    // Iniciar el flujo de autenticación de Google
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'google-sign-in-canceled',
        message: 'El inicio de sesión con Google fue cancelado',
      );
    }

    // Obtener detalles de autenticación de la solicitud
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Crear una nueva credencial
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Iniciar sesión con la credencial
    final userCredential = await _firebaseAuth.signInWithCredential(credential);

    if (userCredential.user == null) {
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: 'No se pudo iniciar sesión con Google',
      );
    }

    return userCredential.user!;
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
