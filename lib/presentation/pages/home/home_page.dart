// lib/presentation/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/presentation/controllers/auth_controller.dart';
import 'package:kidsdo/presentation/controllers/family_controller.dart';
import 'package:kidsdo/presentation/controllers/child_profile_controller.dart';
import 'package:kidsdo/presentation/controllers/session_controller.dart';
import 'package:kidsdo/presentation/controllers/settings_controller.dart'; // Nuevo
import 'package:kidsdo/presentation/widgets/common/app_logo.dart';
import 'package:kidsdo/routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Controladores
    final AuthController authController = Get.find<AuthController>();
    final SessionController sessionController = Get.find<SessionController>();
    final FamilyController familyController = Get.find<FamilyController>();
    final ChildProfileController childProfileController =
        Get.find<ChildProfileController>();
    final SettingsController settingsController =
        Get.find<SettingsController>();

    // Estilo del AppBar
    const appBarTitleStyle = TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      fontSize: AppDimensions.fontLg,
      color: AppColors.textDark,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:
            Text(TrKeys.navHome.tr, style: appBarTitleStyle), // Título "Inicio"
        backgroundColor: AppColors.background,
        elevation: AppDimensions.elevationXs,
        actionsIconTheme: const IconThemeData(color: AppColors.textMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Lógica de Logout (existente)
              final result = await Get.dialog<bool>(
                AlertDialog(
                  title: Text(Tr.t(TrKeys.logout)),
                  content: Text(Tr.t(TrKeys.logoutConfirmation)),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text(Tr.t(TrKeys.cancel),
                          style: const TextStyle(color: AppColors.primary)),
                    ),
                    TextButton(
                      onPressed: () => Get.back(result: true),
                      child: Text(Tr.t(TrKeys.logout),
                          style: const TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
              if (result == true) {
                authController.logout();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Obx(() {
            // Obx para reactividad general de la página
            // Determinar si la configuración de la app está completa
            final bool isFamilySetup =
                familyController.currentFamily.value != null;
            final bool hasChildren =
                childProfileController.childProfiles.isNotEmpty;
            final bool isAppConfigured = isFamilySetup && hasChildren;

            // Mostrar indicador de carga si SettingsController está cargando
            if (settingsController.isLoading.value) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary));
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(size: 100, showSlogan: true),
                const SizedBox(height: AppDimensions.lg),

                // Mensaje de bienvenida
                if (sessionController.currentUser.value != null)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppDimensions.md),
                    child: Text(
                      TrKeys.welcome.trParams({
                        'name': sessionController.currentUser.value!.displayName
                      }),
                      style: Get.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: AppDimensions.md),

                // Contenido condicional: Tarjeta de Configuración Inicial
                if (!isAppConfigured) _buildInitialSetupCard(context),

                const SizedBox(height: AppDimensions.lg),

                // Botones de Acción
                _buildActionButton(
                  context: context,
                  icon: Icons.family_restroom_outlined,
                  label: isAppConfigured
                      ? TrKeys.homeManageFamilyButton.tr
                      : TrKeys.homeGoToFamilyButton.tr,
                  onPressed: () => Get.toNamed(Routes.family),
                  isEnabled: true, // El botón de familia siempre está activo
                  isPrimary:
                      !isAppConfigured, // Destacar si es la acción principal de configuración
                ),
                const SizedBox(height: AppDimensions.md),

                // Opción "Activar Modo Infantil"
                _buildChildModeSwitch(settingsController, isAppConfigured),
                const SizedBox(height: AppDimensions.md),

                // Botón "Control Parental"
                _buildActionButton(
                  context: context,
                  icon: Icons.shield_outlined,
                  label: TrKeys.parentalControl.tr,
                  onPressed: () => Get.toNamed(Routes.parentalControl),
                  isEnabled: isAppConfigured,
                  tooltipMessage: !isAppConfigured
                      ? TrKeys.parentalControlDisabledTooltip.tr
                      : null,
                ),
                const SizedBox(height: AppDimensions.xl),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildInitialSetupCard(BuildContext context) {
    return Card(
      elevation: AppDimensions.elevationSm,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg)),
      color: AppColors.primaryLight.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.settings_suggest_outlined,
                size: AppDimensions.iconXl, color: AppColors.primary),
            const SizedBox(height: AppDimensions.md),
            Text(
              TrKeys.homeInitialSetupTitle.tr,
              textAlign: TextAlign.center,
              style: Get.textTheme.titleLarge?.copyWith(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary),
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              TrKeys.homeInitialSetupMessage.tr,
              textAlign: TextAlign.center,
              style: Get.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Poppins',
                  color: AppColors.textDark.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isEnabled,
    String? tooltipMessage,
    bool isPrimary = false,
  }) {
    Widget button = ElevatedButton.icon(
      icon: Icon(icon, size: AppDimensions.iconMd - 2),
      label: Text(label,
          style: const TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled
            ? (isPrimary ? AppColors.primary : AppColors.secondary)
            : AppColors.textLight.withValues(alpha: 0.5),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        ),
        elevation: isEnabled ? AppDimensions.elevationXs : 0,
      ),
    );

    if (!isEnabled && tooltipMessage != null) {
      return Tooltip(
        message: tooltipMessage,
        child: button,
      );
    }
    return button;
  }

  Widget _buildChildModeSwitch(
      SettingsController settingsController, bool isAppConfigured) {
    Widget switchTile = Obx(() => SwitchListTile.adaptive(
          title: Text(
            TrKeys.activateChildModeOnDevice.tr,
            style: Get.textTheme.titleMedium?.copyWith(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              color:
                  isAppConfigured ? AppColors.textDark : AppColors.textMedium,
            ),
          ),
          value: settingsController.isChildModeActiveOnDevice.value,
          onChanged: isAppConfigured
              ? (bool value) =>
                  settingsController.setChildModeActiveOnDevice(value)
              : null,
          activeColor: AppColors.primary,
          inactiveThumbColor: AppColors.textLight,
          secondary: Icon(
            Icons.child_care_outlined,
            color: isAppConfigured ? AppColors.primary : AppColors.textMedium,
            size: AppDimensions.iconLg,
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.sm, vertical: AppDimensions.xs),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
              side: BorderSide(
                  color: AppColors.textLight.withValues(alpha: 0.5))),
          tileColor: AppColors.card, // Fondo de la tarjeta
        ));

    if (!isAppConfigured) {
      return Tooltip(
        message: TrKeys.childModeSwitchDisabledTooltip.tr,
        child: AbsorbPointer(
            child: switchTile), // AbsorbPointer para deshabilitar interacciones
      );
    }
    return switchTile;
  }
}
