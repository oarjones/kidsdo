// lib/presentation/pages/challenges/challenges_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/assigned_challenge.dart';
import 'package:kidsdo/presentation/controllers/challenge_controller.dart';
import 'package:kidsdo/routes.dart';

class ChallengesPage extends GetView<ChallengeController> {
  const ChallengesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Usamos MediaQuery para obtener el tamaño de la pantalla si necesitamos ajustar algo basado en ella
    // final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // Eliminamos el AppBar para un diseño más limpio como en la imagen
      // appBar: AppBar(
      //   title: Text(TrKeys.challenges.tr),
      //   centerTitle: true,
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          // Usamos SingleChildScrollView para evitar overflows si el contenido es largo, crucial para responsividad
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección de título y subtítulo
                Text(
                  TrKeys.challenges.tr,
                  style: const TextStyle(
                    fontSize: 28, // Aumentamos el tamaño para que resalte más
                    fontWeight: FontWeight.bold,
                    color: Colors
                        .black87, // Color de texto más oscuro para contraste
                  ),
                ),
                const SizedBox(height: AppDimensions.sm), // Espacio reducido
                Text(
                  TrKeys.challengesPageSubtitle.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey, // Color gris para el subtítulo
                  ),
                ),
                const SizedBox(height: AppDimensions.xl),

                // Retos Activos - con degradado y sombra
                _buildFeatureCard(
                  title: TrKeys.activeChallenges.tr,
                  description: TrKeys.challengesAsignedVisualEval.tr,
                  icon: Icons.assignment,
                  // Usamos un degradado en lugar de un color sólido
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6A1B9A),
                      Color(0xFFAB47BC)
                    ], // Tonos morados
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => Get.toNamed(Routes.activeChallenges),
                ),

                const SizedBox(height: AppDimensions.lg),

                // **NUEVO:** Tarjeta para Evaluación en Lote
                _buildFeatureCard(
                  title: TrKeys
                      .batchEvaluationPageTitle.tr, // Usar traducción pendiente
                  description: TrKeys.batchEvaluationPageDescription
                      .tr, // Traducción pendiente
                  icon: Icons.rate_review, // Icono sugerido para evaluación
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF00796B), // Color Teal oscuro
                      Color(0xFF4DB6AC), // Color Teal claro
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => Get.toNamed(
                      Routes.batchEvaluation), // Navegar a la nueva página
                ),

                const SizedBox(
                    height: AppDimensions
                        .lg), // Añadir espacio después de la nueva tarjeta

                // Biblioteca de Retos - con degradado y sombra
                _buildFeatureCard(
                  title: TrKeys.challengeLibrary.tr,
                  description: TrKeys.exploreChallengeLibrary.tr,
                  icon: Icons.menu_book,
                  // Usamos un degradado diferente
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF00ACC1),
                      Color(0xFF4DD0E1)
                    ], // Tonos turquesa
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => Get.toNamed(Routes.challengeLibrary),
                ),

                const SizedBox(height: AppDimensions.lg),

                // Crear reto - con degradado y sombra
                _buildFeatureCard(
                  title: TrKeys.createChallenge.tr,
                  description: TrKeys.createCustomChallenges.tr,
                  icon: Icons.add,
                  // Usamos otro degradado
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF66BB6A),
                      Color(0xFFA5D6A7)
                    ], // Tonos verdes
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => Get.toNamed(Routes.createChallenge),
                ),

                const SizedBox(
                    height:
                        AppDimensions.xl), // Espacio antes de las estadísticas

                // Sección de estadísticas rediseñada
                _buildStatsSection(),

                // Puedes añadir más espacio al final si es necesario
                const SizedBox(height: AppDimensions.lg),
              ],
            ),
          ),
        ),
      ),
      // Aquí podrías añadir un BottomNavigationBar si tu diseño lo incluye
      // bottomNavigationBar: BottomNavigationBar(...)
    );
  }

  // Modificamos la firma para aceptar un Gradient
  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required Gradient gradient, // Ahora aceptamos un Gradient
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
        child: Container(
          width: double
              .infinity, // Esto ayuda a que la tarjeta ocupe todo el ancho disponible
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.lg,
            horizontal: AppDimensions.xl,
          ),
          decoration: BoxDecoration(
            // Usamos el degradado en la decoración
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withValues(alpha: 0.2), // Sombra más pronunciada
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icono con fondo blanco semitransparente y forma circular
              Container(
                width: 50, // Tamaño del icono aumentado
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white
                      .withValues(alpha: 0.3), // Fondo blanco semitransparente
                  shape: BoxShape.circle, // Forma circular
                ),
                child: Icon(
                  icon,
                  size: 30, // Tamaño del icono
                  color: Colors.white, // Color del icono blanco
                ),
              ),
              const SizedBox(width: AppDimensions.md),

              // Texto en blanco - Usamos Expanded para que ocupe el espacio restante
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20, // Tamaño de título aumentado
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors
                            .white70, // Color blanco con transparencia para la descripción
                      ),
                    ),
                  ],
                ),
              ),

              // Flecha de navegación
              const Icon(
                // Usamos solo el icono sin un contenedor adicional si no es necesario un fondo
                Icons.chevron_right,
                color: Colors.white, // Color blanco
                size: 24, // Tamaño aumentado
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Obx(() => Container(
          width: double.infinity, // Ocupa todo el ancho disponible
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.lg,
            horizontal: AppDimensions.md,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceAround, // Distribuye el espacio entre los elementos
            children: [
              _buildStatistic(
                icon: Icons.hourglass_top,
                value: controller.assignedChallenges
                    .where((c) => c.status == AssignedChallengeStatus.active)
                    .length
                    .toString(),
                label: TrKeys.activeChallengesLabel.tr,
                color: const Color(0xFF6A1B9A), // Color morado para el icono
              ),
              _buildStatistic(
                icon: Icons.check_circle,
                value: controller.assignedChallenges
                    .where((c) => c.status == AssignedChallengeStatus.completed)
                    .length
                    .toString(),
                label: TrKeys.completedChallengesStat.tr,
                color: const Color(0xFF66BB6A), // Color verde para el icono
              ),
              _buildStatistic(
                icon: Icons.menu_book,
                value: controller.familyChallenges.length.toString(),
                label: TrKeys.libraryChallengesStat.tr,
                color: const Color(0xFF00ACC1), // Color turquesa para el icono
              ),
            ],
          ),
        ));
  }

  Widget _buildStatistic({
    required IconData icon,
    required String value,
    required String label,
    required Color color, // Color para el icono y el valor
  }) {
    return Column(
      // Los elementos se apilan verticalmente dentro de cada estadística
      children: [
        Container(
          width: 48, // Tamaño fijo, podrías hacerlo responsive con MediaQuery
          height: 48, // Tamaño fijo, podrías hacerlo responsive con MediaQuery
          decoration: BoxDecoration(
            color: color.withValues(
                alpha: 0.1), // Fondo semitransparente del color principal
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color, // Color del icono
            size: 28, // Tamaño del icono, podrías hacerlo responsive
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20, // Tamaño del valor aumentado
            fontWeight: FontWeight.bold,
            color:
                Colors.black87, // Color oscuro para el valor - Mejor contraste
          ),
        ),
        const SizedBox(height: AppDimensions.xs),
        SizedBox(
          width:
              80, // Ancho fijo para el texto de la etiqueta, podrías ajustarlo
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12, // Tamaño de la etiqueta, podrías hacerlo responsive
              color: Colors
                  .black54, // Color gris más oscuro para la etiqueta - Mejor contraste
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
