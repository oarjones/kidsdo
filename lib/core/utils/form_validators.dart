import 'package:get/get.dart';
import 'package:kidsdo/core/translations/app_translations.dart';

/// Utilitario para validación de formularios
class FormValidators {
  /// Validador para campos requeridos
  static String? required(String? value) {
    if (value == null || value.isEmpty) {
      return TrKeys.requiredField.tr;
    }
    return null;
  }

  /// Validador para emails
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return TrKeys.requiredField.tr;
    }
    if (!GetUtils.isEmail(value)) {
      return TrKeys.invalidEmail.tr;
    }
    return null;
  }

  /// Validador para contraseñas (mínimo 6 caracteres)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return TrKeys.requiredField.tr;
    }
    if (value.length < 6) {
      return TrKeys.passwordTooShort.tr;
    }
    return null;
  }

  /// Validador para confirmar contraseña
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return TrKeys.requiredField.tr;
    }
    if (value != password) {
      return TrKeys.passwordsDoNotMatch.tr;
    }
    return null;
  }

  /// Validador para nombres
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return TrKeys.requiredField.tr;
    }
    if (value.length < 2) {
      return 'name_too_short'.tr;
    }
    return null;
  }

  /// Validador para números de teléfono
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return TrKeys.requiredField.tr;
    }
    if (!GetUtils.isPhoneNumber(value)) {
      return 'invalid_phone'.tr;
    }
    return null;
  }
}
