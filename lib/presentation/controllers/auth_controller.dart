import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/errors/failures.dart';
import 'package:kidsdo/core/utils/form_validators.dart';
import 'package:kidsdo/domain/repositories/auth_repository.dart';
import 'package:kidsdo/presentation/controllers/profile_controller.dart';
import 'package:kidsdo/presentation/controllers/session_controller.dart';
import 'package:kidsdo/routes.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:logger/logger.dart';

/// Estados posibles del proceso de autenticación
enum AuthStatus {
  initial,
  loading,
  success,
  error,
}

/// Controlador para la gestión de autenticación
class AuthController extends GetxController {
  final IAuthRepository _authRepository;
  final SessionController _sessionController;
  final Logger _logger;

  AuthController({
    required IAuthRepository authRepository,
    required SessionController sessionController,
    Logger? logger,
  })  : _authRepository = authRepository,
        _sessionController = sessionController,
        _logger = logger ?? Get.find<Logger>();

  // Estado observable
  final Rx<AuthStatus> status = Rx<AuthStatus>(AuthStatus.initial);
  final RxString errorMessage = RxString('');

  // Estados de visibilidad para contraseñas
  final RxBool loginPasswordVisible = RxBool(false);
  final RxBool registerPasswordVisible = RxBool(false);
  final RxBool registerConfirmPasswordVisible = RxBool(false);

  // ---- Controladores de texto para LOGIN ----
  late TextEditingController loginEmailController;
  late TextEditingController loginPasswordController;
  late FocusNode loginEmailFocusNode;
  late FocusNode loginPasswordFocusNode;

  // ---- Controladores de texto para REGISTRO ----
  late TextEditingController registerNameController;
  late TextEditingController registerEmailController;
  late TextEditingController registerPasswordController;
  late TextEditingController registerConfirmPasswordController;
  late FocusNode registerNameFocusNode;
  late FocusNode registerEmailFocusNode;
  late FocusNode registerPasswordFocusNode;
  late FocusNode registerConfirmPasswordFocusNode;

