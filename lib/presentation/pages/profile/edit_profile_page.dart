import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/core/utils/form_validators.dart';
import 'package:kidsdo/presentation/controllers/profile_controller.dart';
import 'package:kidsdo/presentation/widgets/auth/auth_button.dart';
import 'package:kidsdo/presentation/widgets/auth/auth_message.dart';
import 'package:kidsdo/presentation/widgets/auth/auth_text_field.dart';
import 'package:kidsdo/presentation/widgets/common/cached_avatar.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ProfileController controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TrKeys.editProfile.tr),
      ),
      // Añadido SafeArea aquí
      body: SafeArea(
        child: Obx(
          () {
            if (controller.status.value == ProfileStatus.loading &&
                controller.profile.value == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar con opciones para cambiar
                    _buildAvatarPicker(),

                    const SizedBox(height: AppDimensions.xl),

                    // Nombre
                    AuthTextField(
                      controller: controller.nameController,
                      hintText: TrKeys.name.tr,
                      prefixIcon: Icons.person_outline,
                      textCapitalization: TextCapitalization.words,
                      validator: FormValidators.name,
                      enabled: controller.status.value != ProfileStatus.loading,
                    ),

                    const SizedBox(height: AppDimensions.md),

                    // Email (no editable, solo informativo)
                    AbsorbPointer(
                      child: AuthTextField(
                        controller: TextEditingController(
                          text: controller.profile.value?.email ?? '',
                        ),
                        hintText: TrKeys.email.tr,
                        prefixIcon: Icons.email_outlined,
                        enabled: false,
                      ),
                    ),

                    // Mensaje de error
                    if (controller.errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: AppDimensions.lg,
                          bottom: AppDimensions.sm,
                        ),
                        child: AuthMessage(
                          message: controller.errorMessage.value,
                          type: MessageType.error,
                          onDismiss: () => controller.errorMessage.value = '',
                        ),
                      ),

                    const SizedBox(height: AppDimensions.xl),

                    // Botón de guardar
                    AuthButton(
                      text: TrKeys.save.tr,
                      onPressed: controller.status.value !=
                              ProfileStatus.loading
                          ? () {
                              if (_formKey.currentState?.validate() ?? false) {
                                controller.updateProfile();
                              }
                            }
                          : null,
                      isLoading:
                          controller.status.value == ProfileStatus.loading,
                      type: AuthButtonType.primary,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text(TrKeys.editProfile.tr),
  //     ),
  //     body: Obx(
  //       () {
  //         if (controller.status.value == ProfileStatus.loading &&
  //             controller.profile.value == null) {
  //           return const Center(child: CircularProgressIndicator());
  //         }

  //         return SingleChildScrollView(
  //           padding: const EdgeInsets.all(AppDimensions.lg),
  //           child: Form(
  //             key: _formKey,
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 // Avatar con opciones para cambiar
  //                 _buildAvatarPicker(),

  //                 const SizedBox(height: AppDimensions.xl),

  //                 // Nombre
  //                 AuthTextField(
  //                   controller: controller.nameController,
  //                   hintText: TrKeys.name.tr,
  //                   prefixIcon: Icons.person_outline,
  //                   textCapitalization: TextCapitalization.words,
  //                   validator: FormValidators.name,
  //                   enabled: controller.status.value != ProfileStatus.loading,
  //                 ),

  //                 const SizedBox(height: AppDimensions.md),

  //                 // Email (no editable, solo informativo)
  //                 AbsorbPointer(
  //                   child: AuthTextField(
  //                     controller: TextEditingController(
  //                       text: controller.profile.value?.email ?? '',
  //                     ),
  //                     hintText: TrKeys.email.tr,
  //                     prefixIcon: Icons.email_outlined,
  //                     enabled: false,
  //                   ),
  //                 ),

  //                 // Mensaje de error
  //                 if (controller.errorMessage.isNotEmpty)
  //                   Padding(
  //                     padding: const EdgeInsets.only(
  //                       top: AppDimensions.lg,
  //                       bottom: AppDimensions.sm,
  //                     ),
  //                     child: AuthMessage(
  //                       message: controller.errorMessage.value,
  //                       type: MessageType.error,
  //                       onDismiss: () => controller.errorMessage.value = '',
  //                     ),
  //                   ),

  //                 const SizedBox(height: AppDimensions.xl),

  //                 // Botón de guardar
  //                 AuthButton(
  //                   text: TrKeys.save.tr,
  //                   onPressed: controller.status.value != ProfileStatus.loading
  //                       ? () {
  //                           if (_formKey.currentState?.validate() ?? false) {
  //                             controller.updateProfile();
  //                           }
  //                         }
  //                       : null,
  //                   isLoading: controller.status.value == ProfileStatus.loading,
  //                   type: AuthButtonType.primary,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget _buildAvatarPicker() {
    final profile = controller.profile.value;
    final hasNewImage = controller.imageFile.value != null;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Avatar actual o nuevo
        hasNewImage
            ? CircleAvatar(
                radius: 60,
                backgroundImage: FileImage(controller.imageFile.value!),
              )
            : CachedAvatar(
                url: profile?.avatarUrl,
                radius: 60,
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
              backgroundColor: Colors.white.withValues(alpha: 0.5),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
      ],
    );
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
}
