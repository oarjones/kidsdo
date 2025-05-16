import 'dart:ui';

import 'package:get/get.dart';
import 'package:kidsdo/core/translations/en_translations.dart';
import 'package:kidsdo/core/translations/es_translations.dart';

class AppTranslations extends Translations {
  // Define los locales soportados por la aplicación.
  // Esta lista será la fuente de verdad para los idiomas soportados.
  static final List<Locale> locales = [
    const Locale('es', 'ES'), // Español (España)
    const Locale('en', 'US'), // Inglés (Estados Unidos)
    // Añade más locales aquí si los soportas
  ];

  // Locale por defecto si el locale del dispositivo no está soportado.
  // Debe ser uno de los `locales` definidos arriba.
  static final Locale fallbackLocale = locales
      .firstWhere((l) => l.languageCode == 'es', orElse: () => locales.first);

  @override
  Map<String, Map<String, String>> get keys => {
        // Usa los languageTags completos para las claves principales del mapa
        'es_ES':
            esTranslations, // Asumiendo que esTranslations es Map<String, String>
        'en_US':
            enTranslations, // Asumiendo que enTranslations es Map<String, String>
        // Mapea también solo el código de idioma si quieres un fallback más simple
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
  static const challenge = 'challenge';
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

  // Biblioteca de retos
  static const challengeLibrary = 'challenge_library';
  static const filterChallenges = 'filter_challenges';
  static const searchChallenges = 'search_challenges';
  static const importChallenges = 'import_challenges';
  static const exportChallenges = 'export_challenges';
  static const selectAll = 'select_all';
  static const clearSelection = 'clear_selection';
  static const allCategories = 'all_categories';
  static const allFrequencies = 'all_frequencies';
  static const ageRange = 'age_range';
  static const years = 'years';
  static const ageAppropriate = 'age_appropriate';
  static const showOnlyAgeAppropriate = 'show_only_age_appropriate';
  static const ageAppropriateExplanation = 'age_appropriate_explanation';
  static const ageRangeExplanation = 'age_range_explanation';
  static const childAge = 'child_age';
  static const resetFilters = 'reset_filters';
  static const applyFilters = 'apply_filters';
  static const clearAllFilters = 'clear_all_filters';
  static const challengeFound = 'challenge_found';
  static const challengesFound = 'challenges_found';
  static const noChallengesFound = 'no_challenges_found';
  static const tryChangingFilters = 'try_changing_filters';
  static const addToFamily = 'add_to_family';
  static const details = 'details';
  static const description = 'description';
  static const challengeDetails = 'challenge_details';
  static const originalPoints = 'original_points';
  static const adaptedPoints = 'adapted_points';
  static const import = 'import';
  static const export = 'export';
  static const importToFamily = 'import_to_family';
  static const exportSelected = 'export_selected';
  static const importSelectedConfirmation = 'import_selected_confirmation';
  static const importSuccess = 'import_success';
  static const challengesImported = 'challenges_imported';
  static const exportSuccess = 'export_success';
  static const challengesExported = 'challenges_exported';
  static const exportFiltered = 'export_filtered';
  static const exportAll = 'export_all';
  static const numberOfChallenges = 'number_of_challenges';
  static const exportResult = 'export_result';

  static const copied = 'copied';
  static const jsonCopied = 'json_copied';
  static const close = 'close';
  static const selected = 'selected';
  static const select = 'select';
  static const importInstructions = 'import_instructions';
  static const pasteJsonHere = 'paste_json_here';
  static const importErrorTitle = 'import_error_title';
  static const importErrorMessage = 'import_error_message';
  static const exportErrorTitle = 'export_error_title';
  static const exportErrorMessage = 'export_error_message';

  // Categorías de retos
  static const categoryHygiene = 'category_hygiene';
  static const categorySchool = 'category_school';
  static const categoryOrder = 'category_order';
  static const categoryResponsibility = 'category_responsibility';
  static const categoryHelp = 'category_help';
  static const categorySpecial = 'category_special';
  static const categorySibling = 'category_sibling';

  // Frecuencias de retos
  static const frequencyDaily = 'frequency_daily';
  static const frequencyWeekly = 'frequency_weekly';
  static const frequencyMonthly = 'frequency_monthly';
  static const frequencyQuarterly = 'frequency_quarterly';
  static const frequencyOnce = 'frequency_once';

  // Sincronización de retos
  static const cloudDataSource = 'cloud_data_source';
  static const localDataSource = 'local_data_source';
  static const loadingDataSource = 'loading_data_source';
  static const syncWithCloud = 'sync_with_cloud';
  static const cloudSync = 'cloud_sync';
  static const cloudSyncInfo = 'cloud_sync_info';
  static const cloudSyncActive = 'cloud_sync_active';
  static const syncInProgress = 'sync_in_progress';
  static const syncSuccess = 'sync_success';
  static const syncFailed = 'sync_failed';
  static const templateSavedTitle = 'template_saved_title';
  static const templateSavedMessage = 'template_saved_message';
  static const templateSaveRequiresCloud = 'template_save_requires_cloud';
  static const jsonExported = "json_exported";

  // Crear/Editar Retos
  static const createEditChallengeTitle = 'create_edit_challenge_title';
// static const createChallenge = 'create_challenge';
// static const editChallenge = 'edit_challenge';
// static const challengeTitle = 'challenge_title';
  static const enterChallengeTitle = 'enter_challenge_title';
  static const enterChallengeDescription = 'enter_challenge_description';
  static const selectCategory = 'select_category';
  static const selectFrequency = 'select_frequency';
  static const assignToChild = 'assign_to_child';
  static const selectChild = 'select_child';
  static const enterPoints = 'enter_points';
  static const selectAgeRange = 'select_age_range';
  static const minAge = 'min_age';
  static const maxAge = 'max_age';
  static const saveAsTemplate = 'save_as_template';
  static const saveAsTemplateDesc = 'save_as_template_desc';
  static const selectIcon = 'select_icon';
  static const challengeCreatedTitle = 'challenge_created_title';
  static const challengeCreatedMessage = 'challenge_created_message';
  static const challengeUpdatedTitle = 'challenge_updated_title';
  static const challengeUpdatedMessage = 'challenge_updated_message';
  static const challengeDeletedTitle = 'challenge_deleted_title';
  static const challengeDeletedMessage = 'challenge_deleted_message';

// Asignar Retos
  static const assignChallengeTitle = 'assign_challenge_title';
  static const selectStartDate = 'select_start_date';
  static const selectEndDate = 'select_end_date';
  static const selectEvaluationFrequency = 'select_evaluation_frequency';
  static const dailyEvaluation = 'daily_evaluation';
  static const weeklyEvaluation = 'weekly_evaluation';
  static const assignChallenge = 'assign_challenge';
  static const challengeAssignedTitle = 'challenge_assigned_title';
  static const challengeAssignedMessage = 'challenge_assigned_message';
  static const noChildrenAvailable = 'no_children_available';
  static const noChildrenAvailableMessage = 'no_children_available_message';
  static const createChildProfileFirst = 'create_child_profile_first';

// Panel de Control de Retos
  static const activeChallenges = 'active_challenges';
  static const activeChallengesEmpty = 'active_challenges_empty';
  static const activeChallengesEmptyMessage = 'active_challenges_empty_message';
  static const filterByChild = 'filter_by_child';
  static const filterByStatus = 'filter_by_status';
  static const evaluateChallenge = 'evaluate_challenge';
  static const evaluateChallengeTitle = 'evaluate_challenge_title';
  static const completed = 'completed';
  static const failed = 'failed';
  static const pending = 'pending';
  static const addNote = 'add_note';
  static const evaluationNote = 'evaluation_note';
  static const assignedTo = 'assigned_to';
  static const dueDate = 'due_date';
  static const createdOn = 'created_on';
  static const lastEvaluation = 'last_evaluation';
  static const noEvaluationsYet = 'no_evaluations_yet';
  static const deleteAssignedChallengeTitle = 'delete_assigned_challenge_title';
  static const deleteAssignedChallengeMessage =
      'delete_assigned_challenge_message';
  static const today = 'today';
  static const tomorrow = 'tomorrow';
  static const yesterday = 'yesterday';
  static const days = 'days';
  static const daysAgo = 'days_ago';
  static const daysLeft = 'days_left';
  static const noAssignedChallenges = 'no_assigned_challenges';
  static const noAssignedChallengesMessage = 'no_assigned_challenges_message';

  static const refresh = 'refresh';
  static const active = 'active';

  static const challengesPageSubtitle =
      'challenges_page_subtitle'; //      'Manage and visualize challenges to promote good habits',
  static const activeChallengesLabel =
      'active_challenges_label'; // 'Active challenges',
  static const exploreChallengeLibrary =
      'explore_challenge_library'; // 'Explore the predefined challenge library',
  static const createCustomChallenges =
      'create_custom_challenges'; // 'Create custom challenges',
  static const activeChallengesStat =
      'active_challenges_stat'; // 'Active challenges',
  static const completedChallengesStat =
      'completed_challenges_stat'; // 'Completed challenges',
  static const libraryChallengesStat =
      'library_challenges_stat'; // 'Library challenges',
  static const challengesAsignedVisualEval = 'challenges_asigned_visual_eval';

  // UI de retos para niños
  static const markAsCompleted = 'mark_as_completed';
  static const pendingApproval = 'pending_approval';
  static const waitingForParentApproval = 'waiting_for_parent_approval';
  static const totalChallenges = 'total_challenges';
  static const yourProgress = 'your_progress';
  // static const noChallengesFound = 'no_challenges_found';
  static const noCompletedChallengesYet = 'no_completed_challenges_yet';
  static const noChallengesMatchFilter = 'no_challenges_match_filter';
  static const showAllChallenges = 'show_all_challenges';
  static const pointsEarned = 'points_earned';
  static const awesome = 'awesome';
  static const challengeCompleted = 'challenge_completed';
  static const all = 'all';

  static const assignToChildren = 'assign_to_children';
  static const andOthers = 'and_others';
  static const assignChallengeNow = 'assign_challenge_now';
  static const notNow = 'not_now';
  static const assign = 'assign';

  static const continuousChallenge = 'continuous_challenge';
  static const neverEnds = 'never_ends';
  static const challengeSingular = 'challenge_singular';
  static const challengesPlural = 'challenges_plural';

  // Claves para duraciones de retos
  static const challengeDuration = 'challenge_duration';
  static const durationWeekly = 'duration_weekly';
  static const durationMonthly = 'duration_monthly';
  static const durationQuarterly = 'duration_quarterly';
  static const durationYearly = 'duration_yearly';
  static const durationPunctual = 'duration_punctual';

  // Explicaciones de duraciones
  static const durationWeeklyExplanation = 'duration_weekly_explanation';
  static const durationMonthlyExplanation = 'duration_monthly_explanation';
  static const durationQuarterlyExplanation = 'duration_quarterly_explanation';
  static const durationYearlyExplanation = 'duration_yearly_explanation';
  static const durationPunctualExplanation = 'duration_punctual_explanation';

  // Textos para retos continuos
  //static const continuousChallenge = 'continuous_challenge';
  static const continuousChallengeExplanation =
      'continuous_challenge_explanation';
  //static const neverEnds = 'never_ends';

  // Textos de repetición
  static const durationWeeklyRepeat = 'duration_weekly_repeat';
  static const durationMonthlyRepeat = 'duration_monthly_repeat';
  static const durationQuarterlyRepeat = 'duration_quarterly_repeat';
  static const durationYearlyRepeat = 'duration_yearly_repeat';
  static const durationPunctualRepeat = 'duration_punctual_repeat';

  // Estados adicionales
  static const inactive = 'inactive';

  // Evaluación de ejecuciones
  static const currentExecution = 'current_execution';
  static const execution = 'execution';
  static const evaluatingExecution = 'evaluating_execution';
  static const evaluationPeriod = 'evaluation_period';
  static const nextExecutionInfo = 'next_execution_info';
  static const nextExecutionExplanation = 'next_execution_explanation';

  // Advertencias
  static const punctualTemplateWarning = 'punctual_template_warning';

  // Nuevas claves para evaluación de ejecuciones
  static const evaluateExecution = 'evaluate_execution';
  static const selectExecutionToEvaluate = 'select_execution_to_evaluate';
  // static const execution = 'execution';
  // static const currentExecution = 'current_execution';
  static const evaluations = 'evaluations';
  static const challengePointsSummary = 'challenge_points_summary';
  static const totalPointsAccumulated = 'total_points_accumulated';
  static const pointsThisExecution = 'points_this_execution';
  static const assignPoints = 'assign_points';
  static const original = 'original';
  static const continuousChallengeInfo = 'continuous_challenge_info';
  static const nextExecutionStartsAt = 'next_execution_starts_at';

  static const day = 'day';
  static const week = 'week';
  static const weeks = 'weeks';
  static const month = 'month';
  static const months = 'months';

  // static const continuousChallenge = 'continuous_challenge';
  // static const neverEnds = 'never_ends';
  static const currentPeriod = 'current_period';
  static const nextPeriodStarts = 'next_period_starts';
  static const willRenewSoon = 'will_renew_soon';
  static const comesBackSoon = 'comes_back_soon';
  static const notStartedYet = 'not_started_yet';
  static const timeExpired = 'time_expired';
  static const lastDay = 'last_day';
  static const oneDayLeft = 'one_day_left';
  // static const daysLeft = 'days_left';
  static const finished = 'finished';
  static const hurryUp = 'hurry_up';
  static const fewDaysLeft = 'few_days_left';
  static const plentyOfTime = 'plenty_of_time';
  static const timeIsUp = 'time_is_up';
  static const littleTimeLeft = 'little_time_left';
  // static const continuousChallengeInfo = 'continuous_challenge_info';
  static const continuousChallengeInfoSimple =
      'continuous_challenge_info_simple';
  // static const day = 'day';
  static const noContinuousChallengesYet = 'no_continuous_challenges_yet';
  static const manyDaysLeft = 'many_days_left';
  static const noChildSelected = 'no_child_selected';

  static const batchEvaluationPageTitle = 'batch_evaluation_page_title';
  static const batchEvaluationPageDescription =
      'batch_evaluation_page_description';
  static const evaluationNoteOptionalHint = 'evaluation_note_optional_hint';
  static void batchEvaluationFilterChildSelected =
      'batch_evaluation_filter_child_selected';

  static const streamGenericError = 'stream_generic_error';
  static const userNotAuthenticatedError = 'user_not_authenticated_error';
  static const pointsAdjustedTitle = 'points_adjusted_title';
  static const pointsAdjustedMessage =
      'points_adjusted_message'; // Con parámetros: @childName, @points
  static const authGenericError =
      'auth_generic_error'; // Podrías tener una más general ya

  // Nuevas claves para el módulo de recompensas (ejemplos)
  static const rewardsTitle = 'rewards_title';
  static const createRewardTitle = 'create_reward_title';
  static const editRewardTitle = 'edit_reward_title';
  static const rewardNameLabel = 'reward_name_label';
  static const rewardDescriptionLabel = 'reward_description_label';
  static const rewardPointsRequiredLabel = 'reward_points_required_label';
  static const rewardTypeLabel = 'reward_type_label';
  static const rewardIconLabel = 'reward_icon_label';
  static const rewardIsUniqueLabel = 'reward_is_unique_label';
  static const rewardIsEnabledLabel = 'reward_is_enabled_label';
  static const rewardTypeSimple = 'reward_type_simple';
  static const rewardTypeProduct = 'reward_type_product';
  static const rewardTypeExperience = 'reward_type_experience';
  static const rewardTypeDigitalAccess = 'reward_type_digital_access';
  static const rewardTypeLongTermGoal = 'reward_type_long_term_goal';
  static const rewardTypeSurprise = 'reward_type_surprise';
  static const manageRewards = 'manage_rewards';
  static const noRewardsAvailable = 'no_rewards_available';
  static const addFirstReward = 'add_first_reward';
  static const confirmDeleteRewardTitle = 'confirm_delete_reward_title';
  static const confirmDeleteRewardMessage =
      'confirm_delete_reward_message'; // Parámetro: @rewardName
  static const adjustPointsTitle = 'adjust_points_title';
  static const pointsToAdjustLabel = 'points_to_adjust_label';
  static const currentPointsLabel =
      'current_points_label'; // Parámetro: @points
  static const rewardCreatedSuccess = 'reward_created_success';
  static const rewardUpdatedSuccess = 'reward_updated_success';
  static const rewardDeletedSuccess = 'reward_deleted_success';

  static const pointsSuffix =
      'points_suffix'; // Sufijo para puntos, por ejemplo: "puntos"
  static const rewardDisabledHint =
      'reward_disabled_hint'; // Mensaje que indica que la recompensa está deshabilitada
  static const predefinedRewardsTitle =
      'predefined_rewards_title'; // Título para la biblioteca de recompensas predefinidas

// --- Recompensas: Gestión y Lista ---
// --- Recompensas: Creación y Edición (Formulario) ---
  static const deleteReward =
      'delete_reward'; // Para el botón/tooltip de eliminar en la página de edición
  static const rewardBasicInfo = 'reward_basic_info';
  static const rewardNameHint = 'reward_name_hint';
  static const rewardDescriptionHint = 'reward_description_hint';
  static const rewardDetails = 'reward_details';
  static const tapToChangeIcon = 'tap_to_change_icon';
  static const rewardOptions = 'reward_options';
  static const rewardIsEnabledHint = 'reward_is_enabled_hint';
  static const rewardIsUniqueHint = 'reward_is_unique_hint';
  static const rewardSpecificDataTitle =
      'reward_specific_data_title'; // Para futuros campos específicos
  static const saveChanges = 'save_changes';
  static const createRewardButton =
      'create_reward_button'; // Texto del botón de crear
  static const optional = 'optional'; // Para campos opcionales

// --- Diálogos y Mensajes de Feedback ---
  static const formErrorTitle = 'form_error_title';
  static const formErrorMessage = 'form_error_message';
  static const fieldRequiredError =
      'field_required_error'; // Error de validación
  static const pointsPositiveError =
      'points_positive_error'; // Error de validación para puntos
  static const selectRewardIconTitle = 'select_reward_icon_title';

  static const reward_category_treats = 'reward_category_treats';
  static const reward_category_screenTime = 'reward_category_screenTime';
  static const reward_category_activities = 'reward_category_activities';
  static const reward_category_privileges = 'reward_category_privileges';
  static const reward_category_toysAndGames = 'reward_category_toysAndGames';
  static const reward_category_learning = 'reward_category_learning';
  static const reward_category_other = 'reward_category_other';
  static const noPredefinedRewardsFound = 'no_predefined_rewards_found';
  static const tryDifferentFiltersPredefined =
      'try_different_filters_predefined';

  // --- Navegación ---
  static const navHome = 'nav_home';
  static const navChallenges = 'nav_challenges';
  static const navRewards = 'nav_rewards';
  static const navProfile = 'nav_profile';

  // Nuevas TrKeys sugeridas para profile_page.dart y otras páginas
  static const profileTitle = 'profile_title';
  static const editProfileMenuItem = 'edit_profile_menu_item';
  static const errorLoadingProfile = 'error_loading_profile';
  static const tryLoadingProfileAgain = 'try_loading_profile_again';
  static const familyAssociated = 'family_associated';
  static const noFamilyAssociated = 'no_family_associated';
  static const featureComingSoon =
      'feature_coming_soon'; // Más específico que comingSoonMessage
  static const notAvailable = 'not_available'; // Para valores N/A

  // Nuevas TrKeys para HomePage y SettingsController
  static const String homeInitialSetupTitle = 'homeInitialSetupTitle';
  static const String homeInitialSetupMessage = 'homeInitialSetupMessage';
  static const String homeGoToFamilyButton =
      'homeGoToFamilyButton'; // Para "Configurar Familia"
  static const String homeManageFamilyButton =
      'homeManageFamilyButton'; // Para "Gestionar Familia"
  static const String activateChildModeOnDevice = 'activateChildModeOnDevice';
  static const String completeSetupTitle = 'completeSetupTitle';
  static const String completeSetupToNavigate = 'completeSetupToNavigate';
  static const String childModeActivated = 'childModeActivated';
  static const String childModeDeactivated = 'childModeDeactivated';
  static const String settingsLoadingError = 'settingsLoadingError';
  static const String parentalControlDisabledTooltip =
      'parentalControlDisabledTooltip';
  static const String childModeSwitchDisabledTooltip =
      'childModeSwitchDisabledTooltip';
}