  // ---- Controladores de texto para RESET PASSWORD ----
  late TextEditingController resetPasswordEmailController;
  late FocusNode resetPasswordEmailFocusNode;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _logger.i("AuthController inicializado");
  }

  // Método separado para inicializar controladores
  void _initializeControllers() {
    // Inicializar controladores de LOGIN
    loginEmailController = TextEditingController();
    loginPasswordController = TextEditingController();
    loginEmailFocusNode = FocusNode();
    loginPasswordFocusNode = FocusNode();

    // Inicializar controladores de REGISTRO
    registerNameController = TextEditingController();
    registerEmailController = TextEditingController();
    registerPasswordController = TextEditingController();
    registerConfirmPasswordController = TextEditingController();
    registerNameFocusNode = FocusNode();
    registerEmailFocusNode = FocusNode();
    registerPasswordFocusNode = FocusNode();
    registerConfirmPasswordFocusNode = FocusNode();

    // Inicializar controladores de RESET PASSWORD
    resetPasswordEmailController = TextEditingController();
    resetPasswordEmailFocusNode = FocusNode();

    // Listeners para limpiar mensajes de error al modificar campos
    // Login
    loginEmailController.addListener(_clearErrorOnChange);
    loginPasswordController.addListener(_clearErrorOnChange);

    // Registro
    registerNameController.addListener(_clearErrorOnChange);
    registerEmailController.addListener(_clearErrorOnChange);
    registerPasswordController.addListener(_clearErrorOnChange);
    registerConfirmPasswordController.addListener(_clearErrorOnChange);

    // Reset password
    resetPasswordEmailController.addListener(_clearErrorOnChange);

    _logger.d("Todos los controladores de texto inicializados");
  }

  @override
  void onClose() {
    // Liberar controladores
    _disposeControllers();
    _logger.i("AuthController cerrado");
    super.onClose();
  }

  // Método separado para liberar controladores
  void _disposeControllers() {
    _logger.d("Liberando controladores de texto");

    // Remover listeners de Login
    loginEmailController.removeListener(_clearErrorOnChange);
    loginPasswordController.removeListener(_clearErrorOnChange);

    // Remover listeners de Registro
    registerNameController.removeListener(_clearErrorOnChange);
    registerEmailController.removeListener(_clearErrorOnChange);
    registerPasswordController.removeListener(_clearErrorOnChange);
    registerConfirmPasswordController.removeListener(_clearErrorOnChange);

    // Remover listeners de Reset Password
    resetPasswordEmailController.removeListener(_clearErrorOnChange);

    // Disponer controladores de Login
    loginEmailController.dispose();
    loginPasswordController.dispose();
    loginEmailFocusNode.dispose();
    loginPasswordFocusNode.dispose();

    // Disponer controladores de Registro
    registerNameController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    registerConfirmPasswordController.dispose();
    registerNameFocusNode.dispose();
    registerEmailFocusNode.dispose();
    registerPasswordFocusNode.dispose();
    registerConfirmPasswordFocusNode.dispose();

    // Disponer controladores de Reset Password
    resetPasswordEmailController.dispose();
    resetPasswordEmailFocusNode.dispose();
  }

  /// Limpia el mensaje de error cuando el usuario modifica algún campo
  void _clearErrorOnChange() {
    if (errorMessage.isNotEmpty) {
      errorMessage.value = '';
    }
  }

  /// Toggle para mostrar/ocultar contraseña en LOGIN
  void toggleLoginPasswordVisibility() {
    _logger.d(
        "Toggle visibilidad de contraseña login: ${!loginPasswordVisible.value}");
    loginPasswordVisible.value = !loginPasswordVisible.value;
  }

  /// Toggle para mostrar/ocultar contraseña en REGISTRO
  void toggleRegisterPasswordVisibility() {
    _logger.d(
        "Toggle visibilidad de contraseña registro: ${!registerPasswordVisible.value}");
    registerPasswordVisible.value = !registerPasswordVisible.value;
  }

  /// Toggle para mostrar/ocultar confirmación de contraseña en REGISTRO
  void toggleRegisterConfirmPasswordVisibility() {
    _logger.d(
        "Toggle visibilidad de confirmación: ${!registerConfirmPasswordVisible.value}");
    registerConfirmPasswordVisible.value =
        !registerConfirmPasswordVisible.value;
  }

  /// Validador para campo de email
  String? validateEmail(String? value) {
    return FormValidators.email(value);
  }

  /// Validador para campo de contraseña
  String? validatePassword(String? value) {
    return FormValidators.password(value);
  }

  /// Validador para campo de confirmación de contraseña
  String? validateConfirmPassword(String? value) {
    return FormValidators.confirmPassword(
        value, registerPasswordController.text);
  }

  /// Validador para campo de nombre
  String? validateName(String? value) {
    return FormValidators.name(value);
  }

  /// Método para registrar un nuevo usuario
  Future<void> register() async {
    // Ocultar teclado
    FocusManager.instance.primaryFocus?.unfocus();

    _logger.i("Iniciando registro de usuario: ${registerEmailController.text}");
    status.value = AuthStatus.loading;
    errorMessage.value = '';

    final result = await _authRepository.registerWithEmail(
      email: registerEmailController.text.trim(),
      password: registerPasswordController.text,
      displayName: registerNameController.text.trim(),
    );

    result.fold(
      (failure) {
        status.value = AuthStatus.error;
        errorMessage.value = _mapFailureToMessage(failure);
        _logger.e("Error en registro: ${failure.message}");
      },
      (parent) {
        status.value = AuthStatus.success;
        _sessionController.setCurrentUser(parent);
        _logger.i("Registro exitoso: ${parent.uid}");
        Get.offAllNamed(Routes.mainParent);
      },
    );
  }

  /// Método para iniciar sesión
  Future<void> login() async {
    // Ocultar teclado
    FocusManager.instance.primaryFocus?.unfocus();

    _logger.i("Iniciando sesión: ${loginEmailController.text}");
    status.value = AuthStatus.loading;
    errorMessage.value = '';

    final result = await _authRepository.signInWithEmail(
      email: loginEmailController.text.trim(),
      password: loginPasswordController.text,
    );

    result.fold(
      (failure) {
        status.value = AuthStatus.error;
        errorMessage.value = _mapFailureToMessage(failure);
        _logger.e("Error en login: ${failure.message}");
      },
      (parent) {
        status.value = AuthStatus.success;
        _sessionController.setCurrentUser(parent);
        _logger.i("Login exitoso: ${parent.uid}");
        Get.offAllNamed(Routes.mainParent);
      },
    );
  }

  /// Método para iniciar sesión con Google
  Future<void> signInWithGoogle() async {
    // Ocultar teclado
    FocusManager.instance.primaryFocus?.unfocus();

    _logger.i("Iniciando sesión con Google");
    status.value = AuthStatus.loading;
    errorMessage.value = '';

    final result = await _authRepository.signInWithGoogle();

    result.fold(
      (failure) {
        status.value = AuthStatus.error;
        errorMessage.value = _mapFailureToMessage(failure);
        _logger.e("Error en Google Sign-In: ${failure.message}");
      },
      (parent) {
        status.value = AuthStatus.success;
        _sessionController.setCurrentUser(parent);
        _logger.i("Google Sign-In exitoso: ${parent.uid}");
        Get.offAllNamed(Routes.mainParent);
      },
    );
  }

  /// Método para cerrar sesión
  Future<void> logout() async {
    _logger.i("Iniciando proceso de cierre de sesión");
    status.value = AuthStatus.loading;

    // Limpiar el controlador de perfil
    if (Get.isRegistered<ProfileController>()) {
      final profileController = Get.find<ProfileController>();
      profileController.resetProfileData();
      _logger.d("Datos de perfil reseteados");
    }

    final result = await _authRepository.signOut();

    result.fold(
      (failure) {
        status.value = AuthStatus.error;
        errorMessage.value = _mapFailureToMessage(failure);
        _logger.e("Error en cierre de sesión: ${failure.message}");
      },
      (_) {
        status.value = AuthStatus.initial;
        _sessionController.clearCurrentUser();

        // Limpiar todos los campos de formulario
        clearLoginForm();
        clearRegisterForm();
        clearResetPasswordForm();

        _logger.i("Sesión cerrada exitosamente");
        Get.offAllNamed(Routes.login);
      },
    );
  }

  /// Método para enviar correo de recuperación de contraseña
  Future<void> resetPassword() async {
    // Ocultar teclado
    FocusManager.instance.primaryFocus?.unfocus();

    _logger.i(
        "Enviando correo de recuperación: ${resetPasswordEmailController.text}");
    status.value = AuthStatus.loading;
    errorMessage.value = '';

    final result = await _authRepository
        .resetPassword(resetPasswordEmailController.text.trim());

    result.fold(
      (failure) {
        status.value = AuthStatus.error;
        errorMessage.value = _mapFailureToMessage(failure);
        _logger.e("Error enviando correo de recuperación: ${failure.message}");
      },
      (_) {
        status.value = AuthStatus.success;
        _logger.i("Correo de recuperación enviado exitosamente");

        Future.delayed(const Duration(seconds: 3), () {
          if (Get.currentRoute == Routes.resetPassword) {
            _logger.d("Regresando a la pantalla de login después de reset");
            Get.back(); // Volver a la pantalla anterior después de 3 segundos
            resetPasswordEmailController.clear();
          }
        });
      },
    );
  }

  /// Método para limpiar sólo el formulario de LOGIN
  void clearLoginForm() {
    _logger.d("Limpiando formulario de login");
    loginEmailController.clear();
    loginPasswordController.clear();
    errorMessage.value = '';
    status.value = AuthStatus.initial;
    // Restablecer visibilidad de contraseña
    loginPasswordVisible.value = false;
  }

  /// Método para limpiar sólo el formulario de REGISTRO
  void clearRegisterForm() {
    _logger.d("Limpiando formulario de registro");
    registerNameController.clear();
    registerEmailController.clear();
    registerPasswordController.clear();
    registerConfirmPasswordController.clear();
    errorMessage.value = '';
    status.value = AuthStatus.initial;
    // Restablecer visibilidad de contraseñas
    registerPasswordVisible.value = false;
    registerConfirmPasswordVisible.value = false;
  }

  /// Método para limpiar sólo el formulario de RESET PASSWORD
  void clearResetPasswordForm() {
    _logger.d("Limpiando formulario de recuperación de contraseña");
    resetPasswordEmailController.clear();
    errorMessage.value = '';
    status.value = AuthStatus.initial;
  }

  /// Mapeo de errores a mensajes legibles
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case AuthFailure:
        return failure.message;
      case ServerFailure:
        return TrKeys.serverErrorMessage.tr;
      case NetworkFailure:
        return TrKeys.connectionErrorMessage.tr;
      default:
        return TrKeys.unexpectedErrorMessage.tr;
    }
  }
}
