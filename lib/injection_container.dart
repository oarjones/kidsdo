import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kidsdo/data/datasources/remote/challenge_remote_datasource.dart';
import 'package:kidsdo/data/repositories/challenge_repository_impl.dart';
import 'package:kidsdo/domain/repositories/challenge_repository.dart';
import 'package:kidsdo/presentation/controllers/challenge_controller.dart';
import 'package:kidsdo/presentation/controllers/child_challenges_controller.dart';
import 'package:kidsdo/presentation/controllers/main_navigation_controller.dart';
import 'package:kidsdo/presentation/controllers/parental_control_controller.dart';
import 'package:kidsdo/presentation/controllers/profile_controller.dart';
import 'package:kidsdo/presentation/controllers/rewards_controller.dart';
import 'package:kidsdo/presentation/controllers/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

// DataSources
import 'package:kidsdo/data/datasources/remote/auth_remote_datasource.dart';
import 'package:kidsdo/data/datasources/remote/user_remote_datasource.dart';
import 'package:kidsdo/data/datasources/remote/family_remote_datasource.dart';
import 'package:kidsdo/data/datasources/remote/family_child_remote_datasource.dart';

// Repositories
import 'package:kidsdo/data/repositories/auth_repository_impl.dart';
import 'package:kidsdo/data/repositories/user_repository_impl.dart';
import 'package:kidsdo/data/repositories/family_repository_impl.dart';
import 'package:kidsdo/data/repositories/family_child_repository_impl.dart';
import 'package:kidsdo/domain/repositories/auth_repository.dart';
import 'package:kidsdo/domain/repositories/user_repository.dart';
import 'package:kidsdo/domain/repositories/family_repository.dart';
import 'package:kidsdo/domain/repositories/family_child_repository.dart';

// Controllers
import 'package:kidsdo/presentation/controllers/session_controller.dart';
import 'package:kidsdo/presentation/controllers/auth_controller.dart';
import 'package:kidsdo/presentation/controllers/family_controller.dart';
import 'package:kidsdo/presentation/controllers/child_profile_controller.dart';
import 'package:kidsdo/presentation/controllers/child_access_controller.dart';

import 'package:kidsdo/data/datasources/remote/reward_remote_datasource.dart';
import 'package:kidsdo/data/repositories/reward_repository_impl.dart';
import 'package:kidsdo/domain/repositories/reward_repository.dart';
import 'package:uuid/uuid.dart'; // Asegúrate de tener esta dependencia en pubspec.yaml

