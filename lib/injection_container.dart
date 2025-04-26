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
import 'package:kidsdo/presentation/controllers/parental_control_controller.dart';
import 'package:kidsdo/presentation/controllers/profile_controller.dart';
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
import 'package:kidsdo/presentation/controllers/language_controller.dart';
import 'package:kidsdo/presentation/controllers/family_controller.dart';
import 'package:kidsdo/presentation/controllers/child_profile_controller.dart';
import 'package:kidsdo/presentation/controllers/child_access_controller.dart';

//Logging
import 'package:logger/logger.dart';

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();

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
  Get.put<Logger>(logger, permanent: true);

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

  Get.put<SharedPreferences>(sharedPreferences);

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

  // Controllers - Inicializar primero LanguageController
  Get.put<LanguageController>(
    LanguageController(
      sharedPreferences: Get.find<SharedPreferences>(),
    ),
    permanent: true, // Hacerlo permanente para que no se elimine de la memoria
  );

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
}
