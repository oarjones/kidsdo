import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/family_child.dart';
import 'package:kidsdo/domain/repositories/family_child_repository.dart';
import 'package:kidsdo/presentation/controllers/family_controller.dart';
import 'package:kidsdo/presentation/controllers/session_controller.dart';
import 'package:logger/logger.dart';

enum ChildProfileStatus {
  initial,
  loading,
  success,
  error,
}

class ChildProfileController extends GetxController {
  final IFamilyChildRepository _familyChildRepository;
  final SessionController _sessionController;
  final FamilyController _familyController;
  final FirebaseStorage _storage;
  final ImagePicker _imagePicker;
  final Logger _logger;

  // Estado observable general
  final Rx<ChildProfileStatus> status =
      Rx<ChildProfileStatus>(ChildProfileStatus.initial);
  final RxString errorMessage = RxString('');

  // Datos de los perfiles infantiles
  final RxList<FamilyChild> childProfiles = RxList<FamilyChild>([]);
  final Rx<FamilyChild?> selectedChild = Rx<FamilyChild?>(null);
  final RxBool isLoadingProfiles = RxBool(false);

  // Archivos e imágenes para la creación/edición
  final Rx<File?> imageFile = Rx<File?>(null);
  final RxBool isUploading = RxBool(false);
  final RxDouble uploadProgress = RxDouble(0.0);

  // Controladores para formulario de creación/edición
  late TextEditingController nameController;
  late TextEditingController pointsController;
  late TextEditingController levelController;

  // Datos para formulario
  final Rx<DateTime> birthDate = Rx<DateTime>(DateTime.now().subtract(
      const Duration(days: 365 * 5))); // 5 años como edad predeterminada
  final RxMap<String, dynamic> childSettings = RxMap<String, dynamic>({
    'theme': 'default',
    'avatar': 'default',
    'color': 'blue',
    'interfaceSize': 'medium',
  });

  ChildProfileController({
    required IFamilyChildRepository familyChildRepository,
    required SessionController sessionController,
    required FamilyController familyController,
    required FirebaseStorage storage,
    required ImagePicker imagePicker,
    required Logger logger,
  })  : _familyChildRepository = familyChildRepository,
        _sessionController = sessionController,
        _familyController = familyController,
        _storage = storage,
        _imagePicker = imagePicker,
        _logger = logger;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    pointsController = TextEditingController(text: '0');
    levelController = TextEditingController(text: '1');

    // Escuchar cambios en la familia seleccionada
    ever(_familyController.currentFamily, (_) {
      if (_familyController.currentFamily.value != null) {
        loadChildProfiles();
      } else {
        childProfiles.clear();
        selectedChild.value = null;
      }
    });

    // Cargar inicialmente si hay una familia seleccionada
    if (_familyController.currentFamily.value != null) {
      loadChildProfiles();
    }

