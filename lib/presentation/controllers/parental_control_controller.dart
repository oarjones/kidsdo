import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/translations/app_translations.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

enum ParentalControlStatus {
  initial,
  loading,
  success,
  error,
}

class ParentalControlController extends GetxController {
  final SharedPreferences _sharedPreferences;
  final Logger _logger;

  // Estado observable
  final Rx<ParentalControlStatus> status =
      Rx<ParentalControlStatus>(ParentalControlStatus.initial);
  final RxString errorMessage = RxString('');

  // PIN de acceso parental
  final RxString parentalPin = RxString('');
  final RxBool useParentalPin = RxBool(false);
  static const String _parentalPinKey = 'parental_control_pin';
  static const String _useParentalPinKey = 'use_parental_control_pin';

  // PIN temporal para confirmación de cambios
  final TextEditingController currentPinController = TextEditingController();
  final TextEditingController newPinController = TextEditingController();
  final TextEditingController confirmPinController = TextEditingController();

  // Restricciones de tiempo
  final RxBool useTimeRestrictions = RxBool(false);
  final RxString allowedStartTime = RxString('08:00');
  final RxString allowedEndTime = RxString('20:00');
  static const String _useTimeRestrictionsKey = 'use_time_restrictions';
  static const String _allowedStartTimeKey = 'allowed_start_time';
  static const String _allowedEndTimeKey = 'allowed_end_time';

  // Bloqueo de perfiles
  final RxList<String> blockedProfiles = RxList<String>([]);
  static const String _blockedProfilesKey = 'blocked_profiles';

  // Control de contenido
  final RxBool restrictPremiumContent = RxBool(false);
  static const String _restrictPremiumContentKey = 'restrict_premium_content';

  // Tiempo máximo permitido por sesión (en minutos)
  final RxInt maxSessionTime = RxInt(60);
  static const String _maxSessionTimeKey = 'max_session_time';

  // Control de recuperación de PIN
  final RxString recoveryEmail = RxString('');
  static const String _recoveryEmailKey = 'recovery_email';

  // Intentos de PIN fallidos
  final RxInt failedPinAttempts = RxInt(0);
  static const String _failedPinAttemptsKey = 'failed_pin_attempts';
  static const int maxFailedAttempts = 5;

  // Bloqueo temporal
  final RxBool isTemporarilyLocked = RxBool(false);
  final RxString lockExpirationTime = RxString('');
  static const String _lockExpirationTimeKey = 'lock_expiration_time';

  ParentalControlController({
    required SharedPreferences sharedPreferences,
    required Logger logger,
  })  : _sharedPreferences = sharedPreferences,
        _logger = logger;

  @override
  void onInit() {
    super.onInit();
    _loadAllSettings();
    _logger.i("ParentalControlController initialized");
  }

  @override
  void onClose() {
    currentPinController.dispose();
    newPinController.dispose();
    confirmPinController.dispose();
    super.onClose();
  }

  /// Carga todas las configuraciones de control parental
  void _loadAllSettings() {
    // Cargar PIN de control parental
    parentalPin.value = _sharedPreferences.getString(_parentalPinKey) ?? '0000';
    useParentalPin.value =
        _sharedPreferences.getBool(_useParentalPinKey) ?? false;

    // Cargar restricciones de tiempo
    useTimeRestrictions.value =
        _sharedPreferences.getBool(_useTimeRestrictionsKey) ?? false;
    allowedStartTime.value =
        _sharedPreferences.getString(_allowedStartTimeKey) ?? '08:00';
    allowedEndTime.value =
        _sharedPreferences.getString(_allowedEndTimeKey) ?? '20:00';

    // Cargar perfiles bloqueados
    final blockedProfilesStr =
        _sharedPreferences.getStringList(_blockedProfilesKey);
    if (blockedProfilesStr != null) {
      blockedProfiles.value = blockedProfilesStr;
    }

    // Cargar restricciones de contenido
    restrictPremiumContent.value =
        _sharedPreferences.getBool(_restrictPremiumContentKey) ?? false;

    // Cargar tiempo máximo de sesión
    maxSessionTime.value = _sharedPreferences.getInt(_maxSessionTimeKey) ?? 60;

    // Cargar email de recuperación
    recoveryEmail.value = _sharedPreferences.getString(_recoveryEmailKey) ?? '';

    // Cargar intentos fallidos
    failedPinAttempts.value =
        _sharedPreferences.getInt(_failedPinAttemptsKey) ?? 0;

    // Verificar bloqueo temporal
    final lockTime = _sharedPreferences.getString(_lockExpirationTimeKey);
    if (lockTime != null) {
      final expirationTime = DateTime.tryParse(lockTime);
      if (expirationTime != null && expirationTime.isAfter(DateTime.now())) {
        isTemporarilyLocked.value = true;
        lockExpirationTime.value = lockTime;
      } else {
        // El bloqueo expiró
        isTemporarilyLocked.value = false;
        _sharedPreferences.remove(_lockExpirationTimeKey);
      }
    }

    _logger
        .i("Control parental configurado: PIN activo: ${useParentalPin.value}");
  }

