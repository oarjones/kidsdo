// File: kidsdo_gemini/lib/presentation/pages/challenges/challenges_library_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/challenge.dart';
import 'package:kidsdo/presentation/controllers/challenge_controller.dart';
import 'package:kidsdo/presentation/widgets/challenges/challenge_card.dart';
import 'package:kidsdo/presentation/widgets/challenges/challenge_filter_drawer.dart';
import 'package:kidsdo/routes.dart';

class ChallengesLibraryPage extends GetView<ChallengeController> {
  const ChallengesLibraryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TrKeys.challengeLibrary.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Abrir el Drawer de filtros
              Scaffold.of(context).openEndDrawer();
            },
            tooltip: TrKeys.filterChallenges.tr,
          ),
          Obx(() => controller.dataSource.value == 'firestore'
              ? IconButton(
                  icon: const Icon(Icons.cloud_done),
                  tooltip: TrKeys.cloudSyncActive.tr,
                  onPressed: () {
                    // Mostrar diálogo informativo
                    Get.dialog(
                      AlertDialog(
                        title: Text(TrKeys.cloudSync.tr),
                        content: Text(TrKeys.cloudSyncInfo.tr),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: Text(TrKeys.ok.tr),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.cloud_sync),
                  tooltip: TrKeys.syncWithCloud.tr,
                  onPressed: () {
                    // Intentar sincronizar
                    controller.loadPredefinedChallenges();
                  },
                )),
          // Menú de opciones (Importar/Exportar) - Simplificado
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'import':
                  _showImportDialog(context);
                  break;
                case 'export_all': // Exportar todos los retos filtrados
                  _handleExport(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'import',
                child: ListTile(
                  leading: const Icon(Icons.download),
                  title: Text(TrKeys.importChallenges.tr),
                ),
              ),
              PopupMenuItem(
                // Cambiado para exportar todos los filtrados
                value: 'export_all',
                child: ListTile(
                  leading: const Icon(Icons.upload),
                  title: Text(TrKeys.exportFiltered.tr),
                  // Opcional: mostrar el número de retos filtrados
                  trailing: Obx(() => Text(
                        controller.filteredChallenges.length.toString(),
                        style: const TextStyle(color: Colors.grey),
                      )),
                ),
              ),
              // Se eliminan opciones de selección múltiple
            ],
          ),
        ],
      ),
      endDrawer: const ChallengeFilterDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Barra de búsqueda
            Padding(
              padding:
                  const EdgeInsets.all(AppDimensions.md), // Padding ajustado
              child: TextField(
                controller: controller.searchController,
                decoration: InputDecoration(
                  hintText: TrKeys.searchChallenges.tr,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            controller.searchController.clear();
                            controller.updateSearchQuery('');
                          },
                        )
                      : const SizedBox.shrink()),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.md,
                      horizontal: AppDimensions.md), // Ajustar padding interno
                ),
                onChanged: (value) {
                  controller.updateSearchQuery(value);
                },
              ),
            ),

            // Chips para filtros rápidos
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md), // Padding ajustado
              child: Obx(() => Row(
                    children: [
                      // Chip para filtro actual de categoría
                      if (controller.filterCategory.value != null)
                        Padding(
                          padding: const EdgeInsets.only(
                              right: AppDimensions.xs), // Espacio ajustado
                          child: Chip(
                            label: Text(_getCategoryName(
                                controller.filterCategory.value!)),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              controller.setFilterCategory(null);
                            },
                            backgroundColor: AppColors.primaryLight,
                            visualDensity:
                                VisualDensity.compact, // Compactar chip
                          ),
                        ),

                      // Chip para rango de edad si está filtrado
                      if (controller.filterMinAge.value > 0 ||
                          controller.filterMaxAge.value < 18)
                        Padding(
                          padding: const EdgeInsets.only(
                              right: AppDimensions.xs), // Espacio ajustado
                          child: Chip(
                            label: Text(
                                "${controller.filterMinAge.value}-${controller.filterMaxAge.value} ${TrKeys.years.tr}"),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              controller.setAgeRange(0, 18);
                            },
                            backgroundColor: AppColors.infoLight,
                            visualDensity:
                                VisualDensity.compact, // Compactar chip
                          ),
                        ),

                      // Chip para mostrar solo apropiados por edad
                      if (controller.showOnlyAgeAppropriate.value)
                        Padding(
                          padding: const EdgeInsets.only(
                              right: AppDimensions.xs), // Espacio ajustado
                          child: Chip(
                            label: Text(TrKeys.ageAppropriate.tr),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              controller.toggleAgeAppropriate(false);
                            },
                            backgroundColor: AppColors.successLight,
                            visualDensity:
                                VisualDensity.compact, // Compactar chip
                          ),
                        ),

                      // Mostrar chip para limpiar todos los filtros si hay alguno activo
                      if (controller.filterCategory.value != null ||
                          controller.filterMinAge.value > 0 ||
                          controller.filterMaxAge.value < 18 ||
                          controller.showOnlyAgeAppropriate.value)
                        ActionChip(
                          label: Text(TrKeys.clearAllFilters.tr),
                          onPressed: () {
                            controller.clearFilters();
                          },
                          avatar: const Icon(Icons.filter_list_off, size: 18),
                          visualDensity:
                              VisualDensity.compact, // Compactar chip
                        ),
                    ],
                  )),
            ),

            const SizedBox(height: AppDimensions.sm), // Espacio ajustado

            // Contador de resultados y adaptación de edad
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md), // Padding ajustado
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Contador de resultados con indicador de origen
                  Row(
                    children: [
                      Obx(() => Text(
                            "${controller.filteredChallenges.length} ${controller.filteredChallenges.length == 1 ? TrKeys.challengeFound.tr : TrKeys.challengesFound.tr}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: AppDimensions.fontSm, // Tamaño ajustado
                            ),
                          )),
                      const SizedBox(
                          width: AppDimensions.xs), // Espacio ajustado
                      // Indicador de origen de datos
                      Obx(() {
                        Widget icon;
                        String tooltip;

                        switch (controller.dataSource.value) {
                          case 'firestore':
                            icon = const Icon(Icons.cloud_done,
                                size: 18, color: Colors.green);
                            tooltip = TrKeys.cloudDataSource.tr;
                            break;
                          case 'local':
                            icon = const Icon(Icons.smartphone,
                                size: 18, color: Colors.orange);
                            tooltip = TrKeys.localDataSource.tr;
                            break;
                          case 'loading':
                          default:
                            icon = const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                            tooltip = TrKeys.loadingDataSource.tr;
                        }

                        return Tooltip(
                          message: tooltip,
                          child: icon,
                        );
                      }),

                      // Botón para sincronizar si es necesario
                      Obx(() => controller.dataSource.value == 'local'
                          ? IconButton(
                              icon: const Icon(Icons.sync, size: 18),
                              tooltip: TrKeys.syncWithCloud.tr,
                              onPressed: () {
                                controller.loadPredefinedChallenges();
                              },
                              visualDensity:
                                  VisualDensity.compact, // Compactar botón
                              padding: EdgeInsets
                                  .zero, // Eliminar padding por defecto
                            )
                          : const SizedBox.shrink()),
                    ],
                  ),

                  // Selector de edad para adaptación
                  Row(
                    children: [
                      Text(TrKeys.childAge.tr,
                          style: const TextStyle(
                              fontSize:
                                  AppDimensions.fontSm)), // Tamaño ajustado
                      const SizedBox(
                          width: AppDimensions.xs), // Espacio ajustado
                      Obx(() => DropdownButton<int>(
                            value: controller.selectedChildAge.value,
                            items: List.generate(
                                    16, (index) => index + 3) // De 3 a 18 años
                                .map((age) => DropdownMenuItem<int>(
                                      value: age,
                                      child: Text(age.toString()),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                controller.selectedChildAge.value = value;
                                controller.applyFilters();
                              }
                            },
                            isDense: true, // Compactar dropdown
                            iconSize: 18, // Tamaño ajustado
                          )),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.sm), // Espacio ajustado

            // Lista de retos
            Expanded(
              child: Obx(() {
                if (controller.isLoadingPredefinedChallenges.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.lg),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            controller.errorMessage.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              controller.loadPredefinedChallenges();
                            },
                            icon: const Icon(Icons.refresh),
                            label: Text(TrKeys.retry.tr),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (controller.filteredChallenges.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(
                          AppDimensions.lg), // Padding ajustado
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off,
                              size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            TrKeys.noChallengesFound.tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            TrKeys.tryChangingFilters.tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              controller.clearFilters();
                            },
                            icon: const Icon(Icons.filter_list_off),
                            label: Text(TrKeys.clearAllFilters.tr),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(
                      AppDimensions.md), // Padding ajustado
                  itemCount: controller.filteredChallenges.length,
                  itemBuilder: (context, index) {
                    final challenge = controller.filteredChallenges[index];

                    // Adaptar puntos según la edad seleccionada
                    final adaptedPoints = controller.adaptPointsByAge(
                      challenge.points,
                      challenge.ageRange['min'] as int,
                      challenge.ageRange['max'] as int,
                      controller.selectedChildAge.value,
                    );

                    return ChallengeCard(
                      challenge: challenge,
                      adaptedPoints: adaptedPoints,
                      childAge: controller.selectedChildAge.value,
                      // Ya no hay selección múltiple
                      isSelected: false.obs, // Siempre false
                      onSelect: () {}, // No hace nada
                      // Eliminado el botón "Añadir a mi Familia"
                      onConvert: () => {}, // No hace nada aquí
                      // Al pulsar la tarjeta o el botón "Detalles" se muestra el modal
                      onTap: () => _showChallengeDetail(
                          context, challenge, adaptedPoints),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      // Se elimina el FloatingActionButton para selección múltiple
      // floatingActionButton: Obx(() {
      //   if (controller.selectedChallengeIds.isEmpty) {
      //     return const SizedBox.shrink();
      //   }

      //   return FloatingActionButton.extended(
      //     onPressed: () => _showSelectionOptions(context),
      //     label: Text(
      //       "${TrKeys.assignChallenge.tr}: ${controller.selectedChallengeIds.length} ${controller.selectedChallengeIds.length == 1 ? TrKeys.challengeSingular.tr : TrKeys.challengesPlural.tr}",
      //       style: const TextStyle(fontSize: 16),
      //     ),
      //     icon: const Icon(Icons.assignment_ind),
      //     backgroundColor: AppColors.primary,
      //     extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
      //   );
      // }),
    );
  }

  // Se elimina _showSelectionOptions ya que no hay selección múltiple

  // Se elimina _importSelectedToFamily

  // Se elimina _exportSelected

  // Se elimina _selectAll

  // Mostrar diálogo de importación
  void _showImportDialog(BuildContext context) {
    final TextEditingController jsonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(TrKeys.importChallenges.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(TrKeys.importInstructions.tr),
            const SizedBox(height: 16),
            TextField(
              controller: jsonController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: TrKeys.pasteJsonHere.tr,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(TrKeys.cancel.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (jsonController.text.isNotEmpty) {
                controller.importChallengesFromJson(jsonController.text);
              }
            },
            child: Text(TrKeys.import.tr),
          ),
        ],
      ),
    );
  }

  // Manejar exportación de todos los retos filtrados
  void _handleExport(BuildContext context) {
    // Captura el BuildContext actual en una variable local
    //final currentContext = context;

    // Guarda una referencia local a los retos filtrados
    final challengesToExport =
        List<Challenge>.from(controller.filteredChallenges);

    if (challengesToExport.isEmpty) {
      Get.snackbar(
        TrKeys.warning.tr,
        TrKeys.noChallengesFound.tr, // Mensaje si no hay retos para exportar
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber.shade50,
        colorText: Colors.amber.shade900,
      );
      return;
    }

    controller.exportChallengesToJson(challengesToExport).then((jsonString) {
      // No podemos usar mounted, así que verificamos si Navigator está disponible
      if (jsonString.isNotEmpty) {
        // Usar Get.context en lugar de currentContext
        if (Get.context != null) {
          _showExportResult(Get.context!, jsonString);
        } else {
          // Fallback: mostrar un snackbar que no requiere contexto
          Get.snackbar(
            TrKeys.exportSuccess.tr,
            TrKeys.jsonCopied.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green,
          );
        }
      }
    });
  }

  // Mostrar resultado de exportación
  void _showExportResult(BuildContext context, String jsonString) {
    // Verificar si podemos mostrar un diálogo
    if (!Navigator.canPop(context)) {
      // El contexto ya no es válido, mostrar snackbar en su lugar
      Get.snackbar(
        TrKeys.exportSuccess.tr,
        TrKeys.jsonExported.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(TrKeys.exportResult.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(TrKeys.exportSuccess.tr),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: SelectableText(
                  jsonString,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(TrKeys.close.tr),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy),
            label: Text(TrKeys.copyToClipboard.tr),
            onPressed: () {
              // Aquí se implementaría la función para copiar al portapapeles
              Clipboard.setData(ClipboardData(text: jsonString));
              Navigator.pop(dialogContext);
              Get.snackbar(
                TrKeys.copied.tr,
                TrKeys.jsonCopied.tr,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green.shade50,
                colorText: Colors.green,
              );
            },
          ),
        ],
      ),
    );
  }

  // Mostrar detalle de un reto (modificado)
  void _showChallengeDetail(
      BuildContext context, Challenge challenge, int adaptedPoints) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Encabezado con icono y título
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(challenge.category)
                        .withValues(alpha: 0.1), // Color basado en categoría
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getCategoryIcon(challenge.category),
                    color: _getCategoryColor(
                        challenge.category), // Color basado en categoría
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          _buildCategoryChip(challenge.category),
                          const SizedBox(width: 8), // Espacio entre chips
                          _buildDurationChip(
                              challenge.duration), // Mostrar chip de duración
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Descripción
            Text(
              TrKeys.description.tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              challenge.description,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),

            // Detalles del reto
            Text(
              TrKeys.challengeDetails.tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildDetailRow(TrKeys.ageRange.tr,
                "${challenge.ageRange['min']} - ${challenge.ageRange['max']} ${TrKeys.years.tr}"),
            _buildDetailRow(
                TrKeys.originalPoints.tr, challenge.points.toString()),
            _buildDetailRow(TrKeys.adaptedPoints.tr, adaptedPoints.toString()),

            // Mostrar si es plantilla o reto de familia
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  challenge.isTemplate ? Icons.copy_all : Icons.home,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  challenge.isTemplate
                      ? 'Template Challenge'
                      : 'Family Challenge', // Traducciones pendientes
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Botón para asignar a niño/s (nuevo)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.assignment_ind),
                label: Text(TrKeys.assignToChildren.tr),
                onPressed: () {
                  Navigator.pop(context); // Cerrar el modal
                  // Seleccionar este reto en el controlador antes de navegar
                  controller.selectedChallenge.value = challenge;
                  // Navegar a la página de asignación
                  Get.toNamed(Routes.assignChallenge);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor:
                      AppColors.secondary, // Color diferente para asignar
                ),
              ),
            ),

            // Botones existentes (Edit, Delete) - Solo si es un reto de la familia
            if (!challenge.isTemplate || challenge.familyId != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: Text(TrKeys.edit.tr),
                        onPressed: () {
                          Navigator.pop(context);
                          // Seleccionar este reto en el controlador
                          controller.selectChallengeForEdit(challenge);
                          // Navegar a la página de edición
                          Get.toNamed(Routes.editChallenge);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: Text(TrKeys.delete.tr),
                        onPressed: () {
                          Navigator.pop(context); // Cerrar el modal
                          _showDeleteConfirmation(context,
                              challenge); // Mostrar diálogo de confirmación
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Opción para añadir a mi familia si es un template (comentado, no se añaden retos a familia)
            // if (challenge.isTemplate)
            //   Padding(
            //     padding: const EdgeInsets.only(top: 16.0),
            //     child: SizedBox(
            //       width: double.infinity,
            //       child: OutlinedButton.icon(
            //         icon: const Icon(Icons.add_circle_outline),
            //         label: Text(TrKeys.addToFamily.tr),
            //         onPressed: () {
            //           Navigator.pop(context);
            //           controller.convertTemplateToFamilyChallenge(challenge);
            //         },
            //         style: OutlinedButton.styleFrom(
            //           padding: const EdgeInsets.symmetric(vertical: 12),
            //         ),
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  // Construir fila de detalle
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Construir chip de categoría
  Widget _buildCategoryChip(ChallengeCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getCategoryColor(category)
            .withValues(alpha: 0.1), // Color basado en categoría
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getCategoryName(category),
        style: TextStyle(
          fontSize: 12,
          color: _getCategoryColor(category), // Color basado en categoría
        ),
      ),
    );
  }

  // Nuevo: Construir chip de duración
  Widget _buildDurationChip(ChallengeDuration duration) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors
            .infoLight, // Puedes elegir un color específico para duración
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getDurationName(duration), // Función para obtener nombre de duración
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.info, // Color específico para duración
        ),
      ),
    );
  }

  // Diálogo de confirmación de eliminación - Modificado
  void _showDeleteConfirmation(BuildContext context, Challenge challenge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(TrKeys.delete.tr),
        content: Text(TrKeys.confirmDeleteProfile
            .trParams({'name': challenge.title})), // Usar nombre del reto
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(TrKeys.cancel.tr),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Eliminar el reto
              controller.deleteChallenge(challenge.id).then((_) {
                // No se vuelve a la página anterior aquí, solo se elimina de la lista
              });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(TrKeys.delete.tr),
          ),
        ],
      ),
    );
  }

  // Funciones auxiliares para traducir categorías y frecuencias
  String _getCategoryName(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.hygiene:
        return TrKeys.categoryHygiene.tr;
      case ChallengeCategory.school:
        return TrKeys.categorySchool.tr;
      case ChallengeCategory.order:
        return TrKeys.categoryOrder.tr;
      case ChallengeCategory.responsibility:
        return TrKeys.categoryResponsibility.tr;
      case ChallengeCategory.help:
        return TrKeys.categoryHelp.tr;
      case ChallengeCategory.special:
        return TrKeys.categorySpecial.tr;
      case ChallengeCategory.sibling:
        return TrKeys.categorySibling.tr;
    }
  }

  // Obtener color de categoría
  Color _getCategoryColor(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.hygiene:
        return Colors.blue;
      case ChallengeCategory.school:
        return Colors.purple;
      case ChallengeCategory.order:
        return Colors.teal;
      case ChallengeCategory.responsibility:
        return Colors.orange;
      case ChallengeCategory.help:
        return Colors.green;
      case ChallengeCategory.special:
        return Colors.pink;
      case ChallengeCategory.sibling:
        return Colors.indigo;
    }
  }

  // Obtener icono de categoría
  IconData _getCategoryIcon(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.hygiene:
        return Icons.clean_hands;
      case ChallengeCategory.school:
        return Icons.school;
      case ChallengeCategory.order:
        return Icons.cleaning_services;
      case ChallengeCategory.responsibility:
        return Icons.assignment_turned_in;
      case ChallengeCategory.help:
        return Icons.emoji_people;
      case ChallengeCategory.special:
        return Icons.celebration;
      case ChallengeCategory.sibling:
        return Icons.family_restroom;
    }
  }

  // Obtener nombre de duración
  String _getDurationName(ChallengeDuration duration) {
    switch (duration) {
      case ChallengeDuration.weekly:
        return TrKeys.durationWeekly.tr;
      case ChallengeDuration.monthly:
        return TrKeys.durationMonthly.tr;
      case ChallengeDuration.quarterly:
        return TrKeys.durationQuarterly.tr;
      case ChallengeDuration.yearly:
        return TrKeys.durationYearly.tr;
      case ChallengeDuration.punctual:
        return TrKeys.durationPunctual.tr;
    }
  }
}
