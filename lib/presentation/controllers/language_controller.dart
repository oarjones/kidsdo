import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controlador para gestionar el idioma de la aplicación
class LanguageController extends GetxController {
  final SharedPreferences _sharedPreferences;

  // Clave para almacenar el idioma en SharedPreferences
  static const String _languageKey = 'selected_language';
  static const String _countryKey = 'selected_country';

  // Lista de idiomas soportados
  final List<Locale> supportedLocales = [
    const Locale('es', 'ES'), // Español (España)
    const Locale('en', 'US'), // Inglés (Estados Unidos)
  ];

  LanguageController({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences;

  @override
  void onInit() {
    super.onInit();
    // Al iniciar, cargar el idioma guardado o usar el del sistema
    loadSavedLanguage();
  }

  /// Carga el idioma guardado en SharedPreferences
  void loadSavedLanguage() {
    final String? languageCode = _sharedPreferences.getString(_languageKey);
    final String? countryCode = _sharedPreferences.getString(_countryKey);

    if (languageCode != null && countryCode != null) {
      // Si hay un idioma guardado, usarlo
      updateLocale(Locale(languageCode, countryCode));
    } else {
      // Si no hay idioma guardado, usar el del sistema
      if (Get.deviceLocale != null) {
        // Verificar si el idioma del sistema está soportado
        final String deviceLanguage = Get.deviceLocale!.languageCode;
        final bool isSupported = supportedLocales
            .map((locale) => locale.languageCode)
            .contains(deviceLanguage);

        if (isSupported) {
          // Si está soportado, usar el idioma del sistema
          updateLocale(Get.deviceLocale!);
        } else {
          // Si no está soportado, usar el idioma por defecto (español)
          updateLocale(const Locale('es', 'ES'));
        }
      } else {
        // Si no se puede determinar el idioma del sistema, usar español
        updateLocale(const Locale('es', 'ES'));
      }
    }
  }

  /// Actualiza el idioma de la aplicación
  void updateLocale(Locale locale) {
    Get.updateLocale(locale);
    // Guardar el idioma seleccionado
    _sharedPreferences.setString(_languageKey, locale.languageCode);
    _sharedPreferences.setString(_countryKey, locale.countryCode ?? '');

    // Notificar a los widgets que usan GetBuilder
    update();
  }

  /// Cambia al idioma español
  void changeToSpanish() {
    updateLocale(const Locale('es', 'ES'));
    update(); // Llamar a update() para notificar a los widgets que usan GetBuilder
  }

  /// Cambia al idioma inglés
  void changeToEnglish() {
    updateLocale(const Locale('en', 'US'));
    update(); // Llamar a update() para notificar a los widgets que usan GetBuilder
  }

  /// Obtiene el nombre del idioma actual
  String getCurrentLanguageName() {
    final Locale currentLocale = Get.locale ?? const Locale('es', 'ES');
    switch (currentLocale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return 'Español';
    }
  }
}
