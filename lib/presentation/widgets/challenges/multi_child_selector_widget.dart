import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/presentation/controllers/child_profile_controller.dart';
import 'package:kidsdo/presentation/widgets/common/cached_avatar.dart';

class MultiChildSelectorWidget extends StatelessWidget {
  final List<String> selectedChildIds;
  final Function(String) onChildToggle;
  final bool showSelectAll;

  const MultiChildSelectorWidget({
    Key? key,
    required this.selectedChildIds,
    required this.onChildToggle,
    this.showSelectAll = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ChildProfileController childProfileController =
        Get.find<ChildProfileController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        Text(
          TrKeys.assignToChild.tr,
          style: const TextStyle(
            fontSize: AppDimensions.fontLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),

        Obx(() {
          if (childProfileController.isLoadingProfiles.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (childProfileController.childProfiles.isEmpty) {
            return _buildNoChildrenMessage();
          }

          return Column(
            children: [
              // Selector "Seleccionar todos"
              if (showSelectAll &&
                  childProfileController.childProfiles.length > 1)
                ListTile(
                  leading: Checkbox(
                    value: selectedChildIds.length ==
                        childProfileController.childProfiles.length,
                    onChanged: (_) {
                      if (selectedChildIds.length ==
                          childProfileController.childProfiles.length) {
                        // Deseleccionar todos
                        for (final child
                            in childProfileController.childProfiles) {
                          if (selectedChildIds.contains(child.id)) {
                            onChildToggle(child.id);
                          }
                        }
                      } else {
                        // Seleccionar todos
                        for (final child
                            in childProfileController.childProfiles) {
                          if (!selectedChildIds.contains(child.id)) {
                            onChildToggle(child.id);
                          }
                        }
                      }
                    },
                    activeColor: AppColors.primary,
                  ),
                  title: Text(
                    selectedChildIds.length ==
                            childProfileController.childProfiles.length
                        ? TrKeys.clearSelection.tr
                        : TrKeys.selectAll.tr,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

              // Lista de niños con checkboxes
              Container(
                padding: const EdgeInsets.all(AppDimensions.sm),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withValues(alpha: 150)),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusMd),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: childProfileController.childProfiles.length,
                  itemBuilder: (context, index) {
                    final child = childProfileController.childProfiles[index];
                    final isSelected = selectedChildIds.contains(child.id);

                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (_) => onChildToggle(child.id),
                      activeColor: AppColors.primary,
                      title: Text(child.name),
                      subtitle: Text('${child.age} ${TrKeys.yearsOld.tr}'),
                      secondary: child.avatarUrl != null
                          ? CachedAvatar(url: child.avatarUrl, radius: 20)
                          : CircleAvatar(
                              radius: 20,
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 50),
                              child: const Icon(Icons.person,
                                  color: AppColors.primary),
                            ),
                      dense: true,
                    );
                  },
                ),
              ),
            ],
          );
        }),

        // Chips para mostrar los niños seleccionados
        if (selectedChildIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppDimensions.md),
            child: Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: selectedChildIds.map((childId) {
                    final child = childProfileController.childProfiles
                        .firstWhereOrNull((child) => child.id == childId);
                    if (child == null) return const SizedBox.shrink();

                    return Chip(
                      label: Text(child.name),
                      avatar: child.avatarUrl != null
                          ? CachedAvatar(url: child.avatarUrl, radius: 12)
                          : const CircleAvatar(
                              radius: 12,
                              child: Icon(Icons.person, size: 12),
                            ),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => onChildToggle(childId),
                      backgroundColor: AppColors.primaryLight,
                    );
                  }).toList(),
                )),
          ),
      ],
    );
  }

  Widget _buildNoChildrenMessage() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 50),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.amber,
            size: 48,
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            TrKeys.noChildrenAvailable.tr,
            style: const TextStyle(
              fontSize: AppDimensions.fontLg,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            TrKeys.noChildrenAvailableMessage.tr,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.md),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              Get.toNamed('/create-child');
            },
            icon: const Icon(Icons.add),
            label: Text(TrKeys.createChildProfileFirst.tr),
          ),
        ],
      ),
    );
  }
}
