import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Controladores, servicios y repositorios se registrarán aquí
Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  // External
  Get.lazyPut(() => FirebaseAuth.instance, fenix: true);
  Get.lazyPut(() => FirebaseFirestore.instance, fenix: true);
  Get.lazyPut(() => FirebaseStorage.instance, fenix: true);
  Get.lazyPut(() => sharedPreferences, fenix: true);

  // Repositories
  // Ejemplo: Get.lazyPut(() => AuthRepositoryImpl(firebaseAuth: Get.find(), firestore: Get.find()), fenix: true);

  // UseCases
  // Ejemplo: Get.lazyPut(() => SignInUseCase(repository: Get.find()), fenix: true);

  // Controllers
  // Ejemplo: Get.lazyPut(() => AuthController(signInUseCase: Get.find(), signUpUseCase: Get.find()), fenix: true);
}
