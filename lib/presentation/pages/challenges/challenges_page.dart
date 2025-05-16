// lib/presentation/pages/challenges/challenges_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart'; // Asegúrate de que esta importación sea correcta
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/assigned_challenge.dart';
import 'package:kidsdo/presentation/controllers/auth_controller.dart';
import 'package:kidsdo/presentation/controllers/challenge_controller.dart';
import 'package:kidsdo/routes.dart';

class ChallengesPage extends StatelessWidget {
  const ChallengesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final ChallengeController challengeController =
        Get.find<ChallengeController>(); // Para las estadísticas

    // Definir el estilo de texto para el título del AppBar consistentemente
    const appBarTitleStyle = TextStyle(
      fontFamily:
          'Poppins', // Asegúrate de que Poppins esté configurado en tu tema
      fontWeight:
          FontWeight.w600, // O el peso que prefieras para títulos de AppBar
      fontSize: AppDimensions.fontLg, // Ajusta según tu escala tipográfica
      color: AppColors
          .textDark, // O Colors.white si el AppBar usa AppColors.primary
    );

    // Definir el color de los iconos del AppBar
    // final appBarIconColor = AppColors.textMedium; // O Colors.white si el AppBar usa AppColors.primary

    return Scaffold(
      backgroundColor: AppColors.background, // Fondo general de la página
      appBar: AppBar(
        title: Text(Tr.t(TrKeys.challenges),
            style: appBarTitleStyle), // Título específico de la página
        backgroundColor: AppColors
            .background, // O AppColors.primary para un AppBar con color
        elevation:
            AppDimensions.elevationXs, // Sombra muy sutil o 0.0 si es flat
        iconTheme: const IconThemeData(
          color: AppColors.textDark, // Color para el ícono de "atrás" si aplica
        ),
        actionsIconTheme: const IconThemeData(
          color: AppColors.textMedium, // Color para iconos de acción
        ),
        actions: [
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección de título y subtítulo de la página
                Text(
                  TrKeys.challenges.tr,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: AppDimensions.fontXxl, // Ejemplo: 28 o 32
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  TrKeys.challengesPageSubtitle.tr,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: AppDimensions.fontMd, // Ejemplo: 16
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: AppDimensions.xl),

                // Retos Activos
                _buildFeatureCard(
                  title: TrKeys.activeChallenges.tr,
                  description: TrKeys.challengesAsignedVisualEval.tr,
                  icon: Icons
                      .assignment_turned_in_outlined, // Icono más descriptivo
                  iconBackgroundColor: AppColors.primaryLight,
                  iconColor: AppColors.primary,
                  onTap: () => Get.toNamed(Routes.activeChallenges),
                ),
                const SizedBox(height: AppDimensions.md),

                // Evaluación en Lote
                _buildFeatureCard(
                  title: TrKeys.batchEvaluationPageTitle.tr,
                  description: TrKeys.batchEvaluationPageDescription.tr,
                  icon: Icons.rate_review_outlined,
                  iconBackgroundColor:
                      AppColors.secondaryLight, // Usar color secundario
                  iconColor: AppColors.secondary,
                  onTap: () => Get.toNamed(Routes.batchEvaluation),
                ),
                const SizedBox(height: AppDimensions.md),

                // Biblioteca de Retos
                _buildFeatureCard(
                  title: TrKeys.challengeLibrary.tr,
                  description: TrKeys.exploreChallengeLibrary.tr,
                  icon: Icons.menu_book_outlined,
                  iconBackgroundColor:
                      AppColors.tertiaryLight, // Usar color terciario
                  iconColor: AppColors.tertiary,
                  onTap: () => Get.toNamed(Routes.challengeLibrary),
                ),
                const SizedBox(height: AppDimensions.md),

                // Crear reto
                _buildFeatureCard(
                  title: TrKeys.createChallenge.tr,
                  description: TrKeys.createCustomChallenges.tr,
                  icon: Icons.add_circle_outline,
                  iconBackgroundColor:
                      AppColors.successLight, // Usar color de éxito o un neutro
                  iconColor: AppColors.success,
                  onTap: () => Get.toNamed(Routes.createChallenge),
                ),
                const SizedBox(height: AppDimensions.xl),

                // Sección de estadísticas rediseñada
                _buildStatsSection(challengeController),

                const SizedBox(height: AppDimensions.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconBackgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: AppDimensions.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
      ),
      color: AppColors.card, // Fondo blanco para la tarjeta
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
            AppDimensions.borderRadiusLg), // Para el efecto ripple
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.md), // Espaciado interno
          child: Row(
            children: [
              Container(
                width: 50, // Tamaño del contenedor del icono
                height: 50,
                decoration: BoxDecoration(
                  color:
                      iconBackgroundColor, // Color de fondo para el círculo del icono
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: AppDimensions.iconMd, // Tamaño del icono, ej: 28 o 30
                  color: iconColor, // Color del icono
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: AppDimensions.fontLg, // Ejemplo: 18
                        fontWeight: FontWeight.w600, // SemiBold
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      description,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: AppDimensions.fontSm, // Ejemplo: 14
                        color: AppColors.textMedium,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textLight, // Un color sutil para la flecha
                size: AppDimensions.iconSm, // Ejemplo: 24
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(ChallengeController controller) {
    return Card(
      elevation: AppDimensions.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
      ),
      color: AppColors.card,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.lg,
          horizontal: AppDimensions.md,
        ),
        child: Obx(() => Row(
              // Obx para reactividad si los valores cambian
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatistic(
                  icon: Icons.hourglass_top_outlined, // Icono actualizado
                  value: controller.assignedChallenges
                      .where((c) => c.status == AssignedChallengeStatus.active)
                      .length
                      .toString(),
                  label: TrKeys
                      .active.tr, // Usar una traducción más corta si es posible
                  color: AppColors.primary, // Color principal para "Activos"
                ),
                _buildStatistic(
                  icon: Icons.check_circle_outline, // Icono actualizado
                  value: controller.assignedChallenges
                      .where(
                          (c) => c.status == AssignedChallengeStatus.completed)
                      .length
                      .toString(),
                  label: TrKeys.completed.tr, // Usar una traducción más corta
                  color: AppColors.success, // Color de éxito para "Completados"
                ),
                _buildStatistic(
                  icon:
                      Icons.collections_bookmark_outlined, // Icono actualizado
                  value: controller.familyChallenges.length.toString(),
                  label: 'pruebas', // Usar una traducción más corta
                  color:
                      AppColors.tertiary, // Color terciario para "Biblioteca"
                ),
              ],
            )),
      ),
    );
  }

  Widget _buildStatistic({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1), // Fondo suave con opacidad
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color, // Color principal para el icono
            size: AppDimensions.iconMd - 2, // Tamaño del icono, ej: 26
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: AppDimensions.fontLg, // Ejemplo: 20
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: AppDimensions.xs),
        SizedBox(
          width: 80, // Ancho para permitir dos líneas si es necesario
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: AppDimensions.fontXs, // Ejemplo: 12
              color: AppColors.textMedium,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
