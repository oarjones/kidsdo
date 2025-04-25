import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/presentation/controllers/child_profile_controller.dart';
import 'package:kidsdo/presentation/widgets/auth/auth_button.dart';
import 'package:kidsdo/presentation/widgets/auth/auth_message.dart';
import 'package:kidsdo/presentation/widgets/auth/auth_text_field.dart';
import 'package:kidsdo/presentation/widgets/child/avatar_picker.dart';
import 'package:kidsdo/presentation/widgets/child/theme_preview.dart';
import 'package:kidsdo/presentation/widgets/child/theme_selector.dart';

class CreateChildProfilePage extends StatefulWidget {
  const CreateChildProfilePage({Key? key}) : super(key: key);

  @override
  State<CreateChildProfilePage> createState() => _CreateChildProfilePageState();
}

class _CreateChildProfilePageState extends State<CreateChildProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ChildProfileController controller = Get.find<ChildProfileController>();

  @override
  void initState() {
    super.initState();
    // Preparar el formulario para un nuevo perfil
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.prepareForNewChild();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TrKeys.createChildProfile.tr),
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Imagen del perfil
                _buildAvatarPicker(),
                const SizedBox(height: AppDimensions.xl),

                // Nombre del niño
                AuthTextField(
                  controller: controller.nameController,
                  hintText: TrKeys.childName.tr,
                  prefixIcon: Icons.person_outline,
                  textCapitalization: TextCapitalization.words,
                  validator: _validateName,
                  enabled:
                      controller.status.value != ChildProfileStatus.loading,
                  autoValidate: true,
                ),
                const SizedBox(height: AppDimensions.lg),

                // Fecha de nacimiento
                _buildBirthDatePicker(),
                const SizedBox(height: AppDimensions.lg),

                // Configuración de tema/colores
                _buildThemeSelector(),
                const SizedBox(height: AppDimensions.lg),

                // Mensaje de error si existe
                if (controller.errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.md),
                    child: AuthMessage(
                      message: controller.errorMessage.value,
                      type: MessageType.error,
                      onDismiss: () => controller.errorMessage.value = '',
                    ),
                  ),

                const SizedBox(height: AppDimensions.lg),

                // Botón para crear perfil
                AuthButton(
                  text: TrKeys.createChildProfile.tr,
                  onPressed:
                      controller.status.value != ChildProfileStatus.loading
                          ? _submitForm
                          : null,
                  isLoading:
                      controller.status.value == ChildProfileStatus.loading,
                  type: AuthButtonType.primary,
                ),

                const SizedBox(height: AppDimensions.md),

                // Botón para cancelar
                AuthButton(
                  text: TrKeys.cancel.tr,
                  onPressed:
                      controller.status.value != ChildProfileStatus.loading
                          ? () => Get.back()
                          : null,
                  type: AuthButtonType.secondary,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAvatarPicker() {
    return Center(
      child: AvatarPicker(
        selectedImage: controller.imageFile.value,
        selectedPredefinedAvatar:
            controller.childSettings['predefinedAvatar'] as String?,
        onPredefinedAvatarSelected: controller.selectPredefinedAvatar,
        onPickImage: () => _showImageSourceDialog(context),
        onClearImage: controller.clearSelectedImage,
        isUploading: controller.isUploading.value,
        uploadProgress: controller.uploadProgress.value,
      ),
    );
  }

  Widget _buildBirthDatePicker() {
    final dateFormat = DateFormat.yMMMMd();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TrKeys.birthDate.tr,
          style: const TextStyle(
            fontSize: AppDimensions.fontSm,
            color: AppColors.textMedium,
          ),
        ),
        const SizedBox(height: AppDimensions.xs),
        InkWell(
          onTap: controller.status.value != ChildProfileStatus.loading
              ? () => _selectDate(context)
              : null,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.md,
              vertical: AppDimensions.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.textMedium,
                  size: AppDimensions.iconSm,
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Text(
                    dateFormat.format(controller.birthDate.value),
                    style: const TextStyle(
                      fontSize: AppDimensions.fontMd,
                    ),
                  ),
                ),
                Text(
                  '${'age'.tr}: ${controller.birthDate.value.difference(DateTime.now()).inDays ~/ -365}',
                  style: const TextStyle(
                    fontSize: AppDimensions.fontSm,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selector de tema avanzado
        ThemeSelector(
          currentSettings: controller.childSettings,
          onSettingUpdated: controller.updateSetting,
        ),

        const SizedBox(height: AppDimensions.xl),

        // Vista previa del tema
        ThemePreview(
          childName: controller.nameController.text.isNotEmpty
              ? controller.nameController.text
              : 'child_name_preview'.tr,
          childAge:
              controller.birthDate.value.difference(DateTime.now()).inDays ~/
                  -365,
          settings: controller.childSettings,
          avatarUrl: null,
          predefinedAvatar:
              controller.childSettings['predefinedAvatar'] as String?,
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    // No permitir seleccionar fecha futura o de hace más de 18 años
    final now = DateTime.now();
    final minDate = DateTime(now.year - 18, now.month, now.day);
    final maxDate = now;
    final initialDate = controller.birthDate.value;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(maxDate) || initialDate.isBefore(minDate)
          ? DateTime(
              now.year - 5, now.month, now.day) // Fecha predeterminada: 5 años
          : initialDate,
      firstDate: minDate,
      lastDate: maxDate,
      helpText: TrKeys.birthDate.tr,
      cancelText: TrKeys.cancel.tr,
      confirmText: TrKeys.ok.tr,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      controller.changeBirthDate(pickedDate);
    }
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(TrKeys.selectImageSource.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(TrKeys.gallery.tr),
                onTap: () {
                  Navigator.of(context).pop();
                  controller.pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(TrKeys.camera.tr),
                onTap: () {
                  Navigator.of(context).pop();
                  controller.takePicture();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(TrKeys.cancel.tr),
            ),
          ],
        );
      },
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return TrKeys.requiredField.tr;
    }
    if (value.length < 2) {
      return TrKeys.nameTooShort.tr;
    }
    return null;
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      controller.createChildProfile();
    }
  }
}
