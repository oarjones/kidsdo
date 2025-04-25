import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/presentation/controllers/auth_controller.dart';
import 'package:kidsdo/presentation/controllers/session_controller.dart';
import 'package:kidsdo/routes.dart';

class HomePage extends GetView<AuthController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sessionController = Get.find<SessionController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(TrKeys.appName.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Mostrar diálogo de confirmación
              final result = await Get.dialog<bool>(
                AlertDialog(
                  title: Text(TrKeys.logout.tr),
                  content: Text(TrKeys.logoutConfirmation.tr),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text(TrKeys.cancel.tr),
                    ),
                    TextButton(
                      onPressed: () => Get.back(result: true),
                      child: Text(TrKeys.logout.tr),
                    ),
                  ],
                ),
              );

              if (result == true) {
                // Cerrar sesión
                controller.logout();
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Obx(
          () => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 100,
                color: AppColors.success,
              ),
              const SizedBox(height: 24),
              const Text(
                '¡Conexión con Firebase exitosa!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              sessionController.currentUser.value != null
                  ? Text(
                      Tr.tp(TrKeys.welcome, {
                        'name': sessionController.currentUser.value!.displayName
                      }),
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    )
                  : const Text(
                      'La configuración básica está completa.',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
              const SizedBox(height: 48),

              // Opciones de configuración
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Get.toNamed(Routes.family),
                      icon: const Icon(Icons.family_restroom),
                      label: Text(TrKeys.family.tr),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () =>
                          Get.toNamed(Routes.childProfileSelection),
                      icon: const Icon(Icons.child_care),
                      label: Text('access_child_mode'.tr),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: AppColors.childBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        // Eventualmente navegaríamos a otras configuraciones
                        Get.snackbar(
                          TrKeys.comingSoon.tr,
                          TrKeys.comingSoonMessage.tr,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: Text(TrKeys.continueConfig.tr),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          // Navegación entre secciones principales
          switch (index) {
            case 0: // Home
              break;
            case 3: // Perfil
              Get.toNamed(Routes.profile);
              break;
            default:
              Get.snackbar(
                TrKeys.comingSoon.tr,
                TrKeys.comingSoonSection.tr,
                snackPosition: SnackPosition.BOTTOM,
              );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: TrKeys.menuHome.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assignment),
            label: TrKeys.menuChallenges.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.card_giftcard),
            label: TrKeys.menuAwards.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: TrKeys.menuProfile.tr,
          ),
        ],
      ),
    );
  }
}
