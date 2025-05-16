import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kidsdo/app.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/firebase_options.dart';
import 'package:kidsdo/injection_container.dart' as di;
import 'package:kidsdo/presentation/controllers/settings_controller.dart';
import 'package:logger/logger.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Logger (debe ser uno de los primeros, si otros módulos lo usan temprano)
  final Logger logger = Logger(/* ... tu configuración de logger ... */);
  if (!Get.isRegistered<Logger>()) {
    Get.put<Logger>(logger, permanent: true);
  }

  // --- 1. Inicializar Firebase PRIMERO ---
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    logger.i("Firebase initialized successfully.");

    // Configurar Firebase App Check DESPUÉS de inicializar Firebase
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug, // Cambiar en producción
      appleProvider: AppleProvider.debug, // Cambiar en producción
    );
    logger.i("Firebase App Check activated.");
  } catch (e, s) {
    logger.e("CRITICAL: Error initializing Firebase or App Check: $e",
        error: e, stackTrace: s);
    // Considerar mostrar un error fatal al usuario si Firebase es esencial.
    // Por ahora, la app podría continuar, pero fallará si se accede a Firebase.
  }

  // --- 2. Inicialización de Dependencias (incluyendo SharedPreferences y SettingsController) ---
  // Ahora que Firebase está inicializado, di.init() puede registrar servicios de Firebase de forma segura.
  try {
    await di.init();
    logger.i("Dependency injection (di.init) initialized successfully.");

    // Asegurar que SettingsController cargue su configuración inicial
    if (Get.isRegistered<SettingsController>()) {
      await Get.find<SettingsController>().loadInitialSettings();
      logger.i("SettingsController initial settings loaded.");
    } else {
      logger.e(
          "CRITICAL: SettingsController not registered after di.init(). App might not behave as expected.");
    }
  } catch (e, s) {
    logger.e(
        "Error during dependency injection (di.init) or SettingsController load: $e",
        error: e,
        stackTrace: s);
  }

  // --- 3. Inicializar formato de fechas ---
  try {
    String localeForDateFormatting = 'es_ES'; // Fallback inicial
    if (Get.isRegistered<SettingsController>()) {
      final settingsCtrl = Get.find<SettingsController>();
      if (!settingsCtrl.isLoading.value &&
          settingsCtrl.currentLanguageCode.value.isNotEmpty) {
        localeForDateFormatting = settingsCtrl.formatCurrentLocaleToString();
      } else if (settingsCtrl.isLoading.value) {
        logger.w(
            "SettingsController is still loading, date formatting might use fallback or previously set Get.locale");
        localeForDateFormatting =
            Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'es_ES';
      }
    } else {
      final deviceLocale = Get.deviceLocale;
      if (deviceLocale != null) {
        localeForDateFormatting =
            deviceLocale.toLanguageTag().replaceAll('-', '_');
      }
    }

    await initializeDateFormatting(localeForDateFormatting, null);
    logger
        .i("Date formatting initialized for locale: $localeForDateFormatting");
  } catch (e, s) {
    logger.w(
        "Error initializing date formatting for specific locale: $e. Trying default.",
        error: e,
        stackTrace: s);
    try {
      await initializeDateFormatting();
      logger.i("Date formatting initialized with default system locale.");
    } catch (e2, s2) {
      logger.e("Fallback date formatting initialization also failed: $e2",
          error: e2, stackTrace: s2);
    }
  }

  // --- 4. Establecer orientación preferida y Estilo de UI del Sistema ---
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    logger.i("Preferred orientations set to portrait.");
  } catch (e, s) {
    logger.w("Error setting preferred orientations: $e",
        error: e, stackTrace: s);
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.systemNavBarColor,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // --- 5. Ejecutar la aplicación ---
  runApp(const KidsDoApp());
}

// Tu widget KidsDoApp (en app.dart) debería permanecer como está en el Canvas "app_dart_updated"
// usando SettingsController para el locale.
