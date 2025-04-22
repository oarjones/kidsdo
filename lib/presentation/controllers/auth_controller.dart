import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/errors/failures.dart';
//import 'package:kidsdo/domain/entities/parent.dart';
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

  // Controladores de texto para formularios
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late TextEditingController nameController;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    nameController = TextEditingController();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    super.onClose();
  }

  /// Toggle para mostrar/ocultar contraseña
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  /// Método para registrar un nuevo usuario
  Future<void> register() async {
    // Validar formulario
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      errorMessage.value = TrKeys.allFieldsRequired.tr;
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      errorMessage.value = TrKeys.passwordsDoNotMatch.tr;
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
    // Validar formulario
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      errorMessage.value = TrKeys.emailPasswordRequired.tr;
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
  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      errorMessage.value = TrKeys.emailRequired.tr;
      return;
    }

    status.value = AuthStatus.loading;
    errorMessage.value = '';

    final result = await _authRepository.resetPassword(email);

    result.fold(
      (failure) {
        status.value = AuthStatus.error;
        errorMessage.value = _mapFailureToMessage(failure);
      },
      (_) {
        status.value = AuthStatus.success;
        Get.snackbar(
          TrKeys.emailSent.tr,
          TrKeys.emailSentMessage.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      },
    );
  }

  /// Método para limpiar los campos del formulario
  void clearForm() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
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
