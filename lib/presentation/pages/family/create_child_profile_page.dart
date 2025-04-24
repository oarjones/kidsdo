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
    final hasNewImage = controller.imageFile.value != null;

    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Avatar actual o nuevo
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(30),
              shape: BoxShape.circle,
              image: hasNewImage
                  ? DecorationImage(
                      image: FileImage(controller.imageFile.value!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: !hasNewImage
                ? const Icon(
                    Icons.person,
                    size: 60,
                    color: AppColors.primary,
                  )
                : null,
          ),

          // Botón para cambiar avatar
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: hasNewImage
                ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: controller.clearSelectedImage,
                  )
                : IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    onPressed: () => _showImageSourceDialog(context),
                  ),
          ),

          // Indicador de progreso si está subiendo
          if (controller.isUploading.value)
            Positioned.fill(
              child: CircularProgressIndicator(
                value: controller.uploadProgress.value,
                strokeWidth: 3,
                backgroundColor: Colors.white.withAlpha(127),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
        ],
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
    final selectedColor =
        controller.childSettings['color'] as String? ?? 'blue';

    // Definir colores disponibles
    final colors = {
      'blue': AppColors.childBlue,
      'purple': AppColors.childPurple,
      'green': AppColors.childGreen,
      'orange': AppColors.childOrange,
      'pink': AppColors.childPink,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'child_profile_theme'.tr,
          style: const TextStyle(
            fontSize: AppDimensions.fontSm,
            color: AppColors.textMedium,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: colors.entries.map((entry) {
            final isSelected = selectedColor == entry.key;
            return InkWell(
              onTap: () => controller.updateSetting('color', entry.key),
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadiusCircular),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: entry.value, width: 2)
                      : null,
                ),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: entry.value,
                    shape: BoxShape.circle,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: AppDimensions.iconSm,
                        )
                      : null,
                ),
              ),
            );
          }).toList(),
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
