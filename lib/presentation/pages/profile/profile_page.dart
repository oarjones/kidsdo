// lib/presentation/pages/profile/profile_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Para formateo de fechas
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/presentation/controllers/auth_controller.dart';
import 'package:kidsdo/presentation/controllers/profile_controller.dart';
import 'package:kidsdo/presentation/widgets/common/cached_avatar.dart';
import 'package:kidsdo/presentation/widgets/common/empty_state_widget.dart'; // Para estados de error/vacío
import 'package:kidsdo/routes.dart'; // Para navegación

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final ProfileController controller = Get.find<ProfileController>();

    // Estilo de texto para el título del AppBar
    const appBarTitleStyle = TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      fontSize: AppDimensions.fontLg,
      color: AppColors.textDark,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(Tr.t(TrKeys.profile),
            style: appBarTitleStyle), // Título específico "Perfil"
        backgroundColor: AppColors.background,
        elevation: AppDimensions.elevationXs,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        actionsIconTheme: const IconThemeData(color: AppColors.textMedium),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit_profile') {
                Get.toNamed(Routes.editProfile); // Asegúrate de tener esta ruta
                // Get.snackbar(
                //   TrKeys.comingSoon.tr,
                //   'Navegación a editar perfil pendiente.', // Mensaje temporal
                //   snackPosition: SnackPosition.BOTTOM,
                // );
              }
              // Podrías añadir más opciones como "Configuración de cuenta", etc.
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'edit_profile',
                child: ListTile(
                  leading:
                      const Icon(Icons.edit_outlined, color: AppColors.primary),
                  title: Text(Tr.t(TrKeys.editProfile),
                      style: const TextStyle(fontFamily: 'Poppins')),
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
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
        child: Obx(() {
          if (controller.status.value == ProfileStatus.loading &&
              controller.profile.value == null) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (controller.status.value == ProfileStatus.error &&
              controller.profile.value == null) {
            return EmptyStateWidget(
              icon: Icons.error_outline,
              title: Tr.t(TrKeys.streamGenericError), // Nueva key de traducción
              message: controller.errorMessage.value.isNotEmpty
                  ? controller.errorMessage.value
                  : Tr.t(TrKeys.error),
              retryButtonText: Tr.t(TrKeys.retry),
              onRetry: controller.loadProfile,
            );
          }

          final profile = controller.profile.value;
          if (profile == null) {
            return EmptyStateWidget(
              icon: Icons.person_off_outlined,
              title: Tr.t(TrKeys.noProfileData), // Key existente
              message: Tr.t(
                  TrKeys.tryLoadingProfileAgain), // Nueva key de traducción
              retryButtonText: Tr.t(TrKeys.retry),
              onRetry: controller.loadProfile,
            );
          }

          // Estilos de texto para la página de perfil
          const nameStyle = TextStyle(
              fontFamily: 'Poppins',
              fontSize: AppDimensions.fontXxl,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark);
          const emailStyle = TextStyle(
              fontFamily: 'Poppins',
              fontSize: AppDimensions.fontMd,
              color: AppColors.textMedium);
          const infoItemTitleStyle = TextStyle(
              fontFamily: 'Poppins',
              fontSize: AppDimensions.fontSm,
              color: AppColors.textMedium);
          const infoItemValueStyle = TextStyle(
              fontFamily: 'Poppins',
              fontSize: AppDimensions.fontMd,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark);
          const optionItemStyle = TextStyle(
              fontFamily: 'Poppins',
              fontSize: AppDimensions.fontMd,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAvatar(profile.avatarUrl, controller),
                const SizedBox(height: AppDimensions.lg),
                Text(profile.displayName,
                    style: nameStyle, textAlign: TextAlign.center),
                const SizedBox(height: AppDimensions.xs),
                if (profile.email != null && profile.email!.isNotEmpty)
                  Text(profile.email!,
                      style: emailStyle, textAlign: TextAlign.center),
                const Divider(
                    height: AppDimensions.xxl,
                    thickness: 0.5,
                    color: AppColors.textLight),
                _buildInfoItem(
                  icon: Icons.people_outline,
                  title: TrKeys.children.tr,
                  value: '${profile.childrenIds.length}',
                  color:
                      AppColors.primary, // Usar colores de la paleta principal
                  titleStyle: infoItemTitleStyle,
                  valueStyle: infoItemValueStyle,
                ),
                _buildInfoItem(
                  icon: Icons.family_restroom_outlined,
                  title: TrKeys.family.tr,
                  value: profile.familyId != null &&
                          profile.familyId!.isNotEmpty
                      ? Tr.t(TrKeys
                          .familyAssociated) // Nueva key: "Familia Asociada"
                      : Tr.t(TrKeys
                          .noFamilyAssociated), // Nueva key: "Sin Familia Asociada"
                  color: AppColors.secondary,
                  titleStyle: infoItemTitleStyle,
                  valueStyle: infoItemValueStyle,
                ),
                _buildInfoItem(
                  icon: Icons.calendar_today_outlined,
                  title: TrKeys.accountCreated.tr,
                  value: _formatDate(profile.createdAt, context),
                  color: AppColors.tertiary,
                  titleStyle: infoItemTitleStyle,
                  valueStyle: infoItemValueStyle,
                ),
                const Divider(
                    height: AppDimensions.xl,
                    thickness: 0.5,
                    color: AppColors.textLight),
                _buildOptionItem(
                  icon: Icons.notifications_none_outlined,
                  title: TrKeys.notifications.tr,
                  textStyle: optionItemStyle,
                  onTap: () {
                    Get.snackbar(TrKeys.comingSoon.tr,
                        TrKeys.featureComingSoon.tr, // Nueva key
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor:
                            AppColors.textDark.withValues(alpha: 0.8),
                        colorText: Colors.white);
                  },
                ),
                _buildOptionItem(
                  icon: Icons.security_outlined,
                  title: TrKeys.privacy.tr,
                  textStyle: optionItemStyle,
                  onTap: () {
                    Get.snackbar(
                        TrKeys.comingSoon.tr, TrKeys.featureComingSoon.tr,
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor:
                            AppColors.textDark.withValues(alpha: 0.8),
                        colorText: Colors.white);
                  },
                ),
                _buildOptionItem(
                  icon: Icons.help_outline_outlined,
                  title: TrKeys.help.tr,
                  textStyle: optionItemStyle,
                  onTap: () {
                    Get.snackbar(
                        TrKeys.comingSoon.tr, TrKeys.featureComingSoon.tr,
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor:
                            AppColors.textDark.withValues(alpha: 0.8),
                        colorText: Colors.white);
                  },
                ),
                const SizedBox(height: AppDimensions.lg),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAvatar(String? avatarUrl, ProfileController controller) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CachedAvatar(
          url: avatarUrl,
          radius: 60, // Radio del avatar principal
        ),
        // Podrías añadir un botón para cambiar el avatar aquí si lo deseas
        // Positioned(
        //   right: 0,
        //   bottom: 0,
        //   child: Material(
        //     color: AppColors.primary,
        //     shape: CircleBorder(),
        //     elevation: AppDimensions.elevationXs,
        //     child: InkWell(
        //       onTap: () {
        //         // TODO: Lógica para cambiar avatar
        //         Get.snackbar("Avatar", "Cambiar avatar (pendiente)");
        //       },
        //       customBorder: CircleBorder(),
        //       child: Padding(
        //         padding: const EdgeInsets.all(AppDimensions.xs),
        //         child: Icon(Icons.edit, color: Colors.white, size: AppDimensions.iconSm),
        //       ),
        //     ),
        //   ),
        // )
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required TextStyle titleStyle,
    required TextStyle valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(
                AppDimensions.sm), // Reducido para un look más compacto
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusMd), // Bordes más suaves
            ),
            child: Icon(icon, color: color, size: AppDimensions.iconMd - 2),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: titleStyle),
                const SizedBox(height: AppDimensions.xs),
                Text(value, style: valueStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required TextStyle textStyle,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.md -
                AppDimensions.xs, // Ligeramente menos padding vertical
            horizontal: AppDimensions
                .xs, // Menos padding horizontal para alinear con info items
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: AppColors.primary, size: AppDimensions.iconMd - 2),
              const SizedBox(width: AppDimensions.md),
              Expanded(child: Text(title, style: textStyle)),
              const Icon(Icons.chevron_right,
                  color: AppColors.textLight, size: AppDimensions.iconSm),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date, BuildContext context) {
    if (date == null) {
      return Tr.t(TrKeys.notAvailable); // Nueva key: "N/A" o "No disponible"
    }
    // Para obtener el locale del sistema y formatear la fecha correctamente:
    final locale = Localizations.localeOf(context).toString();
    final formatter = DateFormat.yMMMd(locale); // Usar el locale del contexto
    return formatter.format(date);
  }
}

// Nuevas TrKeys sugeridas para profile_page.dart:
// TrKeys.profileTitle -> "Perfil" / "Profile"
// TrKeys.editProfileMenuItem -> "Editar Perfil" / "Edit Profile"
// TrKeys.errorLoadingProfile -> "Error al cargar perfil" / "Error loading profile"
// TrKeys.tryLoadingProfileAgain -> "Intenta cargar el perfil de nuevo." / "Try loading profile again."
// TrKeys.familyAssociated -> "Familia Asociada" / "Family Associated"
// TrKeys.noFamilyAssociated -> "Sin Familia Asociada" / "No Family Associated"
// TrKeys.featureComingSoon -> "Esta funcionalidad estará disponible pronto." / "This feature will be available soon."
// TrKeys.notAvailable -> "No disponible" / "Not available" (para la fecha si es null)