//Logging
import 'package:logger/logger.dart';

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  if (!Get.isRegistered<SharedPreferences>()) {
    Get.put<SharedPreferences>(sharedPreferences, permanent: true);
  }

  // --- Logger ---
  // Crea y configura tu instancia de Logger aquí
  final logger = Logger(
    printer: PrettyPrinter(
        methodCount:
            1, // Número de métodos a mostrar en stacktrace (útil para saber quién llama)
        errorMethodCount: 8, // Más detalle para errores
        lineLength: 90, // Ancho de línea
        colors: true, // Colores
        printEmojis: true, // Emojis para niveles
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart),
    level: kReleaseMode
        ? Level.warning
        : Level.debug, // Ejemplo: Menos logs en release
  );

  // Registra la instancia del logger como un singleton permanente
  if (!Get.isRegistered<Logger>()) {
    Get.put<Logger>(logger, permanent: true);
  }

  if (!Get.isRegistered<Uuid>()) {
    Get.lazyPut<Uuid>(() => const Uuid(), fenix: true);
  }

  // External
  Get.lazyPut(() => FirebaseAuth.instance, fenix: true);
  Get.lazyPut(() => FirebaseFirestore.instance, fenix: true);
  Get.lazyPut(() => FirebaseStorage.instance, fenix: true);
  Get.lazyPut<ImagePicker>(() => ImagePicker(), fenix: true);

  // Configuración específica para GoogleSignIn
  Get.lazyPut(
      () => GoogleSignIn(
            // En desarrollo, no uses scopes o usa los mínimos necesarios
            scopes: [
              'email',
              'profile',
            ],
            // Usa 'serverClientId' si estás configurando OAuth para backend
            // serverClientId: 'tu-client-id-web.apps.googleusercontent.com',
          ),
      fenix: true);

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

  Get.lazyPut<IFamilyChildRemoteDataSource>(
    () => FamilyChildRemoteDataSource(
      firestore: Get.find<FirebaseFirestore>(),
    ),
    fenix: true,
  );

  Get.lazyPut<IChallengeRemoteDataSource>(
    () => ChallengeRemoteDataSource(
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
      firebaseAuth: Get.find<FirebaseAuth>(),
    ),
    fenix: true,
  );

  Get.lazyPut<IFamilyRepository>(
    () => FamilyRepositoryImpl(
      familyRemoteDataSource: Get.find<IFamilyRemoteDataSource>(),
    ),
    fenix: true,
  );

  Get.lazyPut<IFamilyChildRepository>(
    () => FamilyChildRepositoryImpl(
      familyChildRemoteDataSource: Get.find<IFamilyChildRemoteDataSource>(),
    ),
    fenix: true,
  );

  Get.lazyPut<IChallengeRepository>(
    () => ChallengeRepositoryImpl(
      challengeRemoteDataSource: Get.find<IChallengeRemoteDataSource>(),
    ),
    fenix: true,
  );

  // --- SettingsController ---
  // (Debe registrarse ANTES que cualquier controlador que dependa del idioma cargado por él,
  // o si esos controladores acceden a él en su `onInit`)
  if (!Get.isRegistered<SettingsController>()) {
    Get.put<SettingsController>(
      SettingsController(sharedPreferences: Get.find<SharedPreferences>()),
      permanent: true,
    );
    // La carga inicial de settings (loadInitialSettings) se llamará desde main.dart
    // después de di.init() para asegurar que todas las dependencias estén listas.
  }

  // Resto de controladores
  Get.put<SessionController>(
    SessionController(
      authRepository: Get.find<IAuthRepository>(),
      sharedPreferences: Get.find<SharedPreferences>(),
    ),
  );

  Get.put<AuthController>(AuthController(
    authRepository: Get.find<IAuthRepository>(),
    sessionController: Get.find<SessionController>(),
  ));

  // Controlador de perfil
  Get.put<ProfileController>(
    ProfileController(
      userRepository: Get.find<IUserRepository>(),
      sessionController: Get.find<SessionController>(),
      storage: Get.find<FirebaseStorage>(),
      imagePicker: Get.find<ImagePicker>(),
      logger: Get.find<Logger>(),
    ),
  );

  // Family controller
  Get.put<FamilyController>(
    FamilyController(
      familyRepository: Get.find<IFamilyRepository>(),
      userRepository: Get.find<IUserRepository>(),
      sessionController: Get.find<SessionController>(),
      logger: Get.find<Logger>(),
    ),
  );

  // ChildProfileController controller
  Get.put<ChildProfileController>(
    ChildProfileController(
      familyChildRepository: Get.find<IFamilyChildRepository>(),
      sessionController: Get.find<SessionController>(),
      familyController: Get.find<FamilyController>(),
      storage: Get.find<FirebaseStorage>(),
      imagePicker: Get.find<ImagePicker>(),
      logger: Get.find<Logger>(),
    ),
  );

  // ParentalControlController controller
  Get.put<ParentalControlController>(
    ParentalControlController(
      sharedPreferences: Get.find<SharedPreferences>(),
      logger: Get.find<Logger>(),
    ),
    permanent: true,
  );

  // ChildAccessController controller
  Get.put<ChildAccessController>(
    ChildAccessController(
      familyChildRepository: Get.find<IFamilyChildRepository>(),
      parentalControlController: Get.find<ParentalControlController>(),
      familyController: Get.find<FamilyController>(),
      sharedPreferences: Get.find<SharedPreferences>(),
      logger: Get.find<Logger>(),
    ),
  );

  Get.put<ChallengeController>(
    ChallengeController(
      challengeRepository: Get.find<IChallengeRepository>(),
      sessionController: Get.find<SessionController>(),
      logger: logger,
    ),
  );

  Get.put<ChildChallengesController>(
    ChildChallengesController(
      challengeRepository: Get.find<IChallengeRepository>(),
      childAccessController: Get.find<ChildAccessController>(),
      logger: Get.find<Logger>(),
    ),
  );

  // Rewards Feature
  // Datasource
  Get.lazyPut<IRewardRemoteDataSource>(
    () => RewardRemoteDataSourceImpl(
      firestore:
          Get.find<FirebaseFirestore>(), // Ya deberías tenerlo registrado
      logger: Get.find<Logger>(),
      uuid: Get.find<Uuid>(),
    ),
    fenix: true,
  );

  // Repository
  Get.lazyPut<IRewardRepository>(
    () => RewardRepositoryImpl(
      remoteDataSource: Get.find<IRewardRemoteDataSource>(),
      sessionController: Get.find<SessionController>(), // Ya registrado
      uuid: Get.find<Uuid>(),
      logger: Get.find<Logger>(), // Ya registrado
    ),
    fenix: true,
  );

  Get.lazyPut<RewardsController>(
    () => RewardsController(
      rewardRepository: Get.find<IRewardRepository>(),
      familyChildRepository: Get.find<IFamilyChildRepository>(),
      sessionController: Get.find<SessionController>(),
      logger: Get.find<Logger>(),
    ),
    fenix:
        true, // Para que se recree si se elimina, o false si quieres que persista más
  );

  Get.lazyPut<MainNavigationController>(
    () => MainNavigationController(),
    fenix:
        true, // Para que se recree si es necesario, o false si quieres que persista más
  );

  // RewardsController (se registrará cuando lo creemos)
  // Get.lazyPut<RewardsController>(() => RewardsController(
  //   rewardRepository: Get.find<IRewardRepository>(),
  //   familyChildRepository: Get.find<IFamilyChildRepository>(),
  //   sessionController: Get.find<SessionController>(),
  //   logger: Get.find<Logger>(),
  // ));
}
