import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:kidsdo/domain/entities/family_child.dart';
import 'package:kidsdo/domain/repositories/family_child_repository.dart';
import 'package:kidsdo/presentation/controllers/family_controller.dart';
import 'package:kidsdo/presentation/controllers/parental_control_controller.dart';
import 'package:kidsdo/presentation/controllers/settings_controller.dart'; // Added import
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ChildAccessStatus {
  initial,
  loading,
  success,
  error,
}

/// Controlador para gestionar el acceso de los niños a sus perfiles
class ChildAccessController extends GetxController {
  final IFamilyChildRepository _familyChildRepository;
  final FamilyController _familyController;
  final ParentalControlController _parentalControlController;
  final SharedPreferences _sharedPreferences;
  final Logger _logger;

  // Estado observable
  final Rx<ChildAccessStatus> status =
      Rx<ChildAccessStatus>(ChildAccessStatus.initial);
  final RxString errorMessage = RxString('');

  // Lista de perfiles infantiles disponibles
  final RxList<FamilyChild> availableChildren = RxList<FamilyChild>([]);

  // Perfil infantil actualmente seleccionado
  final Rx<FamilyChild?> activeChildProfile = Rx<FamilyChild?>(null);

  // Clave para almacenar el ID del último perfil seleccionado
  static const String _lastActiveChildKey = 'last_active_child_id';

  // Determina si estamos en modo infantil
  final RxBool isChildMode = RxBool(false);

  // Tiempo de inicio de la sesión infantil
  final Rx<DateTime?> sessionStartTime = Rx<DateTime?>(null);

  // Estado de la notificación de tiempo
  final RxBool timeWarningShown = RxBool(false);

  // Estado de acceso restringido por tiempo
  final RxBool timeRestricted = RxBool(false);
  final RxString timeRestrictionMessage = RxString('');

  ChildAccessController({
    required IFamilyChildRepository familyChildRepository,
    required FamilyController familyController,
    required ParentalControlController parentalControlController,
    required SharedPreferences sharedPreferences,
    required Logger logger,
  })  : _familyChildRepository = familyChildRepository,
        _familyController = familyController,
        _parentalControlController = parentalControlController,
        _sharedPreferences = sharedPreferences,
        _logger = logger;

  @override
  void onInit() {
    super.onInit();

    // Escuchar cambios en la familia seleccionada
    ever(_familyController.currentFamily, (_) {
      if (_familyController.currentFamily.value != null) {
        loadAvailableChildProfiles();
      } else {
        availableChildren.clear();
        activeChildProfile.value = null;
        isChildMode.value = false;
      }
    });

    // Intentar cargar el último perfil activo
    loadLastActiveProfile();

    _logger.i("ChildAccessController initialized");
  }

  /// Carga todos los perfiles infantiles disponibles para la familia actual
  Future<void> loadAvailableChildProfiles() async {
    final currentFamily = _familyController.currentFamily.value;
    if (currentFamily == null) {
      _logger.w(
          "No hay familia seleccionada, no se pueden cargar perfiles infantiles");
      return;
    }

    status.value = ChildAccessStatus.loading;
    availableChildren.clear();
    errorMessage.value = '';

    _logger
        .i("Cargando perfiles infantiles para la familia: ${currentFamily.id}");
    final result =
        await _familyChildRepository.getChildrenByFamilyId(currentFamily.id);

    result.fold(
      (failure) {
        status.value = ChildAccessStatus.error;
        errorMessage.value = failure.message;
        _logger.e("Error cargando perfiles infantiles: ${failure.message}");
      },
      (children) {
        // Filtrar perfiles bloqueados si el control parental está activado
        final filteredChildren = children
            .where((child) =>
                !_parentalControlController.isProfileBlocked(child.id))
            .toList();

        // Ordenar alfabéticamente por nombre
        filteredChildren.sort((a, b) => a.name.compareTo(b.name));

        availableChildren.addAll(filteredChildren);
        status.value = ChildAccessStatus.success;
        _logger.i(
            "Se cargaron ${filteredChildren.length} perfiles infantiles disponibles (de ${children.length} totales)");

        // Si hay un perfil activo, verificar que sigue estando disponible y no bloqueado
        if (activeChildProfile.value != null) {
          final stillAvailable = availableChildren
              .any((child) => child.id == activeChildProfile.value!.id);

          if (!stillAvailable) {
            activeChildProfile.value = null;
            isChildMode.value = false;
            _sharedPreferences.remove(_lastActiveChildKey);
            _logger
                .w("El perfil activo ya no está disponible o está bloqueado");
          }
        }
      },
    );
  }

  /// Activa un perfil infantil y entra en modo infantil
  Future<void> activateChildProfile(FamilyChild child) async {
    // Verificar restricciones de tiempo
    if (!checkTimeRestrictions()) {
      return;
    }

    // Verificar si el perfil está bloqueado
    if (_parentalControlController.isProfileBlocked(child.id)) {
      errorMessage.value = 'child_profile_blocked'.tr;
      Get.snackbar(
        'profile_blocked_title'.tr,
        'profile_blocked_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 40),
        colorText: Colors.red,
      );
      return;
    }

    activeChildProfile.value = child;
    isChildMode.value = true;
    sessionStartTime.value = DateTime.now();
    timeWarningShown.value = false;

    // Guardar el ID del perfil activo para futuros accesos
    await _sharedPreferences.setString(_lastActiveChildKey, child.id);

    _logger.i("Perfil infantil activado: ${child.name} (${child.id})");
  }

