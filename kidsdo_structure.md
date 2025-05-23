# Estructura del Proyecto KidsDo 
Generada: 09/05/2025  6:18:56,65 
 
## Archivos de Configuración 
- pubspec.yaml 
 
## Estructura de lib 
 
- **lib/** 
  - app.dart 
  - firebase_options.dart 
  - injection_container.dart 
  - main.dart 
  - routes.dart 
- **lib\core/** 
- **lib\core\constants/** 
  - colors.dart 
  - dimensions.dart 
- **lib\core\data/** 
  - predefined_challenges.dart 
- **lib\core\errors/** 
  - failures.dart 
- **lib\core\middleware/** 
  - auth_middleware.dart 
- **lib\core\network/** 
- **lib\core\theme/** 
  - app_theme.dart 
  - auth_theme.dart 
- **lib\core\translations/** 
  - app_translations.dart 
  - en_translations.dart 
  - es_translations.dart 
- **lib\core\utils/** 
  - family_utils.dart 
  - form_validators.dart 
  - random_generator.dart 
- **lib\core\widgets/** 
- **lib\data/** 
- **lib\data\datasources/** 
- **lib\data\datasources\local/** 
- **lib\data\datasources\remote/** 
  - auth_remote_datasource.dart 
  - challenge_remote_datasource.dart 
  - family_child_remote_datasource.dart 
  - family_remote_datasource.dart 
  - user_remote_datasource.dart 
- **lib\data\models/** 
  - assigned_challenge_model.dart 
  - challenge_execution_model.dart 
  - challenge_model.dart 
  - child_model.dart 
  - family_child_model.dart 
  - family_model.dart 
  - parent_model.dart 
  - user_model.dart 
- **lib\data\repositories/** 
  - auth_repository_impl.dart 
  - challenge_repository_impl.dart 
  - family_child_repository_impl.dart 
  - family_repository_impl.dart 
  - user_repository_impl.dart 
- **lib\domain/** 
- **lib\domain\entities/** 
  - assigned_challenge.dart 
  - base_user.dart 
  - challenge.dart 
  - challenge_execution.dart 
  - child.dart 
  - family.dart 
  - family_child.dart 
  - parent.dart 
- **lib\domain\repositories/** 
  - auth_repository.dart 
  - challenge_repository.dart 
  - family_child_repository.dart 
  - family_repository.dart 
  - user_repository.dart 
- **lib\domain\usecases/** 
- **lib\presentation/** 
- **lib\presentation\bloc/** 
- **lib\presentation\controllers/** 
  - auth_controller.dart 
  - challenge_controller.dart 
  - child_access_controller.dart 
  - child_challenges_controller.dart 
  - child_profile_controller.dart 
  - family_controller.dart 
  - language_controller.dart 
  - parental_control_controller.dart 
  - profile_controller.dart 
  - session_controller.dart 
- **lib\presentation\pages/** 
- **lib\presentation\pages\achievements/** 
- **lib\presentation\pages\auth/** 
  - login_page.dart 
  - register_page.dart 
  - reset_password_page.dart 
- **lib\presentation\pages\challenges/** 
  - active_challenges_page.dart 
  - active_challenges_page_copy.dart 
  - assign_challenge_page.dart 
  - batch_assign_challenges_page.dart 
  - challenges_library_page.dart 
  - challenges_library_page_copy.dart 
  - challenges_page.dart 
  - challenges_page_copy.dart 
  - create_edit_challenge_page.dart 
- **lib\presentation\pages\child_access/** 
  - child_challenges_page.dart 
  - child_dashboard_page.dart 
  - child_profile_selection_page.dart 
  - restricted_access_page.dart 
- **lib\presentation\pages\family/** 
  - child_profiles_page.dart 
  - create_child_profile_page.dart 
  - create_family_page.dart 
  - edit_child_profile_page.dart 
  - family_page.dart 
  - invite_code_page.dart 
  - join_family_page.dart 
- **lib\presentation\pages\home/** 
  - home_page.dart 
- **lib\presentation\pages\profile/** 
  - edit_profile_page.dart 
  - profile_page.dart 
- **lib\presentation\pages\rewards/** 
- **lib\presentation\pages\settings/** 
  - parental_control_page.dart 
- **lib\presentation\pages\splash/** 
  - splash_page.dart 
- **lib\presentation\widgets/** 
- **lib\presentation\widgets\auth/** 
  - auth_button.dart 
  - auth_message.dart 
  - auth_text_field.dart 
  - language_selector_auth.dart 
  - parental_pin_dialog.dart 
  - pin_code_widget.dart 
- **lib\presentation\widgets\challenges/** 
  - assigned_challenge_card.dart 
  - celebration_animation.dart 
  - challenges.dart 
  - challenge_card.dart 
  - challenge_evaluation_dialog.dart 
  - challenge_execution_indicator.dart 
  - challenge_filter_drawer.dart 
  - challenge_icon_selector.dart 
  - child_challenge_card.dart 
  - child_progress_indicator.dart 
  - duration_selector_widget.dart 
  - execution_summary_widget.dart 
  - multi_child_selector_widget.dart 
- **lib\presentation\widgets\child/** 
  - age_adapted_container.dart 
  - avatar_picker.dart 
  - theme_preview.dart 
  - theme_selector.dart 
- **lib\presentation\widgets\common/** 
  - app_logo.dart 
  - cached_avatar.dart 
  - language_selector.dart 
- **lib\presentation\widgets\family/** 
  - family_members_list.dart 
- **lib\presentation\widgets\parental_control/** 
  - time_restriction_widget.dart 
- **lib\presentation\widgets\rewards/** 
