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

  // Nuevas claves para la UI de gestión de familias
  static const familyInfoText = 'family_info_text';
  static const familyRoleCreator = 'family_role_creator';
  static const familyRoleMember = 'family_role_member';
  static const familyMembersCount = 'family_members_count';
  static const familyMembers = 'family_members';
  static const familyInviteCode = 'family_invite_code';
  static const familyCreatedOn = 'family_created_on';
  static const createFamilyDescription = 'create_family_description';
  static const familyCreatorInfo = 'family_creator_info';
  static const familyInfoTitle = 'family_info_title';
  static const joinFamily = 'join_family';
  static const joinFamilyDescription = 'join_family_description';
  static const inviteCode = 'invite_code';
  static const inviteCodeExampleTitle = 'invite_code_example_title';
  static const joinFamilyInfoTitle = 'join_family_info_title';
  static const joinFamilyInfoContent = 'join_family_info_content';
  static const familyInviteCodePageTitle = 'family_invite_code_page_title';
  static const familyInviteCodeTitle = 'family_invite_code_title';
  static const familyInviteCodeDescription = 'family_invite_code_description';
  static const currentInviteCode = 'current_invite_code';
  static const copyToClipboard = 'copy_to_clipboard';
  static const codeValidInfo = 'code_valid_info';
  static const noInviteCode = 'no_invite_code';
  static const generateInviteCodeMessage = 'generate_invite_code_message';
  static const regenerateInviteCode = 'regenerate_invite_code';
  static const inviteCodeWarningTitle = 'invite_code_warning_title';
  static const inviteCodeWarningContent = 'invite_code_warning_content';
  static const codeCopiedTitle = 'code_copied_title';
  static const codeCopiedMessage = 'code_copied_message';
  static const leaveFamilyTitle = 'leave_family_title';
  static const leaveFamilyConfirmation = 'leave_family_confirmation';
  static const leaveFamilyConfirm = 'leave_family_confirm';

  // Nuevas claves para visualización de miembros
  static const noFamilyMembersFound = 'no_family_members_found';
  static const familyCreatorLabel = 'family_creator_label';
  static const familyParentLabel = 'family_parent_label';
  static const familyChildLabel = 'family_child_label';
  static const errorLoadingFamilyMembers = 'error_loading_family_members';

  // Claves para perfiles infantiles
  static const childProfiles = 'child_profiles';
  static const manageChildProfiles = 'manage_child_profiles';
  static const addChildProfilesMessage = 'add_child_profiles_message';
  static const noChildProfiles = 'no_child_profiles';
  static const yearsOld = 'years_old';
  static const level = 'level';
  static const childProfileTheme = 'child_profile_theme';
  static const editChildProfile = 'edit_child_profile';
  static const viewChildChallenges = 'view_child_challenges';
  static const viewChildRewards = 'view_child_rewards';
  static const accessChildMode = 'access_child_mode';
  static const deleteChildProfile = 'delete_child_profile';
  static const confirmDeleteProfile = 'confirm_delete_profile';
  static const confirmDeleteProfileMessage = 'confirm_delete_profile_message';
  static const childProfileNoFamilyUser = 'child_profile_no_family_user';
  static const childProfileCreatedTitle = 'child_profile_created_title';
  static const childProfileCreatedMessage = 'child_profile_created_message';
  static const childProfileUpdatedTitle = 'child_profile_updated_title';
  static const childProfileUpdatedMessage = 'child_profile_updated_message';
  static const childProfileDeletedTitle = 'child_profile_deleted_title';
  static const childProfileDeletedMessage = 'child_profile_deleted_message';

  // Claves para interfaz infantil y acceso
  static const selectAvatarOption = 'select_avatar_option';
  static const themeStyle = 'theme_style';
  static const themeColor = 'theme_color';
  static const interfaceSize = 'interface_size';
  static const themeStyleDefault = 'theme_style_default';
  static const themeStyleSpace = 'theme_style_space';
  static const themeStyleSea = 'theme_style_sea';
  static const themeStyleJungle = 'theme_style_jungle';
  static const themeStylePrincess = 'theme_style_princess';
  static const interfaceSizeSmall = 'interface_size_small';
  static const interfaceSizeMedium = 'interface_size_medium';
  static const interfaceSizeLarge = 'interface_size_large';
  static const themePreview = 'theme_preview';
  static const previewGreeting = 'preview_greeting';
  static const previewSubtitle = 'preview_subtitle';
  static const previewChallenge1 = 'preview_challenge1';
  static const previewChallenge2 = 'preview_challenge2';
  static const previewButton = 'preview_button';
  static const childNamePreview = 'child_name_preview';
  static const whoIsUsing = 'who_is_using';
  static const selectProfileMessage = 'select_profile_message';
  static const accessProfile = 'access_profile';
  static const parentMode = 'parent_mode';
  static const enterParentalPin = 'enter_parental_pin';
  static const enterParentalPinMessage = 'enter_parental_pin_message';
  static const pin = 'pin';
  static const incorrectPin = 'incorrect_pin';
  static const incorrectPinMessage = 'incorrect_pin_message';
  static const noChildProfilesAccess = 'no_child_profiles_access';
  static const noChildProfilesAccessMessage =
      'no_child_profiles_access_message';
  static const switchProfile = 'switch_profile';
  static const parentAccess = 'parent_access';
  static const goodMorning = 'good_morning';
  static const goodAfternoon = 'good_afternoon';
  static const goodEvening = 'good_evening';
  static const childDashboardSubtitle = 'child_dashboard_subtitle';
  static const yourPoints = 'your_points';
  static const nextLevel = 'next_level';
  static const yourChallenges = 'your_challenges';
  static const yourRewards = 'your_rewards';
  static const viewAll = 'view_all';
  static const dailyChallenge = 'daily_challenge';
  static const weeklyChallenge = 'weekly_challenge';
  static const challengeExample1 = 'challenge_example1';
  static const challengeExample2 = 'challenge_example2';
  static const challengeExample3 = 'challenge_example3';
  static const rewardExample1 = 'reward_example1';
  static const rewardExample2 = 'reward_example2';
  static const menuAchievements = 'menu_achievements';

  // Claves para Control Parental
  static const parentalControl = 'parental_control';
  static const parentalPinSectionTitle = 'parental_pin_section_title';
  static const useParentalPin = 'use_parental_pin';
  static const useParentalPinDescription = 'use_parental_pin_description';
  static const changeParentalPin = 'change_parental_pin';
  static const recoveryEmail = 'recovery_email';
  static const recoveryEmailHint = 'recovery_email_hint';
  static const timeRestrictionsTitle = 'time_restrictions_section_title';
  static const useTimeRestrictions = 'use_time_restrictions';
  static const useTimeRestrictionsDescription =
      'use_time_restrictions_description';
  static const startTime = 'start_time';
  static const endTime = 'end_time';
  static const maxSessionTime = 'max_session_time';
  static const maxSessionTimeDescription = 'max_session_time_description';
  static const profileBlockTitle = 'profile_block_section_title';
  static const profileBlockDescription = 'profile_block_description';
  static const profileBlocked = 'profile_blocked';
  static const profileUnblocked = 'profile_unblocked';
  static const contentRestrictionsTitle = 'content_restrictions_section_title';
  static const restrictPremiumContent = 'restrict_premium_content';
  static const restrictPremiumContentDesc =
      'restrict_premium_content_description';
  static const moreContentRestrictions = 'more_content_restrictions';
  static const setParentalPin = 'set_parental_pin';
  static const setParentalPinDescription = 'set_parental_pin_description';
  static const changeParentalPinDesc = 'change_parental_pin_description';
  static const currentPin = 'current_pin';
  static const newPin = 'new_pin';
  static const confirmPin = 'confirm_pin';
  static const invalidPinFormatTitle = 'invalid_pin_format_title';
  static const invalidPinFormatMessage = 'invalid_pin_format_message';
  static const pinMismatchTitle = 'pin_mismatch_title';
  static const pinMismatchMessage = 'pin_mismatch_message';
  static const pinChangedTitle = 'pin_changed_title';
  static const pinChangedMessage = 'pin_changed_message';
  static const pinChangeErrorTitle = 'pin_change_error_title';
  static const parentalPinIncorrect = 'parental_pin_incorrect';
  static const parentalPinIncorrectAttempts = 'parental_pin_incorrect_attempts';
  static const parentalControlLockedTitle = 'parental_control_locked_title';
  static const parentalControlTemporarilyLocked =
      'parental_control_temporarily_locked';
  static const settingsSavedTitle = 'settings_saved_title';
  static const settingsSavedMessage = 'settings_saved_message';
  static const settingsSaveErrorTitle = 'settings_save_error_title';
  static const errorLoadingProfiles = 'error_loading_profiles';
  static const noChildrenProfiles = 'no_children_profiles';

  // Restricciones de tiempo
  static const timeRestrictionTitle = 'time_restriction_title';
  static const timeRestrictionSuggestion = 'time_restriction_suggestion';
  static const timeRestrictionSuggestionDetail =
      'time_restriction_suggestion_detail';
  static const goToHome = 'go_to_home';
  static const parentalControlTimeRestricted =
      'parental_control_time_restricted';
  static const sessionTimeInfoTitle = 'session_time_info_title';
  static const sessionTimeInfoMessage = 'session_time_info_message';
  static const sessionTimeWarningTitle = 'session_time_warning_title';
  static const sessionTimeWarningMessage = 'session_time_warning_message';
  static const sessionTimeExceededTitle = 'session_time_exceeded_title';
  static const sessionTimeExceededMessage = 'session_time_exceeded_message';
  static const timeRestrictionDefaultMessage =
      'time_restriction_default_message';

  // Perfiles bloqueados
  static const profileBlockedTitle = 'profile_blocked_title';
  static const profileBlockedMessage = 'profile_blocked_message';
  static const childProfileBlocked = 'child_profile_blocked';
  static const temporaryBlockTitle = 'temporary_block_title';
  static const accessBlockedTitle = 'access_blocked_title';
  static const parentUnlockTitle = 'parent_unlock_title';
  static const parentUnlockDescription = 'parent_unlock_description';
  static const parentUnlock = 'parent_unlock';
}
