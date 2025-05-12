// lib/presentation/pages/rewards/create_edit_reward_page.dart

import 'package:kidsdo/presentation/widgets/rewards/reward_icon_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/core/utils/form_validators.dart';
import 'package:kidsdo/domain/entities/reward.dart';
import 'package:kidsdo/presentation/controllers/rewards_controller.dart';

class CreateEditRewardPage extends StatefulWidget {
  final bool isEditing;
  final Reward? rewardForEditing; // Recompensa a editar (si isEditing es true)
  final Reward?
      rewardAsTemplate; // Recompensa plantilla para pre-rellenar (si isEditing es false)

  const CreateEditRewardPage({
    super.key,
    required this.isEditing,
    this.rewardForEditing,
    this.rewardAsTemplate,
  }) : assert(isEditing ? rewardForEditing != null : true,
            'rewardForEditing must be provided if isEditing is true');

  @override
  State<CreateEditRewardPage> createState() => _CreateEditRewardPageState();
}

class _CreateEditRewardPageState extends State<CreateEditRewardPage> {
  final RewardsController controller = Get.find<RewardsController>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _pointsController;

  late Rx<RewardType> _selectedRewardType;
  late RxString _selectedIconName;
  late RxBool _isUnique;
  late RxBool _isEnabled;

  @override
  void initState() {
    super.initState();

    // Determinar los datos iniciales para el formulario
    // Si estamos editando, usamos rewardForEditing.
    // Si estamos creando desde una plantilla, usamos rewardAsTemplate.
    // Si no, es una creación nueva con campos vacíos.
    final Reward? initialData =
        widget.isEditing ? widget.rewardForEditing : widget.rewardAsTemplate;

    _nameController = TextEditingController(text: initialData?.name ?? '');
    _descriptionController =
        TextEditingController(text: initialData?.description ?? '');
    _pointsController = TextEditingController(
        text: initialData?.pointsRequired.toString() ?? '');

    _selectedRewardType = (initialData?.type ?? RewardType.simple).obs;
    _selectedIconName = (initialData?.icon ?? 'default_reward_icon').obs;
    _isUnique = (initialData?.isUnique ?? false).obs;
    _isEnabled = (initialData?.isEnabled ?? true).obs;

    controller.clearActionStatus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
          top: AppDimensions.lg, bottom: AppDimensions.sm),
      child: Text(
        title,
        style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    bool isOptional = false,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: '$label ${isOptional ? "(${Tr.t(TrKeys.optional)})" : ""}',
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      validator: validator ?? (isOptional ? null : FormValidators.required),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final points = int.tryParse(_pointsController.text) ?? 0;

      if (widget.isEditing) {
        // No necesitamos rewardBeingEdited aquí, usamos widget.rewardForEditing
        final updatedReward = widget.rewardForEditing!.copyWith(
          // Usamos ! porque assert lo garantiza
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          pointsRequired: points,
          type: _selectedRewardType.value,
          icon: _selectedIconName.value,
          isUnique: _isUnique.value,
          isEnabled: _isEnabled.value,
        );
        await controller.updateReward(updatedReward);
      } else {
        // Crear nueva recompensa (puede estar pre-rellenada por rewardAsTemplate o ser nueva)
        await controller.createReward(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          pointsRequired: points,
          type: _selectedRewardType.value,
          icon: _selectedIconName.value,
          isUnique: _isUnique.value,
          isEnabled: _isEnabled.value,
          // typeSpecificData se manejará más adelante
        );
      }
    } else {
      Get.snackbar(
        Tr.t(TrKeys.formErrorTitle),
        Tr.t(TrKeys.formErrorMessage),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    }
  }

