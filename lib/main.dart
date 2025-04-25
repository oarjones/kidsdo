import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kidsdo/app.dart';
import 'package:kidsdo/firebase_options.dart';
import 'package:kidsdo/injection_container.dart' as di;
import 'package:logger/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Logger? logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 8,
      lineLength: 90,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: Level.debug,
  );

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    // Configurar Firebase App Check
    await FirebaseAppCheck.instance.activate(
      // Para ambientes de desarrollo, usar estas opciones:
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
  } catch (e) {
    logger.d("Error al activar Firebase App Check: $e");
    // Continuar con la app aunque App Check falle
  }

  // Inicializar inyección de dependencias
  await di.init();

  // Establecer orientación preferida
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const KidsDoApp());
}