  /// Carga el último perfil activo si existe
  Future<void> loadLastActiveProfile() async {
    if (availableChildren.isEmpty) {
      await loadAvailableChildProfiles();
    }

    final lastActiveChildId = _sharedPreferences.getString(_lastActiveChildKey);
    if (lastActiveChildId != null && availableChildren.isNotEmpty) {
      final childProfile = availableChildren
          .firstWhereOrNull((child) => child.id == lastActiveChildId);

      if (childProfile != null) {
        activeChildProfile.value = childProfile;
        _logger.i("Último perfil activo cargado: ${childProfile.name}");
      }
    }
  }

  /// Sale del modo infantil y vuelve al modo padre
  void exitChildMode() {
    if (isChildMode.value) {
      isChildMode.value = false;
      activeChildProfile.value = null;
      sessionStartTime.value = null;
      timeWarningShown.value = false;
      _logger.i("Exiting child mode. UI should switch to Parent mode.");

      // Update the setting in SettingsController to keep it in sync
      final settingsCtrl = Get.find<SettingsController>();
      if (settingsCtrl.isChildModeActiveOnDevice.value) {
        settingsCtrl.setChildModeActiveOnDevice(false,
            calledFromChildAccess: true);
      }
    }
  }

  /// Enters global child mode, typically called from SettingsController.
  /// This method itself does not navigate. Navigation is handled by UI reacting to `isChildMode`.
  void enterGlobalChildMode() {
    if (!isChildMode.value) {
      isChildMode.value = true;
      _logger.i(
          "Global child mode requested. UI should switch to ChildProfileSelectionPage.");
    }
  }

  /// Verifica si el PIN introducido es correcto
  bool verifyParentalPin(String pin) {
    return _parentalControlController.verifyParentalPin(pin);
  }

  /// Verifica si se puede acceder al modo infantil según las restricciones de tiempo
  bool checkTimeRestrictions() {
    // Verificar bloqueo temporal
    if (!_parentalControlController.canUseParentalControl()) {
      final remainingTime =
          _parentalControlController.getRemainingLockTimeMinutes();
      errorMessage.value = 'parental_control_temporarily_locked'
          .trParams({'minutes': remainingTime.toString()});

      Get.snackbar(
        'parental_control_locked_title'.tr,
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 40),
        colorText: Colors.red,
      );
      return false;
    }

    // Verificar restricciones horarias
    final timeMessage = _parentalControlController.getTimeRestrictionMessage();
    if (timeMessage != null) {
      timeRestricted.value = true;
      timeRestrictionMessage.value = timeMessage;

      Get.snackbar(
        'time_restriction_title'.tr,
        timeMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 40),
        colorText: Colors.orange.shade800,
      );
      return false;
    }

    timeRestricted.value = false;
    return true;
  }

  /// Verifica si el tiempo de sesión ha superado el límite
  bool checkSessionTimeLimit() {
    if (sessionStartTime.value == null || !isChildMode.value) {
      return true;
    }

    final maxSessionMinutes = _parentalControlController.maxSessionTime.value;
    final sessionDuration = DateTime.now().difference(sessionStartTime.value!);
    final sessionMinutes = sessionDuration.inMinutes;

    // Si ha superado el 80% del tiempo y no se ha mostrado advertencia
    if (sessionMinutes >= (maxSessionMinutes * 0.8) &&
        !timeWarningShown.value) {
      timeWarningShown.value = true;
      Get.snackbar(
        'session_time_warning_title'.tr,
        'session_time_warning_message'.trParams(
            {'minutes': (maxSessionMinutes - sessionMinutes).toString()}),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.amber.withValues(alpha: 40),
        colorText: Colors.amber.shade900,
        duration: const Duration(seconds: 5),
      );
    }

    // Si ha superado el tiempo máximo
    if (sessionMinutes >= maxSessionMinutes) {
      Get.snackbar(
        'session_time_exceeded_title'.tr,
        'session_time_exceeded_message'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withValues(alpha: 40),
        colorText: Colors.red,
        duration: const Duration(seconds: 5),
      );

      // Forzar salida del modo infantil
      exitChildMode();
      return false;
    }

    return true;
  }

  /// Obtiene el tiempo restante de sesión en minutos
  int getRemainingSessionTime() {
    if (sessionStartTime.value == null) return 0;

    final maxSessionMinutes = _parentalControlController.maxSessionTime.value;
    final sessionDuration = DateTime.now().difference(sessionStartTime.value!);
    final sessionMinutes = sessionDuration.inMinutes;

    final remaining = maxSessionMinutes - sessionMinutes;
    return remaining < 0 ? 0 : remaining;
  }
}
