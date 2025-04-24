import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/parent.dart';
import 'package:kidsdo/domain/repositories/user_repository.dart';
import 'package:kidsdo/presentation/controllers/session_controller.dart';
import 'package:kidsdo/routes.dart';
import 'package:logger/logger.dart';

enum ProfileStatus {
  initial,
  loading,
  success,
  error,
}

class ProfileController extends GetxController {
  final IUserRepository _userRepository;
  final SessionController _sessionController;
  final FirebaseStorage _storage;
  final ImagePicker _imagePicker;
  final Logger _logger;

  ProfileController({
    required IUserRepository userRepository,
    required SessionController sessionController,
    required FirebaseStorage storage,
    required ImagePicker imagePicker,
    required Logger logger,
  })  : _userRepository = userRepository,
        _sessionController = sessionController,
        _storage = storage,
        _imagePicker = imagePicker,
        _logger = logger;

  // Estado observable
  final Rx<ProfileStatus> status = Rx<ProfileStatus>(ProfileStatus.initial);
  final RxString errorMessage = RxString('');

  // Datos del perfil
  final Rx<Parent?> profile = Rx<Parent?>(null);

  // Archivos e imágenes
  final Rx<File?> imageFile = Rx<File?>(null);
  final RxBool isUploading = RxBool(false);
  final RxDouble uploadProgress = RxDouble(0.0);

  // Controladores de texto para formularios
  late TextEditingController nameController;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    loadProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  // Cargar perfil desde SessionController
  Future<void> loadProfile() async {
    status.value = ProfileStatus.loading;
    errorMessage.value = '';

    try {
      _logger.i('Cargando perfil de usuario');

      // Intentar obtener el usuario actual de la sesión
      final currentUser = _sessionController.currentUser.value;

      if (currentUser != null) {
        _logger
            .i('Usuario encontrado en SessionController: ${currentUser.uid}');
        profile.value = currentUser;
        nameController.text = currentUser.displayName;
        status.value = ProfileStatus.success;
        return; // Salir temprano si tenemos el usuario
      }

      // Si llegamos aquí, no hay usuario en el SessionController
      _logger.w('No se encontró usuario en SessionController');

      // Intentar obtener el usuario a través de Firebase Auth directamente
      final authResult = await _userRepository.getCurrentParentFromAuth();

      authResult.fold(
        (failure) {
          _logger.e(
              'No se pudo obtener el usuario autenticado: ${failure.message}');
          status.value = ProfileStatus.error;
          errorMessage.value = TrKeys.sessionExpired.tr;

          // Redirigir al login si no hay sesión
          _sessionController.clearCurrentUser();
          Get.offAllNamed(Routes.login);
        },
        (parent) {
          if (parent != null) {
            _logger.i('Perfil obtenido desde Auth: ${parent.uid}');
            profile.value = parent;
            nameController.text = parent.displayName;
            // Actualizar el SessionController
            _sessionController.setCurrentUser(parent);
            status.value = ProfileStatus.success;
          } else {
            _logger.e('No hay usuario autenticado');
            status.value = ProfileStatus.error;
            errorMessage.value = TrKeys.sessionExpired.tr;

            // Redirigir al login si no hay sesión
            _sessionController.clearCurrentUser();
            Get.offAllNamed(Routes.login);
          }
        },
      );
    } catch (e, stackTrace) {
      _logger.e('Error cargando perfil: $e', error: e, stackTrace: stackTrace);
      status.value = ProfileStatus.error;
      errorMessage.value = e.toString();
    }
  }

  // Seleccionar imagen de la galería
  Future<void> pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        imageFile.value = File(pickedFile.path);
      }
    } catch (e, stackTrace) {
      _logger.e('Error seleccionando imagen: $e',
          error: e, stackTrace: stackTrace);
      errorMessage.value = TrKeys.errorSelectingImage.tr;
    }
  }

  // Seleccionar imagen de la cámara
  Future<void> takePicture() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        imageFile.value = File(pickedFile.path);
      }
    } catch (e, stackTrace) {
      _logger.e('Error capturando imagen: $e',
          error: e, stackTrace: stackTrace);
      errorMessage.value = TrKeys.errorCapturingImage.tr;
    }
  }

  // Subir imagen a Firebase Storage
  Future<String?> _uploadImage() async {
    if (imageFile.value == null) return null;

    isUploading.value = true;
    uploadProgress.value = 0.0;

    try {
      final parentId = profile.value?.uid ?? '';
      final storageRef = _storage.ref().child('avatars/$parentId.jpg');

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
      return downloadUrl;
    } catch (e, stackTrace) {
      _logger.e('Error subiendo imagen a Firebase: $e',
          error: e, stackTrace: stackTrace);
      isUploading.value = false;
      errorMessage.value = TrKeys.errorUploadingImage.tr;
      return null;
    }
  }

  // Actualizar perfil
  Future<void> updateProfile() async {
    if (profile.value == null) return;

    status.value = ProfileStatus.loading;
    errorMessage.value = '';

    try {
      // Subir imagen si existe una nueva
      String? photoUrl;
      if (imageFile.value != null) {
        photoUrl = await _uploadImage();
        if (photoUrl == null && errorMessage.isNotEmpty) {
          status.value = ProfileStatus.error;
          return;
        }
      }

      // Actualizar objeto Parent
      final updatedParent = profile.value!.copyWith(
        displayName: nameController.text.trim(),
        avatarUrl: photoUrl ?? profile.value!.avatarUrl,
      );

      // Guardar en Firestore
      final result = await _userRepository.saveParent(updatedParent);

      result.fold(
        (failure) {
          status.value = ProfileStatus.error;
          errorMessage.value = failure.message;
        },
        (_) async {
          // Actualizar perfil en Auth
          await _sessionController.updateUserProfile(
            displayName: nameController.text.trim(),
            photoUrl: photoUrl,
          );

          // Actualizar perfil local
          profile.value = updatedParent;
          _sessionController.setCurrentUser(updatedParent);

          status.value = ProfileStatus.success;
          Get.back(); // Volver a la pantalla anterior
          Get.snackbar(
            TrKeys.success.tr,
            TrKeys.profileUpdatedSuccessfully.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.1),
            colorText: Colors.green,
          );
        },
      );
    } catch (e, stackTrace) {
      _logger.e('Error actualizando perfil: $e',
          error: e, stackTrace: stackTrace);
      status.value = ProfileStatus.error;
      errorMessage.value = e.toString();
    }
  }

  // Limpiar imagen seleccionada
  void clearSelectedImage() {
    imageFile.value = null;
  }
}
