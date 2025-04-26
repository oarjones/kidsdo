import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/family_child.dart';
import 'package:kidsdo/presentation/controllers/child_access_controller.dart';
import 'package:kidsdo/presentation/widgets/common/cached_avatar.dart';
import 'package:kidsdo/routes.dart';
import 'package:kidsdo/presentation/widgets/auth/parental_pin_dialog.dart';

class ChildProfileSelectionPage extends GetView<ChildAccessController> {
  const ChildProfileSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Cargar perfiles infantiles al entrar a la página
    if (controller.availableChildren.isEmpty) {
      controller.loadAvailableChildProfiles();
    }

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          // Mostrar carga
          if (controller.status.value == ChildAccessStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Mostrar error si hay
          if (controller.status.value == ChildAccessStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppDimensions.md),
                    Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    ElevatedButton.icon(
                      onPressed: controller.loadAvailableChildProfiles,
                      icon: const Icon(Icons.refresh),
                      label: Text(TrKeys.retry.tr),
                    ),
                  ],
                ),
              ),
            );
          }

          // No hay perfiles infantiles
          if (controller.availableChildren.isEmpty) {
            return _buildEmptyState();
          }

          // Mostrar selección de perfiles
          return _buildProfilesSelection();
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.child_care,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),
                Text(
                  TrKeys.noChildProfilesAccess.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontLg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                Text(
                  TrKeys.noChildProfilesAccessMessage.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontMd,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Botón para volver al modo parental
        Positioned(
          top: AppDimensions.md,
          right: AppDimensions.md,
          child: _buildParentModeButton(),
        ),
      ],
    );
  }

  Widget _buildProfilesSelection() {
    return Stack(
      children: [
        Column(
          children: [
            // Encabezado
            Container(
              padding: const EdgeInsets.all(AppDimensions.lg),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(
                    TrKeys.whoIsUsing.tr,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontXl,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    TrKeys.selectProfileMessage.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontMd,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),

            // Perfiles
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(AppDimensions.lg),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65, // Ajustado para evitar overflow
                  crossAxisSpacing: AppDimensions.lg,
                  mainAxisSpacing: AppDimensions.xl,
                ),
                itemCount: controller.availableChildren.length,
                itemBuilder: (context, index) {
                  final child = controller.availableChildren[index];
                  return _buildProfileCard(child);
                },
              ),
            ),
          ],
        ),

        // Botón para volver al modo parental
        Positioned(
          bottom: AppDimensions.xl,
          left: 0,
          right: 0,
          child: Center(
            child: _buildParentModeButton(),
          ),
        ),
      ],
    );
  }

  // Widget _buildProfileCard(FamilyChild child) {
  //   // Obtener color basado en la configuración
  //   final Color themeColor = _getProfileColor(child.settings);

  //   return Card(
  //     elevation: AppDimensions.elevationMd,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
  //     ),
  //     // Asegurar que el contenedor tenga un tamaño fijo para evitar overflow
  //     child: SizedBox(
  //       width: 180, // Ancho fijo
  //       child: Column(
  //         mainAxisSize:
  //             MainAxisSize.min, // Este es importante para evitar overflow
  //         children: [
  //           Padding(
  //             padding: const EdgeInsets.all(AppDimensions.md),
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 // Avatar
  //                 Hero(
  //                   tag: 'child_avatar_${child.id}',
  //                   child: child.avatarUrl != null
  //                       ? CachedAvatar(
  //                           url: child.avatarUrl,
  //                           radius: 50,
  //                         )
  //                       : CircleAvatar(
  //                           radius: 50,
  //                           backgroundColor: themeColor.withValues(alpha: 0.2),
  //                           child: Icon(
  //                             Icons.child_care,
  //                             size: 50,
  //                             color: themeColor,
  //                           ),
  //                         ),
  //                 ),
  //                 const SizedBox(height: AppDimensions.md),

  //                 // Nombre
  //                 Text(
  //                   child.name,
  //                   style: const TextStyle(
  //                     fontSize: AppDimensions.fontLg,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                   textAlign: TextAlign.center,
  //                   maxLines: 1,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),

  //                 // Edad
  //                 Text(
  //                   '${child.age} ${TrKeys.yearsOld.tr}',
  //                   style: const TextStyle(
  //                     fontSize: AppDimensions.fontSm,
  //                     color: AppColors.textMedium,
  //                   ),
  //                 ),

  //                 const SizedBox(height: AppDimensions.sm),
  //               ],
  //             ),
  //           ),

  //           // Botón de acceso - Modificado para evitar overflow
  //           // Ahora usamos Material para dar estilo como un botón sin que cause overflow
  //           Material(
  //             color: themeColor,
  //             borderRadius: const BorderRadius.only(
  //               bottomLeft: Radius.circular(AppDimensions.borderRadiusLg),
  //               bottomRight: Radius.circular(AppDimensions.borderRadiusLg),
  //             ),
  //             child: InkWell(
  //               onTap: () => _selectProfile(child),
  //               borderRadius: const BorderRadius.only(
  //                 bottomLeft: Radius.circular(AppDimensions.borderRadiusLg),
  //                 bottomRight: Radius.circular(AppDimensions.borderRadiusLg),
  //               ),
  //               child: Container(
  //                 width: double.infinity,
  //                 padding: const EdgeInsets.symmetric(
  //                   vertical: AppDimensions.md,
  //                   horizontal: AppDimensions.md,
  //                 ),
  //                 alignment: Alignment.center,
  //                 child: Text(
  //                   TrKeys.accessProfile.tr,
  //                   style: const TextStyle(
  //                     color: Colors.white,
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: AppDimensions.fontMd,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildProfileCard(FamilyChild child) {
    // Mantenemos la firma original sin BuildContext
    final Color themeColor =
        _getProfileColor(child.settings); // Asume que _getProfileColor existe

    // Usar un contenedor SIN altura/anchura fija para adaptarse
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
            AppDimensions.borderRadiusLg), // Usa tus constantes
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // Importante: Recorta el contenido que se salga del borde redondeado
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch, // Asegura que los hijos llenen el ancho
        children: [
          // Sección Superior (Avatar y datos) - Ocupa el 70% del espacio vertical DISPONIBLE
          Expanded(
            flex: 7, // Proporción 7
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                  vertical: AppDimensions.sm), // Usa tus constantes
              child: Column(
                mainAxisAlignment: MainAxisAlignment
                    .center, // Centra verticalmente el contenido
                children: [
                  // Avatar
                  Hero(
                    tag: 'child_avatar_${child.id}',
                    child: child.avatarUrl != null
                        ? CachedAvatar(
                            // Usa tu widget CachedAvatar
                            url: child.avatarUrl,
                            radius: 45, // Puedes ajustar este valor
                          )
                        : CircleAvatar(
                            radius: 45, // Puedes ajustar este valor
                            backgroundColor:
                                themeColor.withAlpha(51), // alpha 0.2
                            child: Icon(
                              Icons.child_care,
                              size: 45, // Ajustar tamaño del icono
                              color: themeColor,
                            ),
                          ),
                  ),
                  const SizedBox(
                      height: AppDimensions.md), // Espacio (Usa tus constantes)

                  // Nombre
                  Text(
                    child.name,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontLg, // Usa tus constantes
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1, // Importante para evitar saltos de línea
                    overflow:
                        TextOverflow.ellipsis, // Corta el texto si es muy largo
                  ),

                  // Edad
                  Text(
                    '${child.age} ${TrKeys.yearsOld.tr}', // Usa tus claves de traducción
                    style: const TextStyle(
                      fontSize: AppDimensions.fontSm, // Usa tus constantes
                      color: AppColors.textMedium, // Usa tus colores
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Sección Inferior (Botón) - Ocupa el 30% del espacio vertical DISPONIBLE
          Expanded(
            flex: 3, // Proporción 3
            child: Material(
              // Usar Material para el color y el efecto ripple
              color: themeColor,
              // Aplicar forma SÓLO a las esquinas inferiores
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(
                      AppDimensions.borderRadiusLg), // Usa tus constantes
                  bottomRight: Radius.circular(
                      AppDimensions.borderRadiusLg), // Usa tus constantes
                ),
              ),
              child: InkWell(
                // InkWell para la interacción y el efecto ripple
                onTap: () =>
                    _selectProfile(child), // Asume que _selectProfile existe
                // BorderRadius para que el ripple coincida con la forma del Material
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(
                      AppDimensions.borderRadiusLg), // Usa tus constantes
                  bottomRight: Radius.circular(
                      AppDimensions.borderRadiusLg), // Usa tus constantes
                ),
                child: Center(
                  // Centra el texto dentro del botón
                  child: Padding(
                    // Padding interno para el texto del botón
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.sm,
                        vertical: AppDimensions.xs), // Usa tus constantes
                    child: Text(
                      TrKeys.accessProfile.tr, // Usa tus claves de traducción
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: AppDimensions.fontMd, // Usa tus constantes
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParentModeButton() {
    return ElevatedButton.icon(
      onPressed: _showParentPinDialog,
      icon: const Icon(Icons.lock),
      label: Text(TrKeys.parentMode.tr),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        shadowColor: Colors.black26,
        elevation: 4,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.lg,
          vertical: AppDimensions.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        ),
      ),
    );
  }

  // Muestra el diálogo para introducir el PIN de control parental
  void _showParentPinDialog() {
    ParentalPinDialog.show(
      customTitle: TrKeys.parentAccess.tr,
      customSubtitle: TrKeys.enterParentalPinMessage.tr,
    ).then((success) {
      if (success) {
        Get.offNamed(Routes.home);
      }
    });
  }

  // Selecciona un perfil infantil y navega a su dashboard
  void _selectProfile(FamilyChild child) {
    controller.activateChildProfile(child).then((_) {
      Get.offNamed(Routes.childDashboard);
    });
  }

  // Obtiene el color correspondiente a la configuración del perfil
  Color _getProfileColor(Map<String, dynamic> settings) {
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