    _logger.i("ChildProfileController initialized");
  }

  @override
  void onClose() {
    nameController.dispose();
    pointsController.dispose();
    levelController.dispose();
    super.onClose();
  }

  /// Carga todos los perfiles infantiles de la familia actual
  Future<void> loadChildProfiles() async {
    final currentFamily = _familyController.currentFamily.value;
    if (currentFamily == null) {
      _logger.w(
          "No hay familia seleccionada, no se pueden cargar perfiles infantiles");
      return;
    }

    isLoadingProfiles.value = true;
    childProfiles.clear();
    errorMessage.value = '';

    _logger
        .i("Cargando perfiles infantiles para la familia: ${currentFamily.id}");
    final result =
        await _familyChildRepository.getChildrenByFamilyId(currentFamily.id);

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        _logger.e("Error cargando perfiles infantiles: ${failure.message}");
      },
      (children) {
        childProfiles.addAll(children);
        _logger.i("Se cargaron ${children.length} perfiles infantiles");
      },
    );

    isLoadingProfiles.value = false;
  }

  /// Selecciona un perfil infantil
  void selectChild(FamilyChild child) {
    selectedChild.value = child;
    _logger.d("Perfil infantil seleccionado: ${child.name}");
  }

  /// Limpia la selección actual
  void clearSelection() {
    selectedChild.value = null;
    _logger.d("Selección de perfil infantil limpiada");
  }

  /// Prepara el formulario para crear un nuevo perfil infantil
  void prepareForNewChild() {
    nameController.clear();
    pointsController.text = '0';
    levelController.text = '1';
    birthDate.value = DateTime.now().subtract(
        const Duration(days: 365 * 5)); // 5 años como edad predeterminada
    imageFile.value = null;
    childSettings.value = {
      'theme': 'default',
      'avatar': 'default',
      'color': 'blue',
      'interfaceSize': 'medium',
    };
    _logger.d("Formulario preparado para nuevo perfil infantil");
  }

  /// Prepara el formulario para editar un perfil infantil existente
  void prepareForEditChild(FamilyChild child) {
    nameController.text = child.name;
    pointsController.text = child.points.toString();
    levelController.text = child.level.toString();
    birthDate.value = child.birthDate;
    imageFile.value = null;

    // Copiar configuraciones del perfil
    childSettings.value = Map<String, dynamic>.from(child.settings);

    // Asegurarse de que tenga configuraciones por defecto si faltan
    if (!childSettings.containsKey('theme')) {
      childSettings['theme'] = 'default';
    }
    if (!childSettings.containsKey('color')) {
      childSettings['color'] = 'blue';
    }
    if (!childSettings.containsKey('interfaceSize')) {
      childSettings['interfaceSize'] = 'medium';
    }

    _logger.d("Formulario preparado para editar el perfil: ${child.name}");
  }

  /// Cambia la fecha de nacimiento
  void changeBirthDate(DateTime date) {
    birthDate.value = date;
  }

  /// Actualiza una configuración específica
  void updateSetting(String key, dynamic value) {
    childSettings[key] = value;
  }

  /// Selecciona una imagen de la galería
  Future<void> pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        imageFile.value = File(pickedFile.path);
        // Si se selecciona una imagen personalizada, limpiar el avatar predefinido
        if (childSettings.containsKey('predefinedAvatar')) {
          childSettings.remove('predefinedAvatar');
        }
        _logger.d("Imagen seleccionada de la galería");
      }
    } catch (e, stackTrace) {
      _logger.e('Error seleccionando imagen: $e',
          error: e, stackTrace: stackTrace);
      errorMessage.value = TrKeys.errorSelectingImage.tr;
    }
  }

  /// Toma una foto con la cámara
  Future<void> takePicture() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        imageFile.value = File(pickedFile.path);
        // Si se selecciona una imagen personalizada, limpiar el avatar predefinido
        if (childSettings.containsKey('predefinedAvatar')) {
          childSettings.remove('predefinedAvatar');
        }
        _logger.d("Imagen capturada con la cámara");
      }
    } catch (e, stackTrace) {
      _logger.e('Error capturando imagen: $e',
          error: e, stackTrace: stackTrace);
      errorMessage.value = TrKeys.errorCapturingImage.tr;
    }
  }

  /// Limpia la imagen seleccionada
  void clearSelectedImage() {
    imageFile.value = null;
    if (childSettings.containsKey('predefinedAvatar')) {
      childSettings.remove('predefinedAvatar');
    }
    _logger.d("Imagen y avatar predefinido limpiados");
  }

  /// Selecciona un avatar predefinido
  void selectPredefinedAvatar(String avatarKey) {
    // Limpiar imagen seleccionada si existe
    imageFile.value = null;
    // Establecer avatar predefinido
    childSettings['predefinedAvatar'] = avatarKey;
    _logger.d("Avatar predefinido seleccionado: $avatarKey");
  }

  /// Subir imagen a Firebase Storage
  Future<String?> _uploadImage(String childId) async {
    if (imageFile.value == null) return null;

    isUploading.value = true;
    uploadProgress.value = 0.0;

    try {
      final storageRef = _storage.ref().child('child_avatars/$childId.jpg');

      final uploadTask = storageRef.putFile(
        imageFile.value!,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Monitorear progreso
      uploadTask.snapshotEvents.listen((event) {
        uploadProgress.value = event.bytesTransferred / event.totalBytes;
      });

      // Esperar a que termine la subida
      await uploadTask;

      // Obtener URL de descarga
      final downloadUrl = await storageRef.getDownloadURL();

      isUploading.value = false;
      _logger.i("Imagen subida exitosamente: $downloadUrl");
      return downloadUrl;
    } catch (e, stackTrace) {
      _logger.e('Error subiendo imagen a Firebase: $e',
          error: e, stackTrace: stackTrace);
      isUploading.value = false;
      errorMessage.value = TrKeys.errorUploadingImage.tr;
      return null;
    }
  }

  /// Crea un nuevo perfil infantil
  Future<void> createChildProfile() async {
    final currentFamily = _familyController.currentFamily.value;
    final currentUser = _sessionController.currentUser.value;

    if (currentFamily == null || currentUser == null) {
      _logger.e("No hay familia o usuario para crear el perfil infantil");
      errorMessage.value = 'child_profile_no_family_user'.tr;
      return;
    }

    status.value = ChildProfileStatus.loading;
    errorMessage.value = '';

    try {
      // Validar datos básicos
      final name = nameController.text.trim();
      if (name.isEmpty) {
        status.value = ChildProfileStatus.error;
        errorMessage.value = TrKeys.requiredField.tr;
        return;
      }

      // Crear entrada temporal para subir imagen
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();

      // Subir imagen si existe
      String? avatarUrl;
      if (imageFile.value != null) {
        avatarUrl = await _uploadImage(tempId);
        if (avatarUrl == null && errorMessage.isNotEmpty) {
          status.value = ChildProfileStatus.error;
          return;
        }
      }

      // Crear perfil infantil
      _logger.i("Creando perfil infantil: $name");
      final result = await _familyChildRepository.createChild(
        familyId: currentFamily.id,
        name: name,
        birthDate: birthDate.value,
        avatarUrl: avatarUrl,
        createdBy: currentUser.uid,
        settings: childSettings,
      );

      result.fold(
        (failure) {
          status.value = ChildProfileStatus.error;
          errorMessage.value = failure.message;
          _logger.e("Error creando perfil infantil: ${failure.message}");
        },
        (child) async {
          // Si se subió la imagen con un ID temporal, renombrarla
          if (avatarUrl != null && imageFile.value != null) {
            try {
              final newStorageRef =
                  _storage.ref().child('child_avatars/${child.id}.jpg');
              final oldStorageRef =
                  _storage.ref().child('child_avatars/$tempId.jpg');

              // Descargar el archivo
              final bytes = await oldStorageRef.getData();

              // Subirlo con el nuevo nombre
              if (bytes != null) {
                await newStorageRef.putData(bytes);

                // Obtener nueva URL
                final newUrl = await newStorageRef.getDownloadURL();

                // Actualizar perfil con nueva URL
                await _familyChildRepository
                    .updateChild(child.copyWith(avatarUrl: newUrl));

                // Eliminar archivo original
                await oldStorageRef.delete();
              }
            } catch (e) {
              _logger.w("Error renombrando imagen de perfil: $e");
              // No es crítico si falla esto
            }
          }

          // Limpiar formulario
          prepareForNewChild();

          // Actualizar lista de perfiles
          await loadChildProfiles();

          status.value = ChildProfileStatus.success;
          _logger.i("Perfil infantil creado exitosamente: ${child.id}");

          // Mostrar mensaje de éxito
          Get.back(); // Cerrar pantalla de creación
          Get.snackbar(
            'child_profile_created_title'.tr,
            'child_profile_created_message'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withAlpha(40),
            colorText: Colors.green,
          );
        },
      );
    } catch (e, stackTrace) {
      _logger.e("Error en creación de perfil: $e",
          error: e, stackTrace: stackTrace);
      status.value = ChildProfileStatus.error;
      errorMessage.value = e.toString();
    }
  }

  /// Actualiza un perfil infantil existente
  Future<void> updateChildProfile() async {
    if (selectedChild.value == null) {
      _logger.e("No hay perfil infantil seleccionado para actualizar");
      return;
    }

    status.value = ChildProfileStatus.loading;
    errorMessage.value = '';

    try {
      // Validar datos básicos
      final name = nameController.text.trim();
      if (name.isEmpty) {
        status.value = ChildProfileStatus.error;
        errorMessage.value = TrKeys.requiredField.tr;
        return;
      }

      // Validar y parsear puntos y nivel
      final points = int.tryParse(pointsController.text) ?? 0;
      final level = int.tryParse(levelController.text) ?? 1;

      // Subir imagen si existe una nueva
      String? newAvatarUrl;
      if (imageFile.value != null) {
        newAvatarUrl = await _uploadImage(selectedChild.value!.id);
        if (newAvatarUrl == null && errorMessage.isNotEmpty) {
          status.value = ChildProfileStatus.error;
          return;
        }
      }

      // Actualizar perfil infantil
      final updatedChild = selectedChild.value!.copyWith(
        name: name,
        birthDate: birthDate.value,
        avatarUrl: newAvatarUrl ?? selectedChild.value!.avatarUrl,
        points: points,
        level: level,
        settings: childSettings,
      );

      _logger.i("Actualizando perfil infantil: ${updatedChild.id}");
      final result = await _familyChildRepository.updateChild(updatedChild);

      result.fold(
        (failure) {
          status.value = ChildProfileStatus.error;
          errorMessage.value = failure.message;
          _logger.e("Error actualizando perfil infantil: ${failure.message}");
        },
        (_) async {
          // Actualizar lista de perfiles
          await loadChildProfiles();

          // Actualizar perfil seleccionado
          final updatedIndex =
              childProfiles.indexWhere((child) => child.id == updatedChild.id);
          if (updatedIndex >= 0) {
            selectedChild.value = childProfiles[updatedIndex];
          }

          status.value = ChildProfileStatus.success;
          _logger.i("Perfil infantil actualizado exitosamente");

          // Mostrar mensaje de éxito
          Get.back(); // Cerrar pantalla de edición
          Get.snackbar(
            'child_profile_updated_title'.tr,
            'child_profile_updated_message'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withAlpha(40),
            colorText: Colors.green,
          );
        },
      );
    } catch (e, stackTrace) {
      _logger.e("Error en actualización de perfil: $e",
          error: e, stackTrace: stackTrace);
      status.value = ChildProfileStatus.error;
      errorMessage.value = e.toString();
    }
  }

  /// Elimina un perfil infantil
  Future<void> deleteChildProfile(String childId) async {
    status.value = ChildProfileStatus.loading;
    errorMessage.value = '';

    _logger.i("Eliminando perfil infantil: $childId");
    final result = await _familyChildRepository.deleteChild(childId);

    result.fold(
      (failure) {
        status.value = ChildProfileStatus.error;
        errorMessage.value = failure.message;
        _logger.e("Error eliminando perfil infantil: ${failure.message}");
      },
      (_) async {
        // Si se elimina el perfil seleccionado, limpiar la selección
        if (selectedChild.value?.id == childId) {
          selectedChild.value = null;
        }

        // Actualizar lista de perfiles
        await loadChildProfiles();

        status.value = ChildProfileStatus.success;
        _logger.i("Perfil infantil eliminado exitosamente");

        // Mostrar mensaje de éxito
        Get.snackbar(
          'child_profile_deleted_title'.tr,
          'child_profile_deleted_message'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withAlpha(40),
          colorText: Colors.red,
        );
      },
    );
  }
}
