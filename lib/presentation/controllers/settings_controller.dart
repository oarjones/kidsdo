// lib/presentation/controllers/settings_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/presentation/controllers/child_access_controller.dart'; // Added import
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kidsdo/core/translations/app_translations.dart';

class SettingsController extends GetxController {
  final SharedPreferences sharedPreferences;

  static const String _prefChildModeActiveKey = 'childModeActiveOnDevice';
  static const String _prefAppLanguageKey = 'appLanguage_v2';

  final RxBool isChildModeActiveOnDevice = false.obs;
  final RxBool isLoading = true.obs;
  final RxString currentLanguageCode =
      AppTranslations.fallbackLocale.languageCode.obs;
  final RxString? currentCountryCode =
      (AppTranslations.fallbackLocale.countryCode ?? '').obs;

  SettingsController({required this.sharedPreferences});

  @override
  void onInit() {
    super.onInit();
    loadInitialSettings();
  }

  Future<void> loadInitialSettings() async {
    isLoading.value = true;
    try {
      isChildModeActiveOnDevice.value =
          sharedPreferences.getBool(_prefChildModeActiveKey) ?? false;

      final String? savedLangFull =
          sharedPreferences.getString(_prefAppLanguageKey);
      Locale localeToSet;

      if (savedLangFull != null && savedLangFull.isNotEmpty) {
        List<String> parts = savedLangFull.split('_');
        String langCode = parts[0];
        String? countryC = parts.length > 1 ? parts[1] : null;

        if (AppTranslations.locales.any(
            (l) => l.languageCode == langCode && l.countryCode == countryC)) {
          localeToSet = Locale(langCode, countryC);
        } else {
          localeToSet = AppTranslations.fallbackLocale;
        }
      } else {
        Locale? deviceLocale = Get.deviceLocale;
        if (deviceLocale != null &&
            AppTranslations.locales
                .any((l) => l.languageCode == deviceLocale.languageCode)) {
          Locale matchingLocale = AppTranslations.locales.firstWhere(
              (l) =>
                  l.languageCode == deviceLocale.languageCode &&
                  l.countryCode == deviceLocale.countryCode,
              orElse: () => AppTranslations.locales.firstWhere(
                  (l) => l.languageCode == deviceLocale.languageCode,
                  orElse: () => AppTranslations.fallbackLocale));
          localeToSet = matchingLocale;
        } else {
          localeToSet = AppTranslations.fallbackLocale;
        }
        await sharedPreferences.setString(
            _prefAppLanguageKey, _formatLocaleToStringInternal(localeToSet));
      }

      _updateGetXLocale(localeToSet);
    } catch (e, s) {
      Get.printError(info: "Error loading settings: $e\n$s");
      Get.snackbar(
        TrKeys.error.tr,
        TrKeys.settingsLoadingError.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      _updateGetXLocale(AppTranslations.fallbackLocale);
    } finally {
      isLoading.value = false;
    }
  }

  void _updateGetXLocale(Locale locale) {
    currentLanguageCode.value = locale.languageCode;
    currentCountryCode?.value = locale.countryCode ?? '';
    Get.updateLocale(locale);
  }

  Future<void> setChildModeActiveOnDevice(bool isActive,
      {bool _calledFromChildAccess = false}) async {
    if (isChildModeActiveOnDevice.value == isActive && _calledFromChildAccess) {
      // If called from ChildAccessController.exitChildMode and the value is already what CAC expects,
      // and we are trying to set it to the same value, then ChildAccessController already handled its state.
      // We just need to persist.
      await sharedPreferences.setBool(_prefChildModeActiveKey, isActive);
      // No snackbar here if called from CAC to avoid double snackbar
      return;
    }

    if (isChildModeActiveOnDevice.value == isActive) return; // No change needed

    isChildModeActiveOnDevice.value = isActive;
    await sharedPreferences.setBool(_prefChildModeActiveKey, isActive);

    final childAccessCtrl = Get.find<ChildAccessController>();

    if (isActive) {
      childAccessCtrl.enterGlobalChildMode();
      // Show snackbar only if not called from ChildAccessController, or if you always want to show it
      // For this implementation, we'll show it as it indicates the setting was changed.
      Get.snackbar(
        TrKeys.info.tr,
        TrKeys.childModeActivated.tr,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blueAccent,
        colorText: Colors.white,
      );
    } else {
      // Only call exitChildMode if not already called from it
      if (!_calledFromChildAccess) {
        childAccessCtrl.exitChildMode();
      }
      // Similar logic for snackbar
      Get.snackbar(
        TrKeys.info.tr,
        TrKeys.childModeDeactivated.tr,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
    }
  }

  // Método interno para formatear un Locale específico a string
  String _formatLocaleToStringInternal(Locale locale) {
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      return '${locale.languageCode}_${locale.countryCode}';
    }
    return locale.languageCode;
  }

  // Método público para obtener el string del Locale actual del controlador
  String formatCurrentLocaleToString() {
    if (currentCountryCode?.value != null &&
        currentCountryCode!.value.isNotEmpty) {
      return '${currentLanguageCode.value}_${currentCountryCode?.value}';
    }
    return currentLanguageCode.value;
  }

  Future<void> changeLanguage(Locale newLocale) async {
    if (!AppTranslations.locales.any((l) =>
        l.languageCode == newLocale.languageCode &&
        l.countryCode == newLocale.countryCode)) {
      Get.snackbar(TrKeys.error.tr, "Idioma no soportado",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    await sharedPreferences.setString(
        _prefAppLanguageKey, _formatLocaleToStringInternal(newLocale));
    _updateGetXLocale(newLocale);

    Get.snackbar(
      TrKeys.info.tr,
      "Idioma actualizado a ${_formatLocaleToStringInternal(newLocale)}",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blueAccent,
      colorText: Colors.white,
    );
  }

  void changeToSpanish() => changeLanguage(const Locale('es', 'ES'));
  void changeToEnglish() => changeLanguage(const Locale('en', 'US'));

  String getCurrentLanguageName() {
    // ... (sin cambios)
    final Locale currentLocale = Get.locale ?? AppTranslations.fallbackLocale;
    switch (currentLocale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return currentLocale.languageCode;
    }
  }

  Locale getCurrentLocale() {
    return Locale(currentLanguageCode.value,
        currentCountryCode?.value == '' ? null : currentCountryCode?.value);
  }
}
