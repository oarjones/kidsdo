import 'package:get/get.dart';
import 'package:kidsdo/core/translations/en_translations.dart';
import 'package:kidsdo/core/translations/es_translations.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'es': esTranslations,
        'en': enTranslations,
      };
}

/// Clase para acceder a las traducciones de manera más sencilla
class Tr {
  /// Retorna la traducción de una clave específica
  static String t(String key) => key.tr;

  /// Retorna la traducción con parámetros
  static String tp(String key, Map<String, String> params) {
    String text = key.tr;
    params.forEach((key, value) {
      text = text.replaceAll('@$key', value);
    });
    return text;
  }
}

/// Claves para las traducciones, para evitar errores de escritura
class TrKeys {
  // Título de la aplicación
  static const appName = 'app_name';

  // Autenticación
  static const login = 'login';
  static const register = 'register';
  static const email = 'email';
  static const password = 'password';
  static const confirmPassword = 'confirm_password';
  static const forgotPassword = 'forgot_password';
  static const dontHaveAccount = 'dont_have_account';
  static const alreadyHaveAccount = 'already_have_account';
  static const createAccount = 'create_account';
  static const signInWithGoogle = 'sign_in_with_google';
  static const resetPassword = 'reset_password';
  static const sendResetLink = 'send_reset_link';
  static const logout = 'logout';
  static const logoutConfirmation = 'logout_confirmation';
  static const emailRequired = 'email_required';
  static const allFieldsRequired = 'all_fields_required';
  static const welcome = 'welcome';
  static const configComplete = 'config_complete';
  static const continueConfig = 'continue_config';
  static const comingSoon = 'coming_soon';
  static const comingSoonMessage = 'coming_soon_message';
  static const comingSoonSection = 'coming_soon_section';
  static const emailPasswordRequired = 'email_password_required';
  static const emailSent = 'email_sent';
  static const emailSentMessage = 'email_sent_message';

  // Validaciones
  static const requiredField = 'required_field';
  static const invalidEmail = 'invalid_email';
  static const passwordTooShort = 'password_too_short';
  static const passwordsDoNotMatch = 'passwords_do_not_match';

  static var cancel = 'cancel';
  static var name = 'name';

  //Errors
  static var serverErrorMessage = 'server_error_message';
  static var connectionErrorMessage = 'connection_error_message';
  static var unexpectedErrorMessage = 'unexpected_error_message';

  //Menú

  static var menuHome = 'menu_home';
  static var menuChallenges = 'menu_challenges';
  static var menuAwards = 'menu_awards';
  static var menuProfile = 'menu_profile';
}
