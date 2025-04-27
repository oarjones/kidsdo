import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
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
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'import':
                  _showImportDialog(context);
                  break;
                case 'export':
                  _handleExport(context);
                  break;
                case 'select_all':
                  _selectAll();
                  break;
                case 'clear_selection':
                  controller.clearSelection();
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
                value: 'export',
                child: ListTile(
                  leading: const Icon(Icons.upload),
                  title: Text(TrKeys.exportChallenges.tr),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'select_all',
                child: ListTile(
                  leading: const Icon(Icons.select_all),
                  title: Text(TrKeys.selectAll.tr),
                ),
              ),
              PopupMenuItem(
                value: 'clear_selection',
                child: ListTile(
                  leading: const Icon(Icons.clear_all),
                  title: Text(TrKeys.clearSelection.tr),
                ),
              ),
            ],
          ),
        ],
      ),
      endDrawer: const ChallengeFilterDrawer(),
      // Añadido SafeArea aquí
      body: SafeArea(
        child: Column(
          children: [
            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                ),
                onChanged: (value) {
                  controller.updateSearchQuery(value);
                },
              ),
            ),

            // Chips para filtros rápidos
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Obx(() => Row(
                    children: [
                      // Chip para filtro actual de categoría
                      if (controller.filterCategory.value != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Chip(
                            label: Text(_getCategoryName(
                                controller.filterCategory.value!)),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              controller.setFilterCategory(null);
                            },
                            backgroundColor: AppColors.primaryLight,
                          ),
                        ),

                      // Chip para filtro actual de frecuencia
                      if (controller.filterFrequency.value != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Chip(
                            label: Text(_getFrequencyName(
                                controller.filterFrequency.value!)),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              controller.setFilterFrequency(null);
                            },
                            backgroundColor: AppColors.secondaryLight,
                          ),
                        ),

                      // Chip para rango de edad si está filtrado
                      if (controller.filterMinAge.value > 0 ||
                          controller.filterMaxAge.value < 18)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Chip(
                            label: Text(
                                "${controller.filterMinAge.value}-${controller.filterMaxAge.value} ${TrKeys.years.tr}"),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              controller.setAgeRange(0, 18);
                            },
                            backgroundColor: AppColors.infoLight,
                          ),
                        ),

                      // Chip para mostrar solo apropiados por edad
                      if (controller.showOnlyAgeAppropriate.value)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Chip(
                            label: Text(TrKeys.ageAppropriate.tr),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              controller.toggleAgeAppropriate(false);
                            },
                            backgroundColor: AppColors.successLight,
                          ),
                        ),

                      // Mostrar chip para limpiar todos los filtros si hay alguno activo
                      if (controller.filterCategory.value != null ||
                          controller.filterFrequency.value != null ||
                          controller.filterMinAge.value > 0 ||
                          controller.filterMaxAge.value < 18 ||
                          controller.showOnlyAgeAppropriate.value)
                        ActionChip(
                          label: Text(TrKeys.clearAllFilters.tr),
                          onPressed: () {
                            controller.clearFilters();
                          },
                          avatar: const Icon(Icons.clear_all, size: 18),
                        ),
                    ],
                  )),
            ),

            const SizedBox(height: 8),

            // Contador de resultados y adaptación de edad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                            ),
                          )),
                      const SizedBox(width: 8),
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
                            )
                          : const SizedBox.shrink()),
                    ],
                  ),

                  // Selector de edad para adaptación
                  Row(
                    children: [
                      Text(TrKeys.childAge.tr,
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
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
                            isDense: true,
                          )),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Lista de retos
            Expanded(
              child: Obx(() {
                if (controller.isLoadingPredefinedChallenges.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return Center(
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
                  );
                }

                if (controller.filteredChallenges.isEmpty) {
                  return Center(
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
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
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
                      isSelected: controller.isChallengeSelected(challenge.id),
                      onSelect: () =>
                          controller.toggleChallengeSelection(challenge.id),
                      onConvert: () => controller
                          .convertTemplateToFamilyChallenge(challenge),
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
      // Botón flotante para acciones con selección
      floatingActionButton: Obx(() {
        if (controller.selectedChallengeIds.isEmpty) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton.extended(
          onPressed: () => _showSelectionOptions(context),
          label: Text(
              "${controller.selectedChallengeIds.length} ${TrKeys.selected.tr}"),
          icon: const Icon(Icons.check_circle),
          backgroundColor: AppColors.primary,
        );
      }),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text(TrKeys.challengeLibrary.tr),
  //       actions: [
  //         IconButton(
  //           icon: const Icon(Icons.filter_list),
  //           onPressed: () {
  //             Scaffold.of(context).openEndDrawer();
  //           },
  //           tooltip: TrKeys.filterChallenges.tr,
  //         ),
  //         Obx(() => controller.dataSource.value == 'firestore'
  //             ? IconButton(
  //                 icon: const Icon(Icons.cloud_done),
  //                 tooltip: TrKeys.cloudSyncActive.tr,
  //                 onPressed: () {
  //                   // Mostrar diálogo informativo
  //                   Get.dialog(
  //                     AlertDialog(
  //                       title: Text(TrKeys.cloudSync.tr),
  //                       content: Text(TrKeys.cloudSyncInfo.tr),
  //                       actions: [
  //                         TextButton(
  //                           onPressed: () => Get.back(),
  //                           child: Text(TrKeys.ok.tr),
  //                         ),
  //                       ],
  //                     ),
  //                   );
  //                 },
  //               )
  //             : IconButton(
  //                 icon: const Icon(Icons.cloud_sync),
  //                 tooltip: TrKeys.syncWithCloud.tr,
  //                 onPressed: () {
  //                   // Intentar sincronizar
  //                   controller.loadPredefinedChallenges();
  //                 },
  //               )),
  //         PopupMenuButton<String>(
  //           onSelected: (value) {
  //             switch (value) {
  //               case 'import':
  //                 _showImportDialog(context);
  //                 break;
  //               case 'export':
  //                 _handleExport(context);
  //                 break;
  //               case 'select_all':
  //                 _selectAll();
  //                 break;
  //               case 'clear_selection':
  //                 controller.clearSelection();
  //                 break;
  //             }
  //           },
  //           itemBuilder: (context) => [
  //             PopupMenuItem(
  //               value: 'import',
  //               child: ListTile(
  //                 leading: const Icon(Icons.download),
  //                 title: Text(TrKeys.importChallenges.tr),
  //               ),
  //             ),
  //             PopupMenuItem(
  //               value: 'export',
  //               child: ListTile(
  //                 leading: const Icon(Icons.upload),
  //                 title: Text(TrKeys.exportChallenges.tr),
  //               ),
  //             ),
  //             const PopupMenuDivider(),
  //             PopupMenuItem(
  //               value: 'select_all',
  //               child: ListTile(
  //                 leading: const Icon(Icons.select_all),
  //                 title: Text(TrKeys.selectAll.tr),
  //               ),
  //             ),
  //             PopupMenuItem(
  //               value: 'clear_selection',
  //               child: ListTile(
  //                 leading: const Icon(Icons.clear_all),
  //                 title: Text(TrKeys.clearSelection.tr),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //     endDrawer: const ChallengeFilterDrawer(),
  //     body: Column(
  //       children: [
  //         // Barra de búsqueda
  //         Padding(
  //           padding: const EdgeInsets.all(16.0),
  //           child: TextField(
  //             controller: controller.searchController,
  //             decoration: InputDecoration(
  //               hintText: TrKeys.searchChallenges.tr,
  //               prefixIcon: const Icon(Icons.search),
  //               suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
  //                   ? IconButton(
  //                       icon: const Icon(Icons.clear),
  //                       onPressed: () {
  //                         controller.searchController.clear();
  //                         controller.updateSearchQuery('');
  //                       },
  //                     )
  //                   : const SizedBox.shrink()),
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(12.0),
  //               ),
  //               filled: true,
  //               fillColor: Colors.grey.shade100,
  //             ),
  //             onChanged: (value) {
  //               controller.updateSearchQuery(value);
  //             },
  //           ),
  //         ),

  //         // Chips para filtros rápidos
  //         SingleChildScrollView(
  //           scrollDirection: Axis.horizontal,
  //           padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //           child: Obx(() => Row(
  //                 children: [
  //                   // Chip para filtro actual de categoría
  //                   if (controller.filterCategory.value != null)
  //                     Padding(
  //                       padding: const EdgeInsets.only(right: 8.0),
  //                       child: Chip(
  //                         label: Text(_getCategoryName(
  //                             controller.filterCategory.value!)),
  //                         deleteIcon: const Icon(Icons.close, size: 18),
  //                         onDeleted: () {
  //                           controller.setFilterCategory(null);
  //                         },
  //                         backgroundColor: AppColors.primaryLight,
  //                       ),
  //                     ),

  //                   // Chip para filtro actual de frecuencia
  //                   if (controller.filterFrequency.value != null)
  //                     Padding(
  //                       padding: const EdgeInsets.only(right: 8.0),
  //                       child: Chip(
  //                         label: Text(_getFrequencyName(
  //                             controller.filterFrequency.value!)),
  //                         deleteIcon: const Icon(Icons.close, size: 18),
  //                         onDeleted: () {
  //                           controller.setFilterFrequency(null);
  //                         },
  //                         backgroundColor: AppColors.secondaryLight,
  //                       ),
  //                     ),

  //                   // Chip para rango de edad si está filtrado
  //                   if (controller.filterMinAge.value > 0 ||
  //                       controller.filterMaxAge.value < 18)
  //                     Padding(
  //                       padding: const EdgeInsets.only(right: 8.0),
  //                       child: Chip(
  //                         label: Text(
  //                             "${controller.filterMinAge.value}-${controller.filterMaxAge.value} ${TrKeys.years.tr}"),
  //                         deleteIcon: const Icon(Icons.close, size: 18),
  //                         onDeleted: () {
  //                           controller.setAgeRange(0, 18);
  //                         },
  //                         backgroundColor: AppColors.infoLight,
  //                       ),
  //                     ),

  //                   // Chip para mostrar solo apropiados por edad
  //                   if (controller.showOnlyAgeAppropriate.value)
  //                     Padding(
  //                       padding: const EdgeInsets.only(right: 8.0),
  //                       child: Chip(
  //                         label: Text(TrKeys.ageAppropriate.tr),
  //                         deleteIcon: const Icon(Icons.close, size: 18),
  //                         onDeleted: () {
  //                           controller.toggleAgeAppropriate(false);
  //                         },
  //                         backgroundColor: AppColors.successLight,
  //                       ),
  //                     ),

  //                   // Mostrar chip para limpiar todos los filtros si hay alguno activo
  //                   if (controller.filterCategory.value != null ||
  //                       controller.filterFrequency.value != null ||
  //                       controller.filterMinAge.value > 0 ||
  //                       controller.filterMaxAge.value < 18 ||
  //                       controller.showOnlyAgeAppropriate.value)
  //                     ActionChip(
  //                       label: Text(TrKeys.clearAllFilters.tr),
  //                       onPressed: () {
  //                         controller.clearFilters();
  //                       },
  //                       avatar: const Icon(Icons.clear_all, size: 18),
  //                     ),
  //                 ],
  //               )),
  //         ),

  //         const SizedBox(height: 8),

  //         // Contador de resultados y adaptación de edad
  //         Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               // Contador de resultados con indicador de origen
  //               Row(
  //                 children: [
  //                   Obx(() => Text(
  //                         "${controller.filteredChallenges.length} ${controller.filteredChallenges.length == 1 ? TrKeys.challengeFound.tr : TrKeys.challengesFound.tr}",
  //                         style: const TextStyle(
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.grey,
  //                         ),
  //                       )),
  //                   const SizedBox(width: 8),
  //                   // Indicador de origen de datos
  //                   Obx(() {
  //                     Widget icon;
  //                     String tooltip;

  //                     switch (controller.dataSource.value) {
  //                       case 'firestore':
  //                         icon = const Icon(Icons.cloud_done,
  //                             size: 18, color: Colors.green);
  //                         tooltip = TrKeys.cloudDataSource.tr;
  //                         break;
  //                       case 'local':
  //                         icon = const Icon(Icons.smartphone,
  //                             size: 18, color: Colors.orange);
  //                         tooltip = TrKeys.localDataSource.tr;
  //                         break;
  //                       case 'loading':
  //                       default:
  //                         icon = const SizedBox(
  //                           width: 18,
  //                           height: 18,
  //                           child: CircularProgressIndicator(strokeWidth: 2),
  //                         );
  //                         tooltip = TrKeys.loadingDataSource.tr;
  //                     }

  //                     return Tooltip(
  //                       message: tooltip,
  //                       child: icon,
  //                     );
  //                   }),

  //                   // Botón para sincronizar si es necesario
  //                   Obx(() => controller.dataSource.value == 'local'
  //                       ? IconButton(
  //                           icon: const Icon(Icons.sync, size: 18),
  //                           tooltip: TrKeys.syncWithCloud.tr,
  //                           onPressed: () {
  //                             controller.loadPredefinedChallenges();
  //                           },
  //                         )
  //                       : const SizedBox.shrink()),
  //                 ],
  //               ),

  //               // Selector de edad para adaptación
  //               Row(
  //                 children: [
  //                   Text(TrKeys.childAge.tr,
  //                       style: const TextStyle(fontSize: 14)),
  //                   const SizedBox(width: 8),
  //                   Obx(() => DropdownButton<int>(
  //                         value: controller.selectedChildAge.value,
  //                         items: List.generate(
  //                                 16, (index) => index + 3) // De 3 a 18 años
  //                             .map((age) => DropdownMenuItem<int>(
  //                                   value: age,
  //                                   child: Text(age.toString()),
  //                                 ))
  //                             .toList(),
  //                         onChanged: (value) {
  //                           if (value != null) {
  //                             controller.selectedChildAge.value = value;
  //                             controller.applyFilters();
  //                           }
  //                         },
  //                         isDense: true,
  //                       )),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),

  //         const SizedBox(height: 8),

  //         // Lista de retos
  //         Expanded(
  //           child: Obx(() {
  //             if (controller.isLoadingPredefinedChallenges.value) {
  //               return const Center(child: CircularProgressIndicator());
  //             }

  //             if (controller.errorMessage.value.isNotEmpty) {
  //               return Center(
  //                 child: Column(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     const Icon(Icons.error_outline,
  //                         size: 48, color: Colors.red),
  //                     const SizedBox(height: 16),
  //                     Text(
  //                       controller.errorMessage.value,
  //                       textAlign: TextAlign.center,
  //                       style: const TextStyle(color: Colors.red),
  //                     ),
  //                     const SizedBox(height: 16),
  //                     ElevatedButton.icon(
  //                       onPressed: () {
  //                         controller.loadPredefinedChallenges();
  //                       },
  //                       icon: const Icon(Icons.refresh),
  //                       label: Text(TrKeys.retry.tr),
  //                     ),
  //                   ],
  //                 ),
  //               );
  //             }

  //             if (controller.filteredChallenges.isEmpty) {
  //               return Center(
  //                 child: Column(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     const Icon(Icons.search_off,
  //                         size: 48, color: Colors.grey),
  //                     const SizedBox(height: 16),
  //                     Text(
  //                       TrKeys.noChallengesFound.tr,
  //                       textAlign: TextAlign.center,
  //                       style: const TextStyle(
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.bold,
  //                         color: Colors.grey,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 8),
  //                     Text(
  //                       TrKeys.tryChangingFilters.tr,
  //                       textAlign: TextAlign.center,
  //                       style: const TextStyle(color: Colors.grey),
  //                     ),
  //                     const SizedBox(height: 16),
  //                     ElevatedButton.icon(
  //                       onPressed: () {
  //                         controller.clearFilters();
  //                       },
  //                       icon: const Icon(Icons.filter_list_off),
  //                       label: Text(TrKeys.clearAllFilters.tr),
  //                     ),
  //                   ],
  //                 ),
  //               );
  //             }

  //             return ListView.builder(
  //               padding: const EdgeInsets.all(16.0),
  //               itemCount: controller.filteredChallenges.length,
  //               itemBuilder: (context, index) {
  //                 final challenge = controller.filteredChallenges[index];

  //                 // Adaptar puntos según la edad seleccionada
  //                 final adaptedPoints = controller.adaptPointsByAge(
  //                   challenge.points,
  //                   challenge.ageRange['min'] as int,
  //                   challenge.ageRange['max'] as int,
  //                   controller.selectedChildAge.value,
  //                 );

  //                 return ChallengeCard(
  //                   challenge: challenge,
  //                   adaptedPoints: adaptedPoints,
  //                   childAge: controller.selectedChildAge.value,
  //                   isSelected: controller.isChallengeSelected(challenge.id),
  //                   onSelect: () =>
  //                       controller.toggleChallengeSelection(challenge.id),
  //                   onConvert: () =>
  //                       controller.convertTemplateToFamilyChallenge(challenge),
  //                   onTap: () =>
  //                       _showChallengeDetail(context, challenge, adaptedPoints),
  //                 );
  //               },
  //             );
  //           }),
  //         ),
  //       ],
  //     ),

  //     // Botón flotante para acciones con selección
  //     floatingActionButton: Obx(() {
  //       if (controller.selectedChallengeIds.isEmpty) {
  //         return const SizedBox.shrink();
  //       }

  //       return FloatingActionButton.extended(
  //         onPressed: () => _showSelectionOptions(context),
  //         label: Text(
  //             "${controller.selectedChallengeIds.length} ${TrKeys.selected.tr}"),
  //         icon: const Icon(Icons.check_circle),
  //         backgroundColor: AppColors.primary,
  //       );
  //     }),
  //   );
  // }

  // Mostrar opciones para los retos seleccionados
  void _showSelectionOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy, color: AppColors.primary),
              title: Text(TrKeys.importToFamily.tr),
              onTap: () {
                Navigator.pop(context);
                _importSelectedToFamily();
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload, color: AppColors.secondary),
              title: Text(TrKeys.exportSelected.tr),
              onTap: () {
                Navigator.pop(context);
                _exportSelected(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear_all, color: Colors.grey),
              title: Text(TrKeys.clearSelection.tr),
              onTap: () {
                Navigator.pop(context);
                controller.clearSelection();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Importar retos seleccionados a la familia
  void _importSelectedToFamily() {
    // Obtener retos seleccionados
    final selectedChallenges = controller.filteredChallenges
        .where((challenge) =>
            controller.selectedChallengeIds.contains(challenge.id))
        .toList();

    if (selectedChallenges.isEmpty) return;

    // Mostrar diálogo de confirmación
    Get.dialog(
      AlertDialog(
        title: Text(TrKeys.importToFamily.tr),
        content: Text(
          Tr.tp(TrKeys.importSelectedConfirmation,
              {'count': selectedChallenges.length.toString()}),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(TrKeys.cancel.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();

              // Importar cada reto seleccionado
              for (final challenge in selectedChallenges) {
                controller.convertTemplateToFamilyChallenge(challenge);
              }

              // Limpiar selección después de importar
              controller.clearSelection();

              // Mostrar mensaje de éxito
              Get.snackbar(
                TrKeys.importSuccess.tr,
                Tr.tp(TrKeys.challengesImported,
                    {'count': selectedChallenges.length.toString()}),
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green.shade50,
                colorText: Colors.green,
              );
            },
            child: Text(TrKeys.import.tr),
          ),
        ],
      ),
    );
  }

  // Exportar retos seleccionados
  void _exportSelected(BuildContext context) {
    // Obtener retos seleccionados
    final selectedChallenges = controller.filteredChallenges
        .where((challenge) =>
            controller.selectedChallengeIds.contains(challenge.id))
        .toList();

    if (selectedChallenges.isEmpty) return;

    // Exportar retos seleccionados
    controller.exportChallengesToJson(selectedChallenges).then((jsonString) {
      if (jsonString.isNotEmpty) {
        // Aquí se podría implementar la función para compartir o guardar el JSON
        Get.snackbar(
          TrKeys.exportSuccess.tr,
          Tr.tp(TrKeys.challengesExported,
              {'count': selectedChallenges.length.toString()}),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green,
        );

        // Limpiar selección después de exportar
        controller.clearSelection();
      }
    });
  }

  // Seleccionar todos los retos filtrados
  void _selectAll() {
    for (final challenge in controller.filteredChallenges) {
      if (!controller.selectedChallengeIds.contains(challenge.id)) {
        controller.selectedChallengeIds.add(challenge.id);
      }
    }
  }

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

  // Manejar exportación de todos los retos
  void _handleExport(BuildContext context) {
    // Captura el BuildContext actual en una variable local
    final currentContext = context;

    // Mostrar opciones de exportación
    showDialog(
      context: currentContext,
      builder: (dialogContext) => AlertDialog(
        title: Text(TrKeys.exportChallenges.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.filter_list),
              title: Text(TrKeys.exportFiltered.tr),
              subtitle: Text(
                Tr.tp(TrKeys.numberOfChallenges,
                    {'count': controller.filteredChallenges.length.toString()}),
              ),
              onTap: () {
                Navigator.pop(dialogContext);

                // Guarda una referencia local a los retos filtrados
                final challengesToExport =
                    List<Challenge>.from(controller.filteredChallenges);

                controller
                    .exportChallengesToJson(challengesToExport)
                    .then((jsonString) {
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
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: Text(TrKeys.exportAll.tr),
              subtitle: Text(
                Tr.tp(TrKeys.numberOfChallenges, {
                  'count': controller.predefinedChallenges.length.toString()
                }),
              ),
              onTap: () {
                Navigator.pop(dialogContext);

                // Guarda una referencia local a todos los retos
                final challengesToExport =
                    List<Challenge>.from(controller.predefinedChallenges);

                controller
                    .exportChallengesToJson(challengesToExport)
                    .then((jsonString) {
                  // Usar Get.context que es actualizado dinámicamente por GetX
                  if (jsonString.isNotEmpty && Get.context != null) {
                    _showExportResult(Get.context!, jsonString);
                  } else if (jsonString.isNotEmpty) {
                    // Fallback: mostrar un snackbar que no requiere contexto
                    Get.snackbar(
                      TrKeys.exportSuccess.tr,
                      TrKeys.jsonCopied.tr,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green.shade50,
                      colorText: Colors.green,
                    );
                  }
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(TrKeys.cancel.tr),
          ),
        ],
      ),
    );
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

  // Mostrar detalle de un reto
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
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getCategoryIcon(challenge.category),
                    color: AppColors.primary,
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
                          const SizedBox(width: 8),
                          _buildFrequencyChip(challenge.frequency),
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

            const SizedBox(height: 32),

            // Botones de acción
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.add_circle_outline),
                        label: Text(TrKeys.addToFamily.tr),
                        onPressed: () {
                          Navigator.pop(context);
                          controller
                              .convertTemplateToFamilyChallenge(challenge);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Obx(() => Icon(
                            controller.isChallengeSelected(challenge.id)
                                ? Icons.check_box
                                : Icons.check_box_outline_blank)),
                        label: Obx(() => Text(
                            controller.isChallengeSelected(challenge.id)
                                ? TrKeys.selected.tr
                                : TrKeys.select.tr)),
                        onPressed: () {
                          controller.toggleChallengeSelection(challenge.id);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Nueva fila con botones para editar y asignar
                Row(
                  children: [
                    // Botón para editar (solo si no es template o si es un reto de la familia)
                    if (!challenge.isTemplate || challenge.familyId != null)
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

                    // Espacio entre botones si ambos están visibles
                    if (!challenge.isTemplate || challenge.familyId != null)
                      const SizedBox(width: 16),

                    // Botón para asignar (solo si es un reto de la familia)
                    if (challenge.familyId != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.assignment_ind),
                          label: Text(TrKeys.assignToChild.tr),
                          onPressed: () {
                            Navigator.pop(context);
                            // Seleccionar este reto en el controlador
                            controller.selectedChallenge.value = challenge;
                            // Navegar a la página de asignación
                            Get.toNamed(Routes.assignChallenge);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: AppColors.secondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
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
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getCategoryName(category),
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.primary,
        ),
      ),
    );
  }

  // Construir chip de frecuencia
  Widget _buildFrequencyChip(ChallengeFrequency frequency) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getFrequencyName(frequency),
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.secondary,
        ),
      ),
    );
  }

  // Obtener nombre de categoría
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

  // Obtener nombre de frecuencia
  String _getFrequencyName(ChallengeFrequency frequency) {
    switch (frequency) {
      case ChallengeFrequency.daily:
        return TrKeys.frequencyDaily.tr;
      case ChallengeFrequency.weekly:
        return TrKeys.frequencyWeekly.tr;
      case ChallengeFrequency.monthly:
        return TrKeys.frequencyMonthly.tr;
      case ChallengeFrequency.quarterly:
        return TrKeys.frequencyQuarterly.tr;
      case ChallengeFrequency.once:
        return TrKeys.frequencyOnce.tr;
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
}