  /// Verifica si el PIN introducido es correcto
  bool verifyParentalPin(String pin) {
    if (!useParentalPin.value) {
      // Si el PIN está desactivado, no se requiere verificación
      return true;
    }

    if (pin == parentalPin.value) {
      // PIN correcto, reiniciar contador de intentos fallidos
      failedPinAttempts.value = 0;
      _sharedPreferences.setInt(_failedPinAttemptsKey, 0);
      return true;
    } else {
      // PIN incorrecto, incrementar contador
      failedPinAttempts.value++;
      _sharedPreferences.setInt(_failedPinAttemptsKey, failedPinAttempts.value);

      // Verificar si se debe bloquear temporalmente
      if (failedPinAttempts.value >= maxFailedAttempts) {
        _activateTemporaryLock();
      }

      return false;
    }
  }

  /// Activa el bloqueo temporal después de demasiados intentos fallidos
  void _activateTemporaryLock() {
    // Bloqueo por 30 minutos
    final expirationTime = DateTime.now().add(const Duration(minutes: 30));
    lockExpirationTime.value = expirationTime.toIso8601String();
    isTemporarilyLocked.value = true;

    // Guardar en preferences
    _sharedPreferences.setString(
        _lockExpirationTimeKey, lockExpirationTime.value);

    _logger.w(
        "Control parental bloqueado temporalmente hasta: ${expirationTime.toString()}");
  }

  /// Verifica si el usuario puede acceder según las restricciones de tiempo
  bool canAccessByTime() {
    if (!useTimeRestrictions.value) {
      return true;
    }

    try {
      final now = TimeOfDay.now();
      final nowMinutes = now.hour * 60 + now.minute;

      final startTimeParts = allowedStartTime.value.split(':');
      final startHour = int.parse(startTimeParts[0]);
      final startMinute = int.parse(startTimeParts[1]);
      final startTimeMinutes = startHour * 60 + startMinute;

      final endTimeParts = allowedEndTime.value.split(':');
      final endHour = int.parse(endTimeParts[0]);
      final endMinute = int.parse(endTimeParts[1]);
      final endTimeMinutes = endHour * 60 + endMinute;

      return nowMinutes >= startTimeMinutes && nowMinutes <= endTimeMinutes;
    } catch (e) {
      _logger.e("Error verificando restricciones de tiempo: $e");
      return true; // En caso de error, permitir acceso
    }
  }

  /// Verifica si un perfil infantil está bloqueado
  bool isProfileBlocked(String childId) {
    return blockedProfiles.contains(childId);
  }

  /// Bloquea o desbloquea un perfil infantil
  Future<void> toggleProfileBlock(String childId) async {
    if (blockedProfiles.contains(childId)) {
      blockedProfiles.remove(childId);
    } else {
      blockedProfiles.add(childId);
    }

    await _sharedPreferences.setStringList(
        _blockedProfilesKey, blockedProfiles);
    _logger.i(
        "Estado de bloqueo cambiado para perfil: $childId, Bloqueado: ${blockedProfiles.contains(childId)}");
  }

