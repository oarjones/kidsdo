import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/family_child.dart';
import 'package:kidsdo/presentation/controllers/child_access_controller.dart';
import 'package:kidsdo/presentation/widgets/child/age_adapted_container.dart';
import 'package:kidsdo/presentation/widgets/common/cached_avatar.dart';
import 'package:kidsdo/routes.dart';
import 'package:kidsdo/presentation/widgets/auth/parental_pin_dialog.dart';

class ChildDashboardPage extends GetView<ChildAccessController> {
  const ChildDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Verificar que hay un perfil activo
      final FamilyChild? activeChild = controller.activeChildProfile.value;
      if (activeChild == null) {
        // Si no hay perfil activo, redirigir a la selección de perfil
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offNamed(Routes.childProfileSelection);
        });
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Verificar restricciones de tiempo
      if (controller.timeRestricted.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offNamed(Routes.childProfileSelection);
        });
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Verificar tiempo máximo de sesión
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.checkSessionTimeLimit();
      });

      // Determinar el color del tema según la configuración del perfil
      final Color themeColor = _getThemeColor(activeChild.settings);

      return Scaffold(
        appBar: _buildAppBar(activeChild, themeColor),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Saludo personalizado
                    _buildGreeting(activeChild, themeColor),
                    const SizedBox(height: AppDimensions.lg),

                    // Progreso y puntos
                    _buildPointsProgress(activeChild, themeColor),
                    const SizedBox(height: AppDimensions.lg),

                    // Sección de retos
                    _buildChallengesSection(activeChild, themeColor),
                    const SizedBox(height: AppDimensions.lg),

                    // Sección de recompensas
                    _buildRewardsSection(activeChild, themeColor),
                  ],
                ),
              ),
            ),

            // Indicador de tiempo restante de sesión
            if (controller.sessionStartTime.value != null)
              Positioned(
                bottom: 16,
                right: 16,
                child: _buildSessionTimeIndicator(themeColor),
              ),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(themeColor, activeChild.age),
      );
    });
  }

  // Nuevo widget para mostrar el tiempo restante de sesión
  Widget _buildSessionTimeIndicator(Color themeColor) {
    final remainingTime = controller.getRemainingSessionTime();
    final isRunningLow = remainingTime <= 5; // Menos de 5 minutos

    return Material(
      elevation: AppDimensions.elevationMd,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
      color: isRunningLow
          ? Colors.red.withValues(alpha: 200)
          : themeColor.withValues(alpha: 180),
      child: InkWell(
        onTap: () {
          Get.snackbar(
            'session_time_info_title'.tr,
            'session_time_info_message'
                .trParams({'minutes': remainingTime.toString()}),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: themeColor.withValues(alpha: 40),
            colorText: themeColor,
          );
        },
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.md,
            vertical: AppDimensions.sm,
          ),
          child: Row(
            children: [
              Icon(
                Icons.timer,
                color: Colors.white,
                size: isRunningLow ? 20 : 18,
              ),
              const SizedBox(width: AppDimensions.xs),
              Text(
                '$remainingTime min',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight:
                      isRunningLow ? FontWeight.bold : FontWeight.normal,
                  fontSize: isRunningLow
                      ? AppDimensions.fontMd
                      : AppDimensions.fontSm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(FamilyChild child, Color themeColor) {
    return AppBar(
      backgroundColor: themeColor,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Avatar con Hero
          Hero(
            tag: 'child_avatar_${child.id}',
            child: child.avatarUrl != null
                ? CachedAvatar(
                    url: child.avatarUrl,
                    radius: 18,
                  )
                : CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    child: const Icon(
                      Icons.child_care,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
          ),
          const SizedBox(width: AppDimensions.sm),

          // Nombre
          Text(
            child.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        // Botón para cambiar de perfil
        IconButton(
          icon: const Icon(Icons.switch_account, color: Colors.white),
          onPressed: () => Get.offNamed(Routes.childProfileSelection),
          tooltip: TrKeys.switchProfile.tr,
        ),

        // Botón para acceso parental
        IconButton(
          icon: const Icon(Icons.lock, color: Colors.white),
          onPressed: _showParentPinDialog,
          tooltip: TrKeys.parentAccess.tr,
        ),
      ],
    );
  }

  Widget _buildGreeting(FamilyChild child, Color themeColor) {
    final String greeting = _getTimeBasedGreeting(child.name);

    return AgeAdaptedContainer(
      childAge: child.age,
      settings: child.settings,
      padding: const EdgeInsets.all(AppDimensions.lg),
      defaultWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: TextStyle(
              fontSize: AppDimensions.fontXl,
              fontWeight: FontWeight.bold,
              color: themeColor,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            TrKeys.childDashboardSubtitle.tr,
            style: const TextStyle(
              fontSize: AppDimensions.fontMd,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
      // Widget específico para niños pequeños (3-5 años)
      youngChildWidget: Row(
        children: [
          Image.asset(
            'assets/images/star.png', // Asegúrate de tener esta imagen
            width: 80,
            height: 80,
            errorBuilder: (ctx, error, _) => Icon(
              Icons.stars,
              size: 80,
              color: themeColor,
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Text(
              greeting,
              style: TextStyle(
                fontSize: AppDimensions.fontXl,
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsProgress(FamilyChild child, Color themeColor) {
    // Datos de ejemplo (en una implementación real vendrían del repositorio)
    final int totalPoints = child.points;
    const int pointsToNextLevel = 100;
    final double progress = totalPoints / pointsToNextLevel;

    return AgeAdaptedContainer(
      childAge: child.age,
      settings: child.settings,
      padding: const EdgeInsets.all(AppDimensions.lg),
      defaultWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                TrKeys.yourPoints.tr,
                style: const TextStyle(
                  fontSize: AppDimensions.fontMd,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                  vertical: AppDimensions.xs,
                ),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusMd),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: AppDimensions.iconSm,
                      color: themeColor,
                    ),
                    const SizedBox(width: AppDimensions.xs),
                    Text(
                      totalPoints.toString(),
                      style: TextStyle(
                        fontSize: AppDimensions.fontMd,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Text(
                '${TrKeys.level.tr} ${child.level}',
                style: TextStyle(
                  fontSize: AppDimensions.fontSm,
                  color: themeColor,
                ),
              ),
              const Spacer(),
              Text(
                '${TrKeys.nextLevel.tr} ${child.level + 1}',
                style: const TextStyle(
                  fontSize: AppDimensions.fontSm,
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSm),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(themeColor),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            '$totalPoints/$pointsToNextLevel ${TrKeys.points.tr}',
            style: const TextStyle(
              fontSize: AppDimensions.fontXs,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
      // Widget para niños pequeños (más visual)
      youngChildWidget: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star,
                size: 40,
                color: themeColor,
              ),
              const SizedBox(width: AppDimensions.sm),
              Text(
                totalPoints.toString(),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Icon(
                Icons.star,
                size: 40,
                color: themeColor,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(themeColor),
              minHeight: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesSection(FamilyChild child, Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              TrKeys.yourChallenges.tr,
              style: const TextStyle(
                fontSize: AppDimensions.fontLg,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Get.snackbar(
                  TrKeys.comingSoon.tr,
                  TrKeys.comingSoonMessage.tr,
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              icon: Icon(
                Icons.visibility,
                size: AppDimensions.iconSm,
                color: themeColor,
              ),
              label: Text(
                TrKeys.viewAll.tr,
                style: TextStyle(
                  color: themeColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sm),

        // Lista de retos (ejemplos)
        _buildChallengeTile(
          title: TrKeys.challengeExample1.tr,
          subtitle: TrKeys.dailyChallenge.tr,
          icon: Icons.check_circle_outline,
          points: 10,
          isCompleted: true,
          themeColor: themeColor,
          childAge: child.age,
          settings: child.settings,
        ),
        const SizedBox(height: AppDimensions.sm),
        _buildChallengeTile(
          title: TrKeys.challengeExample2.tr,
          subtitle: TrKeys.weeklyChallenge.tr,
          icon: Icons.bed,
          points: 15,
          isCompleted: false,
          themeColor: themeColor,
          childAge: child.age,
          settings: child.settings,
        ),
        const SizedBox(height: AppDimensions.sm),
        _buildChallengeTile(
          title: TrKeys.challengeExample3.tr,
          subtitle: TrKeys.dailyChallenge.tr,
          icon: Icons.school,
          points: 20,
          isCompleted: false,
          themeColor: themeColor,
          childAge: child.age,
          settings: child.settings,
        ),
      ],
    );
  }

  Widget _buildRewardsSection(FamilyChild child, Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              TrKeys.yourRewards.tr,
              style: const TextStyle(
                fontSize: AppDimensions.fontLg,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Get.snackbar(
                  TrKeys.comingSoon.tr,
                  TrKeys.comingSoonMessage.tr,
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              icon: Icon(
                Icons.visibility,
                size: AppDimensions.iconSm,
                color: themeColor,
              ),
              label: Text(
                TrKeys.viewAll.tr,
                style: TextStyle(
                  color: themeColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sm),

        // Grid de recompensas (ejemplos)
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppDimensions.sm,
          crossAxisSpacing: AppDimensions.sm,
          childAspectRatio: 0.8,
          children: [
            _buildRewardCard(
              title: TrKeys.rewardExample1.tr,
              icon: Icons.sports_baseball,
              points: 50,
              themeColor: themeColor,
              childAge: child.age,
              settings: child.settings,
            ),
            _buildRewardCard(
              title: TrKeys.rewardExample2.tr,
              icon: Icons.videogame_asset,
              points: 100,
              themeColor: themeColor,
              childAge: child.age,
              settings: child.settings,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChallengeTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required int points,
    required bool isCompleted,
    required Color themeColor,
    required int childAge,
    required Map<String, dynamic> settings,
  }) {
    return AgeAdaptedContainer(
      childAge: childAge,
      settings: settings,
      defaultWidget: ListTile(
        leading: Icon(
          icon,
          color: isCompleted ? themeColor : Colors.grey,
          size: AppDimensions.iconMd,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.sm,
            vertical: AppDimensions.xs,
          ),
          decoration: BoxDecoration(
            color: isCompleted
                ? themeColor.withValues(alpha: 0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star,
                size: 16,
                color: isCompleted ? themeColor : Colors.grey,
              ),
              const SizedBox(width: 2),
              Text(
                points.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? themeColor : Colors.grey,
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          Get.snackbar(
            TrKeys.comingSoon.tr,
            TrKeys.comingSoonMessage.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      ),
      // Widget para niños pequeños
      youngChildWidget: InkWell(
        onTap: () {
          Get.snackbar(
            TrKeys.comingSoon.tr,
            TrKeys.comingSoonMessage.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? themeColor.withValues(alpha: 0.2)
                      : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isCompleted ? themeColor : Colors.grey,
                  size: 36,
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: AppDimensions.fontLg,
                        fontWeight: FontWeight.bold,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 20,
                          color: isCompleted ? themeColor : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          points.toString(),
                          style: TextStyle(
                            fontSize: AppDimensions.fontMd,
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? themeColor : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppDimensions.sm),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? themeColor.withValues(alpha: 0.2)
                      : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted ? Icons.check : Icons.arrow_forward,
                  color: isCompleted ? themeColor : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardCard({
    required String title,
    required IconData icon,
    required int points,
    required Color themeColor,
    required int childAge,
    required Map<String, dynamic> settings,
  }) {
    return AgeAdaptedContainer(
      childAge: childAge,
      settings: settings,
      defaultWidget: Card(
        elevation: AppDimensions.elevationSm,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
        ),
        child: InkWell(
          onTap: () {
            Get.snackbar(
              TrKeys.comingSoon.tr,
              TrKeys.comingSoonMessage.tr,
              snackPosition: SnackPosition.BOTTOM,
            );
          },
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: themeColor,
                ),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md,
                    vertical: AppDimensions.xs,
                  ),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusMd),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: AppDimensions.iconSm,
                        color: themeColor,
                      ),
                      const SizedBox(width: AppDimensions.xs),
                      Text(
                        points.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // Para niños pequeños
      youngChildWidget: Card(
        elevation: AppDimensions.elevationMd,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXl),
        ),
        child: InkWell(
          onTap: () {
            Get.snackbar(
              TrKeys.comingSoon.tr,
              TrKeys.comingSoonMessage.tr,
              snackPosition: SnackPosition.BOTTOM,
            );
          },
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXl),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 64,
                  color: themeColor,
                ),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppDimensions.fontLg,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star,
                      size: 28,
                      color: themeColor,
                    ),
                    const SizedBox(width: AppDimensions.xs),
                    Text(
                      points.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppDimensions.fontLg,
                        color: themeColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Actualizar el método _buildBottomNav en child_dashboard_page.dart
// para mejorar el contraste y aumentar el tamaño de los iconos

  Widget _buildBottomNav(Color themeColor, int childAge) {
    // Determinar tamaños según la edad para mejorar la usabilidad
    double normalIconSize = childAge <= 5 ? 32.0 : 28.0;
    double activeIconSize = childAge <= 5 ? 36.0 : 30.0;
    double labelSize =
        childAge <= 5 ? AppDimensions.fontSm : AppDimensions.fontXs;

    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        Get.snackbar(
          TrKeys.comingSoon.tr,
          TrKeys.comingSoonMessage.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      selectedItemColor: themeColor,
      unselectedItemColor:
          AppColors.navigationUnselected, // Color estandarizado
      backgroundColor: Colors.white,
      elevation: 16, // Mayor elevación para sombra más visible
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(
        fontSize: labelSize,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: labelSize,
      ),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: normalIconSize),
          activeIcon: Icon(Icons.home, size: activeIconSize),
          label: TrKeys.menuHome.tr,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment, size: normalIconSize),
          activeIcon: Icon(Icons.assignment, size: activeIconSize),
          label: TrKeys.menuChallenges.tr,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.card_giftcard, size: normalIconSize),
          activeIcon: Icon(Icons.card_giftcard, size: activeIconSize),
          label: TrKeys.menuAwards.tr,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_events, size: normalIconSize),
          activeIcon: Icon(Icons.emoji_events, size: activeIconSize),
          label: TrKeys.menuAchievements.tr,
        ),
      ],
    );
  }

  // Función para obtener un saludo basado en la hora del día
  String _getTimeBasedGreeting(String name) {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = TrKeys.goodMorning.tr;
    } else if (hour < 18) {
      greeting = TrKeys.goodAfternoon.tr;
    } else {
      greeting = TrKeys.goodEvening.tr;
    }

    return '$greeting, $name!';
  }

  // Muestra el diálogo para introducir el PIN de control parental
  void _showParentPinDialog() {
    ParentalPinDialog.show(
      customTitle: TrKeys.parentAccess.tr,
      customSubtitle: TrKeys.enterParentalPinMessage.tr,
    ).then((success) {
      if (success) {
        controller.exitChildMode();
        Get.offNamed(Routes.home);
      }
    });
  }

  // Obtiene el color del tema basado en las configuraciones
  Color _getThemeColor(Map<String, dynamic> settings) {
    final String colorKey = settings['color'] as String? ?? 'blue';

    switch (colorKey) {
      case 'purple':
        return AppColors.childPurple;
      case 'green':
        return AppColors.childGreen;
      case 'orange':
        return AppColors.childOrange;
      case 'pink':
        return AppColors.childPink;
      case 'blue':
      default:
        return AppColors.childBlue;
    }
  }
}
