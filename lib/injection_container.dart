import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

// DataSources
import 'package:kidsdo/data/datasources/remote/auth_remote_datasource.dart';
import 'package:kidsdo/data/datasources/remote/user_remote_datasource.dart';
import 'package:kidsdo/data/datasources/remote/family_remote_datasource.dart';

// Repositories
import 'package:kidsdo/data/repositories/auth_repository_impl.dart';
import 'package:kidsdo/data/repositories/user_repository_impl.dart';
import 'package:kidsdo/data/repositories/family_repository_impl.dart';
import 'package:kidsdo/domain/repositories/auth_repository.dart';
import 'package:kidsdo/domain/repositories/user_repository.dart';
import 'package:kidsdo/domain/repositories/family_repository.dart';

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  // External
  Get.lazyPut(() => FirebaseAuth.instance, fenix: true);
  Get.lazyPut(() => FirebaseFirestore.instance, fenix: true);
  Get.lazyPut(() => FirebaseStorage.instance, fenix: true);
  Get.lazyPut(() => GoogleSignIn(), fenix: true);
  Get.lazyPut(() => sharedPreferences, fenix: true);

  // DataSources
  Get.lazyPut<IAuthRemoteDataSource>(
    () => AuthRemoteDataSource(
      firebaseAuth: Get.find<FirebaseAuth>(),
      googleSignIn: Get.find<GoogleSignIn>(),
    ),
    fenix: true,
  );

  Get.lazyPut<IUserRemoteDataSource>(
    () => UserRemoteDataSource(
      firestore: Get.find<FirebaseFirestore>(),
    ),
    fenix: true,
  );

  Get.lazyPut<IFamilyRemoteDataSource>(
    () => FamilyRemoteDataSource(
      firestore: Get.find<FirebaseFirestore>(),
    ),
    fenix: true,
  );

  // Repositories
  Get.lazyPut<IAuthRepository>(
    () => AuthRepositoryImpl(
      authRemoteDataSource: Get.find<IAuthRemoteDataSource>(),
      userRemoteDataSource: Get.find<IUserRemoteDataSource>(),
    ),
    fenix: true,
  );

  Get.lazyPut<IUserRepository>(
    () => UserRepositoryImpl(
      userRemoteDataSource: Get.find<IUserRemoteDataSource>(),
    ),
    fenix: true,
  );

  Get.lazyPut<IFamilyRepository>(
    () => FamilyRepositoryImpl(
      familyRemoteDataSource: Get.find<IFamilyRemoteDataSource>(),
    ),
    fenix: true,
  );

  // UseCases
  // Se implementarán en sesiones futuras

  // Controllers
  // Se implementarán en sesiones futuras
}
