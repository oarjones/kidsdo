import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//import 'package:get/get.dart';
import 'package:kidsdo/app.dart';
import 'package:kidsdo/firebase_options.dart';
import 'package:kidsdo/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializar inyección de dependencias
  await di.init();

  runApp(const KidsDoApp());
}
