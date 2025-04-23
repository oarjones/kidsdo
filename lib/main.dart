import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kidsdo/app.dart';
import 'package:kidsdo/firebase_options.dart';
import 'package:kidsdo/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Para depuración, imprime información importante
  print("Inicializando Firebase...");

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Imprimir las opciones de Firebase para depuración
  print("Firebase inicializado con las siguientes opciones:");
  print("API Key: ${DefaultFirebaseOptions.currentPlatform.apiKey}");
  print("App ID: ${DefaultFirebaseOptions.currentPlatform.appId}");
  print("Project ID: ${DefaultFirebaseOptions.currentPlatform.projectId}");
  print(
      "Messaging Sender ID: ${DefaultFirebaseOptions.currentPlatform.messagingSenderId}");

  try {
    // Configurar Firebase App Check
    await FirebaseAppCheck.instance.activate(
      // Para ambientes de desarrollo, usar estas opciones:
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );

    print("Firebase App Check configurado para entorno de desarrollo");
  } catch (e) {
    print("Error al activar Firebase App Check: $e");
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
