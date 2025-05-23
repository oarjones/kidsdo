import 'package:get/get.dart';
import 'package:kidsdo/core/middleware/auth_middleware.dart';
import 'package:kidsdo/domain/entities/reward.dart';
import 'package:kidsdo/presentation/pages/challenges/active_challenges_page.dart';
import 'package:kidsdo/presentation/pages/challenges/assign_challenge_page.dart';
import 'package:kidsdo/presentation/pages/challenges/batch_assign_challenges_page.dart';
import 'package:kidsdo/presentation/pages/challenges/batch_evaluation_page.dart';
import 'package:kidsdo/presentation/pages/challenges/challenges_library_page.dart';
import 'package:kidsdo/presentation/pages/challenges/challenges_page.dart';
import 'package:kidsdo/presentation/pages/challenges/create_edit_challenge_page.dart';
import 'package:kidsdo/presentation/pages/child_access/child_challenges_page.dart';
import 'package:kidsdo/presentation/pages/main_parent_shell_page.dart';
import 'package:kidsdo/presentation/pages/rewards/create_edit_reward_page.dart';
import 'package:kidsdo/presentation/pages/rewards/predefined_rewards_library_page.dart';
import 'package:kidsdo/presentation/pages/rewards/rewards_management_page.dart';
import 'package:kidsdo/presentation/pages/settings/parental_control_page.dart';
import 'package:kidsdo/presentation/pages/splash/splash_page.dart';
import 'package:kidsdo/presentation/pages/auth/login_page.dart';
import 'package:kidsdo/presentation/pages/auth/register_page.dart';
import 'package:kidsdo/presentation/pages/auth/reset_password_page.dart';
import 'package:kidsdo/presentation/pages/home/home_page.dart';
import 'package:kidsdo/presentation/pages/profile/profile_page.dart';
import 'package:kidsdo/presentation/pages/profile/edit_profile_page.dart';
import 'package:kidsdo/presentation/pages/family/family_page.dart';
import 'package:kidsdo/presentation/pages/family/create_family_page.dart';
import 'package:kidsdo/presentation/pages/family/join_family_page.dart';
import 'package:kidsdo/presentation/pages/family/invite_code_page.dart';
import 'package:kidsdo/presentation/pages/family/child_profiles_page.dart';
import 'package:kidsdo/presentation/pages/family/create_child_profile_page.dart';
import 'package:kidsdo/presentation/pages/family/edit_child_profile_page.dart';
import 'package:kidsdo/presentation/pages/child_access/child_profile_selection_page.dart';
import 'package:kidsdo/presentation/pages/child_access/child_dashboard_page.dart';

abstract class Routes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const resetPassword = '/reset-password';
  static const home = '/home';
  static const profile = '/profile';
  static const editProfile = '/edit-profile';
  static const family = '/family';
  static const childProfiles = '/child-profiles';
  static const createChild = '/create-child';
  static const editChild = '/edit-child';
  static const createFamily = '/create-family';
  static const joinFamily = '/join-family';
  static const inviteCode = '/invite-code';
  static const parentalControl = '/parental-control';
  static const challenges = '/challenges';

  // Rutas para acceso infantil
  static const childProfileSelection = '/child-profile-selection';
  static const childDashboard = '/child-dashboard';
  static const childChallenges = '/child-challenges';
  static const childRewards = '/child-rewards';
  static const childAchievements = '/child-achievements';

  // Rutas para los retos
  static const challengeLibrary = '/challenge-library';
  static const createChallenge = '/create-challenge';
  static const editChallenge = '/edit-challenge';
  static const assignChallenge = '/assign-challenge';
  static const activeChallenges = '/active-challenges';
  static const batchAssignChallenges = '/batch-assign-challenges';
  static const batchEvaluation = '/batch-evaluation';

  // Rutas para gestión de recompensas
  static const String rewardsManagement = '/rewards-management';
  static const String createReward = '/create-reward';
  static const String editReward =
      '/edit-reward'; // Se pasará Reward como argumento
  static const String predefinedRewardsLibrary = '/predefined-rewards-library';

  // Rutas para la navegación principal
  static const String mainParent = '/main-parent';
}

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashPage(),
      transition: Transition.fade,
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginPage(),
      middlewares: [NoAuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterPage(),
      middlewares: [NoAuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.resetPassword,
      page: () => const ResetPasswordPage(),
      middlewares: [NoAuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomePage(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.family,
      page: () => const FamilyPage(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.createFamily,
      page: () => const CreateFamilyPage(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.joinFamily,
      page: () => const JoinFamilyPage(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.inviteCode,
      page: () => const InviteCodePage(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.profile,
      page: () => const ProfilePage(), // Temporalmente usando HomePage
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.createChild,
      page: () =>
          const CreateChildProfilePage(), // Temporalmente usando HomePage
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.childProfiles,
      page: () => const ChildProfilesPage(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.editChild,
      page: () => const EditChildProfilePage(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.editProfile,
      page: () => const EditProfilePage(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),

    // Rutas para acceso infantil
    GetPage(
      name: Routes.childChallenges,
      page: () => const ChildChallengesPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.childProfileSelection,
      page: () => const ChildProfileSelectionPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.childDashboard,
      page: () => const ChildDashboardPage(),
      transition: Transition.fadeIn,
    ),

    // Ruta para el control parental
    GetPage(
      name: Routes.parentalControl,
      page: () => const ParentalControlPage(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),

    // Rutas para gestión de retos
    GetPage(
      name: Routes.challenges,
      page: () => const ChallengesPage(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.challengeLibrary,
      page: () => const ChallengesLibraryPage(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.createChallenge,
      page: () => const CreateEditChallengePage(isEditing: false),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.editChallenge,
      page: () => const CreateEditChallengePage(isEditing: true),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.assignChallenge,
      page: () => const AssignChallengePage(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.activeChallenges,
      page: () => const ActiveChallengesPage(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: Routes.batchAssignChallenges,
      page: () => const BatchAssignChallengesPage(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.batchEvaluation,
      page: () => const BatchEvaluationPage(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: Routes.rewardsManagement,
      page: () => const RewardsManagementPage(),
      middlewares: [AuthMiddleware()], // Si requiere autenticación
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.createReward,
      page: () => const CreateEditRewardPage(
          isEditing: false), // Necesitaremos esta página
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.editReward,
      page: () {
        // Cuando navegas a esta ruta, se espera que pases el objeto Reward
        // como argumento. Ejemplo de navegación:
        // Get.toNamed(Routes.editReward, arguments: laRecompensaAEditar);

        final Reward? rewardToEdit = Get.arguments as Reward?;

        // Es una buena práctica verificar si el argumento es del tipo esperado
        // y manejar el caso en que no lo sea, aunque aquí lo pasamos directamente.
        // La página CreateEditRewardPage ya está preparada para recibir `rewardForEditing`.
        return CreateEditRewardPage(
          isEditing: true,
          rewardForEditing:
              rewardToEdit, // Se pasa la recompensa al constructor
        );
      },
      middlewares: [
        AuthMiddleware()
      ], // Aplica tu middleware de autenticación si es necesario
      transition: Transition.rightToLeft, // O la transición que prefieras
    ),
    GetPage(
      name: Routes.predefinedRewardsLibrary,
      page: () =>
          const PredefinedRewardsLibraryPage(), // Necesitaremos esta página
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: Routes.mainParent, // Nueva ruta principal para padres
      page: () => const MainParentShellPage(),
      middlewares: [
        AuthMiddleware()
      ], // Asegura que el usuario esté autenticado
    ),
  ];
}
