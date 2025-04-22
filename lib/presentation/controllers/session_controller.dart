import 'package:get/get.dart';
import 'package:kidsdo/domain/entities/parent.dart';
import 'package:kidsdo/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controlador para gestionar el estado de la sesión del usuario
class SessionController extends GetxController {
  final IAuthRepository _authRepository;
  final SharedPreferences _sharedPreferences;

  // Estado observable
  final Rx<Parent?> currentUser = Rx<Parent?>(null);
  final RxBool isLoading = RxBool(true);

  // Clave para almacenamiento local
  static const String _userLoggedInKey = 'user_logged_in';

  SessionController({
    required IAuthRepository authRepository,
    required SharedPreferences sharedPreferences,
  })  : _authRepository = authRepository,
        _sharedPreferences = sharedPreferences;

  @override
  void onInit() {
    super.onInit();
    checkUserLoggedIn();
  }

  /// Verifica si hay un usuario con sesión activa
  Future<void> checkUserLoggedIn() async {
    isLoading.value = true;

    final result = await _authRepository.getCurrentUser();

    result.fold(
      (failure) {
        currentUser.value = null;
        // Si hay un error, consideramos que no hay sesión activa
        _sharedPreferences.setBool(_userLoggedInKey, false);
      },
      (user) {
        currentUser.value = user;
        // Si hay un usuario, marcamos que hay sesión activa
        if (user != null) {
          _sharedPreferences.setBool(_userLoggedInKey, true);
        } else {
          _sharedPreferences.setBool(_userLoggedInKey, false);
        }
      },
    );

    isLoading.value = false;
  }

  /// Establece el usuario actual
  void setCurrentUser(Parent user) {
    currentUser.value = user;
    _sharedPreferences.setBool(_userLoggedInKey, true);
  }

  /// Limpia la sesión actual
  void clearCurrentUser() {
    currentUser.value = null;
    _sharedPreferences.setBool(_userLoggedInKey, false);
  }

  /// Obtiene si hay un usuario con sesión activa desde SharedPreferences
  bool get isUserLoggedIn =>
      _sharedPreferences.getBool(_userLoggedInKey) ?? false;

  /// Actualiza el perfil del usuario actual
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    if (currentUser.value == null) return;

    final result = await _authRepository.updateUserProfile(
      displayName: displayName,
      photoUrl: photoUrl,
    );

    result.fold(
      (failure) {
        // Manejo de error
      },
      (_) async {
        // Actualizar el usuario actual
        await checkUserLoggedIn();
      },
    );
  }
}
