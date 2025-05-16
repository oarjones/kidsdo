// lib/presentation/pages/main_parent_shell_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart'; // Para AppColors
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/presentation/controllers/family_controller.dart'; // Necesario para el estado de configuración
import 'package:kidsdo/presentation/controllers/child_profile_controller.dart'; // Necesario para el estado de configuración
import 'package:kidsdo/presentation/controllers/main_navigation_controller.dart';
import 'package:kidsdo/presentation/widgets/common/custom_bottom_nav_bar.dart';

class MainParentShellPage extends StatelessWidget {
  const MainParentShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MainNavigationController navController =
        Get.find<MainNavigationController>(); // Usar find si ya está puesto
    final FamilyController familyController = Get.find<FamilyController>();
    final ChildProfileController childProfileController =
        Get.find<ChildProfileController>();

    final List<BottomNavItem> navigationItems = [
      const BottomNavItem(
          labelKey: TrKeys.navHome, svgAssetPath: 'assets/icons/menu/home.svg'),
      const BottomNavItem(
          labelKey: TrKeys.navChallenges,
          svgAssetPath: 'assets/icons/menu/challenges.svg'),
      const BottomNavItem(
          labelKey: TrKeys.navRewards,
          svgAssetPath: 'assets/icons/menu/rewards.svg'),
      const BottomNavItem(
          labelKey: TrKeys.navProfile,
          svgAssetPath: 'assets/icons/menu/profile.svg'),
    ];

    return Scaffold(
      body: Obx(() => navController.currentPage),
      bottomNavigationBar: Obx(() {
        // Determinar si la configuración de la app está completa
        final bool isFamilySetup = familyController.currentFamily.value != null;
        final bool hasChildren =
            childProfileController.childProfiles.isNotEmpty;
        final bool isAppConfigured = isFamilySetup && hasChildren;

        return CustomBottomNavBar(
          items: navigationItems,
          currentIndex: navController.selectedIndex.value,
          onTap: isAppConfigured
              ? navController.changePage
              : (index) {
                  // Si la app no está configurada, solo permite quedarse en Home (índice 0)
                  if (navController.selectedIndex.value != 0 && index != 0) {
                    // Forzar la vuelta a Home si se intenta navegar a otra pestaña
                    navController.changePage(0);
                  }
                  if (index != 0) {
                    // Mostrar snackbar solo si se intenta cambiar de la pestaña Home
                    Get.snackbar(
                      TrKeys.completeSetupTitle.tr,
                      TrKeys.completeSetupToNavigate.tr,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.warning.withValues(alpha: 0.9),
                      colorText: AppColors.textDark,
                      margin: const EdgeInsets.all(AppDimensions.sm),
                    );
                  }
                },
          // (Opcional) Pasar 'isAppConfigured' a CustomBottomNavBar si quieres atenuar visualmente los iconos
          // isEnabled: isAppConfigured,
        );
      }),
    );
  }
}