  void _confirmDeleteReward() {
    // Solo se puede borrar si estamos editando y rewardForEditing existe
    if (widget.isEditing && widget.rewardForEditing != null) {
      Get.dialog(
        AlertDialog(
          title: Text(Tr.t(TrKeys.confirmDeleteRewardTitle)),
          content: Text(Tr.tp(TrKeys.confirmDeleteRewardMessage,
              {'rewardName': widget.rewardForEditing!.name})),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(Tr.t(TrKeys.cancel)),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                // Usamos el ID de widget.rewardForEditing!
                await controller.deleteReward(widget.rewardForEditing!.id);
                if (controller.rewardActionStatus.value ==
                    RewardOperationStatus.success) {
                  Get.back();
                }
              },
              style: TextButton.styleFrom(
                  foregroundColor: Theme.of(Get.context!).colorScheme.error),
              child: Text(Tr.t(TrKeys.delete)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String appBarTitle = widget.isEditing
        ? Tr.t(TrKeys.editRewardTitle)
        : Tr.t(TrKeys.createRewardTitle);

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          if (widget.isEditing && widget.rewardForEditing != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: Tr.t(TrKeys.deleteReward),
              onPressed: _confirmDeleteReward,
            ),
        ],
      ),
      body: Obx(() {
        if (controller.rewardActionStatus.value ==
            RewardOperationStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppDimensions.md, AppDimensions.md,
              AppDimensions.md, AppDimensions.xxl * 2),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (controller.rewardActionStatus.value ==
                        RewardOperationStatus.error &&
                    controller.rewardActionError.value.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.md),
                    child: Text(
                      controller.rewardActionError.value,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                _buildSectionTitle(Tr.t(TrKeys.rewardBasicInfo)),
                _buildTextField(
                  controller: _nameController,
                  label: Tr.t(TrKeys.rewardNameLabel),
                  hint: Tr.t(TrKeys.rewardNameHint),
                ),
                const SizedBox(height: AppDimensions.md),
                _buildTextField(
                  controller: _descriptionController,
                  label: Tr.t(TrKeys.rewardDescriptionLabel),
                  hint: Tr.t(TrKeys.rewardDescriptionHint),
                  isOptional: true,
                  maxLines: 3,
                ),
                const SizedBox(height: AppDimensions.md),
                _buildTextField(
                  controller: _pointsController,
                  label: Tr.t(TrKeys.rewardPointsRequiredLabel),
                  hint: "100",
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    final requiredError = FormValidators.required(value);
                    if (requiredError != null) {
                      return requiredError;
                    }
                    if (int.tryParse(value!) == null || int.parse(value) <= 0) {
                      return Tr.t(TrKeys.pointsPositiveError);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.lg),
                _buildSectionTitle(Tr.t(TrKeys.rewardDetails)),
                Obx(() => DropdownButtonFormField<RewardType>(
                      value: _selectedRewardType.value,
                      decoration: InputDecoration(
                        labelText: Tr.t(TrKeys.rewardTypeLabel),
                      ),
                      items: RewardType.values.map((RewardType type) {
                        return DropdownMenuItem<RewardType>(
                          value: type,
                          child: Text(Tr.t('reward_type_${type.name}')),
                        );
                      }).toList(),
                      onChanged: (RewardType? newValue) {
                        if (newValue != null) {
                          _selectedRewardType.value = newValue;
                        }
                      },
                      validator: (value) => value == null
                          ? Tr.t(TrKeys.fieldRequiredError)
                          : null,
                    )),
                const SizedBox(height: AppDimensions.md),
                _buildSectionTitle(Tr.t(TrKeys.rewardIconLabel)),
                Obx(() {
                  final selectedOption = availableRewardIcons.firstWhere(
                    (opt) => opt.name == _selectedIconName.value,
                    orElse: () => const RewardIconOption(
                        name: 'default_reward_icon',
                        iconData: Icons.star_outline),
                  );

                  return ListTile(
                    leading: Icon(
                      selectedOption.iconData,
                      size: 32,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      _selectedIconName.value == 'default_reward_icon'
                          ? Tr.t(TrKeys.selectIcon)
                          : (_selectedIconName.value
                                  .replaceAll('_', ' ')
                                  .capitalizeFirst ??
                              _selectedIconName.value),
                    ),
                    subtitle: Text(Tr.t(TrKeys.tapToChangeIcon)),
                    onTap: () async {
                      await Get.dialog<void>(
                        RewardIconSelectorDialog(
                          currentlySelectedIconName: _selectedIconName.value,
                          onSelectIcon: (selectedName) {
                            _selectedIconName.value = selectedName;
                          },
                        ),
                      );
                    },
                    trailing: const Icon(Icons.chevron_right),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Theme.of(context).dividerColor),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.borderRadiusMd),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.sm,
                        vertical: AppDimensions.xs),
                  );
                }),
                const SizedBox(height: AppDimensions.lg),
                _buildSectionTitle(Tr.t(TrKeys.rewardOptions)),
                Obx(() => SwitchListTile(
                      title: Text(Tr.t(TrKeys.rewardIsEnabledLabel)),
                      subtitle: Text(Tr.t(TrKeys.rewardIsEnabledHint)),
                      value: _isEnabled.value,
                      onChanged: (bool value) => _isEnabled.value = value,
                      activeColor: AppColors.success,
                      contentPadding: EdgeInsets.zero,
                    )),
                Obx(() => SwitchListTile(
                      title: Text(Tr.t(TrKeys.rewardIsUniqueLabel)),
                      subtitle: Text(Tr.t(TrKeys.rewardIsUniqueHint)),
                      value: _isUnique.value,
                      onChanged: (bool value) => _isUnique.value = value,
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                    )),
                const SizedBox(height: AppDimensions.xl),
                ElevatedButton.icon(
                  icon: Icon(widget.isEditing
                      ? Icons.save_outlined
                      : Icons.add_circle_outline),
                  label: Text(widget.isEditing
                      ? Tr.t(TrKeys.saveChanges)
                      : Tr.t(TrKeys.createRewardButton)),
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppDimensions.md),
                    textStyle: Get.textTheme.labelLarge
                        ?.copyWith(fontSize: AppDimensions.fontMd),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
