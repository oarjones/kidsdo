import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/errors/failures.dart';
import 'package:kidsdo/core/utils/form_validators.dart';
import 'package:kidsdo/domain/repositories/auth_repository.dart';
import 'package:kidsdo/presentation/controllers/session_controller.dart';
import 'package:kidsdo/routes.dart';
import 'package:kidsdo/core/translations/app_translations.dart';

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

  AuthController({
    required IAuthRepository authRepository,
    required SessionController sessionController,
  })  : _authRepository = authRepository,
        _sessionController = sessionController;

  // Estado observable
  final Rx<AuthStatus> status = Rx<AuthStatus>(AuthStatus.initial);
  final RxString errorMessage = RxString('');
  final RxBool obscurePassword = RxBool(true);
  final RxBool obscureConfirmPassword = RxBool(true);

  // Claves para los formularios - usando claves únicas para cada formulario
  final loginFormKey = GlobalKey<FormState>(debugLabel: 'loginFormKey');
  final registerFormKey = GlobalKey<FormState>(debugLabel: 'registerFormKey');
  final resetPasswordFormKey =
      GlobalKey<FormState>(debugLabel: 'resetPasswordFormKey');

  // Controladores de texto para formularios
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late TextEditingController nameController;
  late TextEditingController resetPasswordEmailController;

  // Focus nodes para gestionar el foco
  late FocusNode emailFocusNode;
  late FocusNode passwordFocusNode;
  late FocusNode confirmPasswordFocusNode;
  late FocusNode nameFocusNode;

  @override
  void onInit() {
    super.onInit();
    // Inicializar controladores
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    nameController = TextEditingController();
    resetPasswordEmailController = TextEditingController();

    // Inicializar focus nodes
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    confirmPasswordFocusNode = FocusNode();
    nameFocusNode = FocusNode();

    // Listeners para limpiar mensajes de error al modificar campos
    emailController.addListener(_clearErrorOnChange);
    passwordController.addListener(_clearErrorOnChange);
    confirmPasswordController.addListener(_clearErrorOnChange);
    nameController.addListener(_clearErrorOnChange);
  }

  @override
  void onClose() {
    // Liberar controladores
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    resetPasswordEmailController.dispose();

    // Liberar focus nodes
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    nameFocusNode.dispose();

    super.onClose();
  }

  /// Limpia el mensaje de error cuando el usuario modifica algún campo
  void _clearErrorOnChange() {
    if (errorMessage.isNotEmpty) {
      errorMessage.value = '';
    }
  }

  /// Toggle para mostrar/ocultar contraseña
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  /// Toggle para mostrar/ocultar confirmación de contraseña
  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
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
    return FormValidators.confirmPassword(value, passwordController.text);
  }

  /// Validador para campo de nombre
  String? validateName(String? value) {
    return FormValidators.name(value);
  }

  /// Método para registrar un nuevo usuario
  Future<void> register() async {
    // Ocultar teclado
    FocusManager.instance.primaryFocus?.unfocus();

    // Validar formulario con validaciones de Flutter
    if (!registerFormKey.currentState!.validate()) {
      return;
    }

    status.value = AuthStatus.loading;
    errorMessage.value = '';

    final result = await _authRepository.registerWithEmail(
      email: emailController.text.trim(),
      password: passwordController.text,
      displayName: nameController.text.trim(),
    );

    result.fold(
      (failure) {
        status.value = AuthStatus.error;
        errorMessage.value = _mapFailureToMessage(failure);
      },
      (parent) {
        status.value = AuthStatus.success;
        _sessionController.setCurrentUser(parent);
        Get.offAllNamed(Routes.home);
      },
    );
  }

  /// Método para iniciar sesión
  Future<void> login() async {
    // Ocultar teclado
    FocusManager.instance.primaryFocus?.unfocus();

    // Validar formulario con validaciones de Flutter
    if (!loginFormKey.currentState!.validate()) {
      return;
    }

    status.value = AuthStatus.loading;
    errorMessage.value = '';

    final result = await _authRepository.signInWithEmail(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    result.fold(
      (failure) {
        status.value = AuthStatus.error;
        errorMessage.value = _mapFailureToMessage(failure);
      },
      (parent) {
        status.value = AuthStatus.success;
        _sessionController.setCurrentUser(parent);
        Get.offAllNamed(Routes.home);
      },
    );
  }

  /// Método para iniciar sesión con Google
  Future<void> signInWithGoogle() async {
    // Ocultar teclado
    FocusManager.instance.primaryFocus?.unfocus();

    status.value = AuthStatus.loading;
    errorMessage.value = '';

    final result = await _authRepository.signInWithGoogle();

    result.fold(
      (failure) {
        status.value = AuthStatus.error;
        errorMessage.value = _mapFailureToMessage(failure);
      },
      (parent) {
        status.value = AuthStatus.success;
        _sessionController.setCurrentUser(parent);
        Get.offAllNamed(Routes.home);
      },
    );
  }

  /// Método para cerrar sesión
  Future<void> logout() async {
    status.value = AuthStatus.loading;

    final result = await _authRepository.signOut();

    result.fold(
      (failure) {
        status.value = AuthStatus.error;
        errorMessage.value = _mapFailureToMessage(failure);
      },
      (_) {
        status.value = AuthStatus.initial;
        _sessionController.clearCurrentUser();
        Get.offAllNamed(Routes.login);
      },
    );
  }

  /// Método para enviar correo de recuperación de contraseña
  Future<void> resetPassword() async {
    // Ocultar teclado
    FocusManager.instance.primaryFocus?.unfocus();

    // Validar formulario
    if (!resetPasswordFormKey.currentState!.validate()) {
      return;
    }

    status.value = AuthStatus.loading;
    errorMessage.value = '';

    final result = await _authRepository
        .resetPassword(resetPasswordEmailController.text.trim());

    result.fold(
      (failure) {
        status.value = AuthStatus.error;
        errorMessage.value = _mapFailureToMessage(failure);
      },
      (_) {
        status.value = AuthStatus.success;
        // No cerramos la pantalla, mostramos mensaje de éxito
        // La pantalla resetPassword mostrará un mensaje basado en este estado

        Future.delayed(const Duration(seconds: 3), () {
          if (Get.currentRoute == Routes.resetPassword) {
            Get.back(); // Volver a la pantalla anterior después de 3 segundos
            resetPasswordEmailController.clear();
          }
        });
      },
    );
  }

  /// Método para limpiar los campos del formulario
  void clearForm() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
    resetPasswordEmailController.clear();
    status.value = AuthStatus.initial;
    errorMessage.value = '';
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
