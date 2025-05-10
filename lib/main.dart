import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kidsdo/app.dart';
import 'package:kidsdo/firebase_options.dart';
import 'package:kidsdo/injection_container.dart' as di;
import 'package:logger/logger.dart';
import 'package:intl/date_symbol_data_local.dart'; // Importante para formato de fechas
import 'package:get/get.dart'; // Para acceder a Get.locale

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuración del Logger
  Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 8,
      lineLength: 90,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: Level
        .debug, // Ajustar nivel según sea necesario (debug, info, warning, error)
  );

  // Inicializar Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    logger.i("Firebase initialized successfully.");
  } catch (e) {
    logger.e("Error initializing Firebase: $e");
    // Considerar si la app puede continuar sin Firebase o mostrar un error crítico.
  }

  // Configurar Firebase App Check
  try {
    await FirebaseAppCheck.instance.activate(
      // Para ambientes de desarrollo:
      androidProvider: AndroidProvider
          .debug, // Usar AndroidProvider.playIntegrity en producción
      appleProvider:
          AppleProvider.debug, // Usar AppleProvider.appAttest en producción
      // webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'), // Si se usa en web
    );
    logger.i("Firebase App Check activated.");
  } catch (e) {
    logger.w(
        "Error activating Firebase App Check: $e. App will continue without App Check.");
    // La app puede continuar, pero App Check no protegerá las llamadas a Firebase.
  }

  // Inicializar inyección de dependencias (GetIt o similar)
  try {
    await di.init();
    logger.i("Dependency injection initialized.");
  } catch (e) {
    logger.e("Error initializing dependency injection: $e");
    // Error crítico, la app podría no funcionar correctamente.
  }

  // Inicializar formato de fechas después de que GetX (y por ende Get.locale) esté disponible.
  // LanguageController usualmente se inicializa en di.init().
  try {
    // Obtener el locale actual de GetX si está disponible, si no, el del dispositivo.
    final String? initialLocale =
        Get.locale?.languageCode ?? Get.deviceLocale?.languageCode;
    if (initialLocale != null && initialLocale.isNotEmpty) {
      await initializeDateFormatting(initialLocale, null);
      logger.i("Date formatting initialized for locale: $initialLocale");
    } else {
      // Si no se puede determinar un locale específico, inicializar con el default del sistema.
      await initializeDateFormatting();
      logger.i("Date formatting initialized with default system locale.");
    }
  } catch (e) {
    logger.w(
        "Error initializing date formatting: $e. Date formats might use default locale.");
    // Intentar inicialización por defecto como fallback si la específica falla.
    try {
      await initializeDateFormatting();
    } catch (e2) {
      logger.e("Fallback date formatting initialization also failed: $e2");
    }
  }

  // Establecer orientación preferida
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    logger.i("Preferred orientations set to portrait.");
  } catch (e) {
    logger.w("Error setting preferred orientations: $e");
  }

  runApp(const KidsDoApp());
}