  /// Guarda las configuraciones de control parental
  Future<bool> saveParentalControlSettings() async {
    try {
      status.value = ParentalControlStatus.loading;

      // Guardar configuración de PIN
      await _sharedPreferences.setBool(
          _useParentalPinKey, useParentalPin.value);
      await _sharedPreferences.setString(_parentalPinKey, parentalPin.value);

      // Guardar restricciones de tiempo
      await _sharedPreferences.setBool(
          _useTimeRestrictionsKey, useTimeRestrictions.value);
      await _sharedPreferences.setString(
          _allowedStartTimeKey, allowedStartTime.value);
      await _sharedPreferences.setString(
          _allowedEndTimeKey, allowedEndTime.value);

      // Guardar restricciones de contenido
      await _sharedPreferences.setBool(
          _restrictPremiumContentKey, restrictPremiumContent.value);

      // Guardar tiempo máximo de sesión
      await _sharedPreferences.setInt(_maxSessionTimeKey, maxSessionTime.value);

      // Guardar perfiles bloqueados
      await _sharedPreferences.setStringList(
          _blockedProfilesKey, blockedProfiles);

      // Guardar email de recuperación
      if (recoveryEmail.value.isNotEmpty) {
        await _sharedPreferences.setString(
            _recoveryEmailKey, recoveryEmail.value);
      }

      _logger.i("Configuraciones de control parental guardadas correctamente");
      status.value = ParentalControlStatus.success;
      return true;
    } catch (e) {
      _logger.e("Error guardando configuraciones de control parental: $e");
      errorMessage.value = TrKeys.unexpectedErrorMessage.tr;
      status.value = ParentalControlStatus.error;
      return false;
    }
  }

  /// Cambia el PIN de control parental
  Future<bool> changeParentalPin(String currentPin, String newPin) async {
    try {
      status.value = ParentalControlStatus.loading;

      // Verificar PIN actual
      if (currentPin != parentalPin.value) {
        errorMessage.value = 'parental_pin_incorrect'.tr;
        status.value = ParentalControlStatus.error;
        return false;
      }

      // Actualizar PIN
      parentalPin.value = newPin;
      await _sharedPreferences.setString(_parentalPinKey, newPin);

      _logger.i("PIN de control parental actualizado correctamente");
      status.value = ParentalControlStatus.success;
      return true;
    } catch (e) {
      _logger.e("Error cambiando PIN de control parental: $e");
      errorMessage.value = TrKeys.unexpectedErrorMessage.tr;
      status.value = ParentalControlStatus.error;
      return false;
    }
  }

  /// Establece el email de recuperación
  Future<bool> setRecoveryEmail(String email) async {
    try {
      status.value = ParentalControlStatus.loading;

      recoveryEmail.value = email;
      await _sharedPreferences.setString(_recoveryEmailKey, email);

      _logger.i("Email de recuperación configurado: $email");
      status.value = ParentalControlStatus.success;
      return true;
    } catch (e) {
      _logger.e("Error configurando email de recuperación: $e");
      errorMessage.value = TrKeys.unexpectedErrorMessage.tr;
      status.value = ParentalControlStatus.error;
      return false;
    }
  }

  /// Verifica si se puede usar el control parental
  bool canUseParentalControl() {
    return !isTemporarilyLocked.value;
  }

  /// Obtiene el tiempo restante de bloqueo en minutos
  int getRemainingLockTimeMinutes() {
    if (!isTemporarilyLocked.value) return 0;

    try {
      final expirationTime = DateTime.parse(lockExpirationTime.value);
      final now = DateTime.now();
      final difference = expirationTime.difference(now);
      return difference.inMinutes < 0 ? 0 : difference.inMinutes;
    } catch (e) {
      return 0;
    }
  }

  /// Comprueba si esta dentro del horario permitido
  String? getTimeRestrictionMessage() {
    if (!useTimeRestrictions.value) return null;
    if (canAccessByTime()) return null;

    return 'parental_control_time_restricted'.trParams(
        {'start': allowedStartTime.value, 'end': allowedEndTime.value});
  }

  /// Desbloquea el control parental (para uso administrativo o recuperación)
  Future<void> unlockParentalControl() async {
    isTemporarilyLocked.value = false;
    failedPinAttempts.value = 0;
    await _sharedPreferences.remove(_lockExpirationTimeKey);
    await _sharedPreferences.setInt(_failedPinAttemptsKey, 0);
    _logger.i("Control parental desbloqueado manualmente");
  }

  /// Resetea el PIN a su valor por defecto
  Future<void> resetPinToDefault() async {
    parentalPin.value = '0000';
    await _sharedPreferences.setString(_parentalPinKey, '0000');
    _logger.i("PIN de control parental reseteado al valor por defecto");
  }
}
