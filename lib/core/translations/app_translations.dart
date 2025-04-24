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
  static const appSlogan = 'app_slogan';

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
  static const resetPasswordDescription = 'reset_password_description';
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
  static const backToLogin = 'back_to_login';
  static const or = 'or';
  static const registerSubtitle = 'register_subtitle';
  static const registerTermsPrivacy = 'register_terms_privacy';
  static const nameTooShort = 'name_too_short';
  static const invalidPhone = 'invalid_phone';

  // Validaciones
  static const requiredField = 'required_field';
  static const invalidEmail = 'invalid_email';
  static const passwordTooShort = 'password_too_short';
  static const passwordsDoNotMatch = 'passwords_do_not_match';

  // Perfil
  static const profile = 'profile';
  static const editProfile = 'edit_profile';
  static const name = 'name';
  static const age = 'age';
  static const birthDate = 'birth_date';
  static const selectAvatar = 'select_avatar';

  // Familia
  static const family = 'family';
  static const createFamily = 'create_family';
  static const familyName = 'family_name';
  static const addChild = 'add_child';
  static const childName = 'child_name';
  static const createChildProfile = 'create_child_profile';

  // Retos
  static const challenges = 'challenges';
  static const createChallenge = 'create_challenge';
  static const editChallenge = 'edit_challenge';
  static const challengeTitle = 'challenge_title';
  static const challengeDescription = 'challenge_description';
  static const points = 'points';
  static const category = 'category';
  static const frequency = 'frequency';
  static const assignTo = 'assign_to';
  static const startDate = 'start_date';
  static const endDate = 'end_date';
  static const status = 'status';

  // General
  static const save = 'save';
  static const cancel = 'cancel';
  static const delete = 'delete';
  static const edit = 'edit';
  static const ok = 'ok';
  static const confirm = 'confirm';
  static const loading = 'loading';
  static const noData = 'no_data';
  static const error = 'error';
  static const success = 'success';
  static const warning = 'warning';
  static const info = 'info';

  // Errores
  static const serverErrorMessage = 'server_error_message';
  static const connectionErrorMessage = 'connection_error_message';
  static const unexpectedErrorMessage = 'unexpected_error_message';

  // Menú
  static const menuHome = 'menu_home';
  static const menuChallenges = 'menu_challenges';
  static const menuAwards = 'menu_awards';
  static const menuProfile = 'menu_profile';

  // Perfil
  // static const profile = 'profile';
  // static const editProfile = 'edit_profile';
  // static const name = 'name';
  // static const age = 'age';
  // static const birthDate = 'birth_date';
  // static const selectAvatar = 'select_avatar';
  static const selectImageSource = 'select_image_source';
  static const gallery = 'gallery';
  static const camera = 'camera';
  static const retry = 'retry';
  static const noProfileData = 'no_profile_data';
  static const errorSelectingImage = 'error_selecting_image';
  static const errorCapturingImage = 'error_capturing_image';
  static const errorUploadingImage = 'error_uploading_image';
  static const children = 'children';
  static const accountCreated = 'account_created';
  static const familyCreated = 'family_created';
  static const noFamily = 'no_family';
  static const profileUpdatedSuccessfully = 'profile_updated_successfully';
  static const notifications = 'notifications';
  static const privacy = 'privacy';
  static const help = 'help';
  static const sessionExpired = 'session_expired';

  // Familia - nuevas claves
  static const familyCreatedTitle = 'family_created_title';
  static const familyCreatedMessage = 'family_created_message';
  static const familyJoinedTitle = 'family_joined_title';
  static const familyJoinedMessage = 'family_joined_message';
  static const familyLeftTitle = 'family_left_title';
  static const familyLeftMessage = 'family_left_message';
  static const familyNameTooShort = 'family_name_too_short';
  static const invalidInviteCode = 'invalid_invite_code';
  static const notLoggedIn = 'not_logged_in';
  static const alreadyInFamily = 'already_in_family';
  static const familyNotFound = 'family_not_found';
  static const creatorCantLeave = 'creator_cant_leave';
  static const createFamilyActionButton = 'create_family_action_button';
  static const joinFamilyActionButton = 'join_family_action_button';
  static const generateCodeActionButton = 'generate_code_action_button';
  static const leaveFamilyActionButton = 'leave_family_action_button';
}
