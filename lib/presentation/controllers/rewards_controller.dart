import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/data/predefined_rewards.dart';
import 'package:kidsdo/core/errors/failures.dart';
import 'package:kidsdo/core/translations/app_translations.dart'; // Para mensajes de error
import 'package:kidsdo/domain/entities/reward.dart';
import 'package:kidsdo/domain/repositories/family_child_repository.dart';
import 'package:kidsdo/domain/repositories/reward_repository.dart';
import 'package:kidsdo/presentation/controllers/child_profile_controller.dart';
import 'package:kidsdo/presentation/controllers/session_controller.dart';
import 'package:logger/logger.dart';
import 'dart:async'; // Para StreamSubscription

// Estados para las operaciones del controlador
enum RewardOperationStatus {
  initial,
  loading,
  success,
  error,
}

class RewardsController extends GetxController {
  final IRewardRepository _rewardRepository;
  final IFamilyChildRepository _familyChildRepository;
  final SessionController _sessionController;
  final Logger _logger;

  // Observables para la lista de recompensas
  final RxList<Reward> rewardsList = <Reward>[].obs;
  final Rx<RewardOperationStatus> rewardsListStatus =
      RewardOperationStatus.initial.obs;
  final RxString rewardsListError = ''.obs;
  StreamSubscription? _rewardsSubscription;

  // Observables para operaciones CRUD individuales
  final Rx<RewardOperationStatus> rewardActionStatus =
      RewardOperationStatus.initial.obs;
  final RxString rewardActionError = ''.obs;

  // Observables para el ajuste de puntos
  final Rx<RewardOperationStatus> pointsAdjustmentStatus =
      RewardOperationStatus.initial.obs;
  final RxString pointsAdjustmentError = ''.obs;

  //Recompensas predefinidas
  final RxList<Reward> predefinedRewards = <Reward>[].obs;
  final Rx<RewardOperationStatus> predefinedRewardsStatus =
      RewardOperationStatus.initial.obs;
  final RxString predefinedRewardsError = ''.obs;

  RewardsController({
    required IRewardRepository rewardRepository,
    required IFamilyChildRepository familyChildRepository,
    required SessionController sessionController,
    required Logger logger,
  })  : _rewardRepository = rewardRepository,
        _familyChildRepository = familyChildRepository,
        _sessionController = sessionController,
        _logger = logger;

  @override
  void onInit() {
    super.onInit();
    // Cargar las recompensas de la familia actual cuando el controlador se inicializa
    // y el usuario (padre/madre) tiene una familia asignada.
    // Escuchar cambios en el currentUser para reaccionar si cambia la familia.

    loadPredefinedRewardsToFirestoreIfNeeded();

    ever(_sessionController.currentUser, (parent) {
      if (parent?.familyId != null) {
        fetchRewards(parent!.familyId!);
      } else {
        rewardsList.clear();
        _rewardsSubscription?.cancel();
      }
    });

    // Carga inicial si ya hay un usuario con familyId
    final initialFamilyId = _sessionController.currentUser.value?.familyId;
    if (initialFamilyId != null) {
      fetchRewards(initialFamilyId);
    }
  }

  @override
  void onClose() {
    _rewardsSubscription?.cancel();
    super.onClose();
  }

  // En algún lugar, por ejemplo, al inicializar la app o en un panel de admin/settings
  Future<void> loadPredefinedRewardsToFirestoreIfNeeded() async {
    await fetchPredefinedRewards();
    final firestore = Get.find<FirebaseFirestore>();
    final logger = Get.find<Logger>();
    final predefinedRewardsCollection =
        firestore.collection('predefined_rewards');

    // Podrías tener una versión en SharedPreferences o un documento de 'metadata'
    // para saber si ya se cargaron o si hay una nueva versión.
    // Por simplicidad, verificaremos si la colección está vacía.
    final snapshot = await predefinedRewardsCollection.limit(1).get();

    if (snapshot.docs.isEmpty) {
      logger.i('No predefined rewards found in Firestore. Loading them now...');
      final WriteBatch batch = firestore.batch();

      for (final PredefinedReward predefinedReward in predefinedRewardsList) {
        final DocumentReference docRef = predefinedRewardsCollection
            .doc(predefinedReward.id); // Usa el ID de la plantilla

        // Construye el mapa de datos para Firestore
        // Aquí predefinedRewardItem ES de tipo PredefinedReward
        final Map<String, dynamic> dataToSet = {
          // Guarda cada idioma como un campo separado para facilitar las consultas si es necesario
          // o guarda el mapa directamente si prefieres (ej: 'name': predefinedRewardItem.name)
          // Para este ejemplo, guardaremos los campos específicos de idioma.
          'name_es': predefinedReward.name['es'],
          'name_en': predefinedReward.name['en'],
          // Manejo opcional de descripciones
          if (predefinedReward.description?['es'] != null)
            'description_es': predefinedReward.description!['es'],
          if (predefinedReward.description?['en'] != null)
            'description_en': predefinedReward.description!['en'],
          'pointsRequired': predefinedReward.pointsRequired,
          'type': rewardTypeToString(
              predefinedReward.type), // Usa el enum de reward.dart
          'icon': predefinedReward.icon,
          'typeSpecificData':
              predefinedReward.typeSpecificData, // Puede ser null
          'isUnique': predefinedReward.isUnique,
          'category': predefinedRewardCategoryToString(predefinedReward
              .category), // Usa el enum de predefined_rewards.dart
          // No se guarda familyId ni createdBy aquí, son plantillas globales.
        };
        batch.set(docRef, dataToSet);
      }

      try {
        await batch.commit();
        logger.i(
            'Successfully loaded ${predefinedRewardsList.length} predefined rewards to Firestore.');
      } catch (e) {
        logger.e('Error loading predefined rewards to Firestore: $e');
      }
    } else {
      logger.i(
          'Predefined rewards already exist in Firestore or check logic needs refinement.');
    }
  }

  /// Obtiene las recompensas predefinidas de la base de datos.
  Future<void> fetchPredefinedRewards({String? category}) async {
    _logger.i('Fetching predefined rewards. Category: $category');
    predefinedRewardsStatus.value = RewardOperationStatus.loading;
    predefinedRewardsError.value = '';

    final result =
        await _rewardRepository.getPredefinedRewards(category: category);
    result.fold(
      (failure) {
        _logger.e('Error fetching predefined rewards: ${failure.message}');
        predefinedRewardsError.value = _mapFailureToMessage(failure);
        predefinedRewardsStatus.value = RewardOperationStatus.error;
      },
      (rewards) {
        _logger.i('Predefined rewards fetched successfully: ${rewards.length}');
        predefinedRewards.assignAll(rewards);
        predefinedRewardsStatus.value = RewardOperationStatus.success;
      },
    );
  }

  /// Obtiene las recompensas de la familia y se suscribe a los cambios.
  void fetchRewards(String familyId) {
    _logger.i('Fetching rewards for family: $familyId');
    rewardsListStatus.value = RewardOperationStatus.loading;
    rewardsListError.value = '';
    _rewardsSubscription?.cancel(); // Cancelar suscripción anterior si existe

    _rewardsSubscription = _rewardRepository.getRewardsStream(familyId).listen(
      (eitherResult) {
        eitherResult.fold(
          (failure) {
            _logger.e('Error fetching rewards: ${failure.message}');
            rewardsListError.value = _mapFailureToMessage(failure);
            rewardsListStatus.value = RewardOperationStatus.error;
            rewardsList
                .clear(); // Limpiar en caso de error para no mostrar datos viejos
          },
          (rewards) {
            _logger.i('Rewards fetched successfully: ${rewards.length}');
            rewardsList.assignAll(rewards);
            rewardsListStatus.value = RewardOperationStatus.success;
          },
        );
      },
      onError: (error) {
        // Este es el manejo de error del stream que mencionaste
        _logger.e('Stream error in fetchRewards: $error');
        rewardsListError.value =
            TrKeys.streamGenericError.tr; // Necesitarás esta key de traducción
        rewardsListStatus.value = RewardOperationStatus.error;
        rewardsList.clear();
      },
    );
  }

  /// Crea una nueva recompensa.
  Future<void> createReward({
    required String name,
    String? description,
    required int pointsRequired,
    required RewardType type,
    String? icon,
    Map<String, dynamic>? typeSpecificData,
    bool isUnique = false,
    bool isEnabled = true,
  }) async {
    _logger.i('Attempting to create reward: $name');
    rewardActionStatus.value = RewardOperationStatus.loading;
    rewardActionError.value = '';

    final parent = _sessionController.currentUser.value;
    if (parent == null || parent.familyId == null) {
      _logger.w('Cannot create reward: User not logged in or no familyId.');
      rewardActionError.value = TrKeys
          .userNotAuthenticatedError.tr; // Necesitarás esta key de traducción
      rewardActionStatus.value = RewardOperationStatus.error;
      return;
    }

    // El ID, familyId, createdBy, createdAt, updatedAt se asignarán en el repositorio.
    // Aquí solo pasamos los datos que el padre introduce.
    final newReward = Reward(
      id: '', // El repositorio generará esto
      familyId: '', // El repositorio asignará esto
      name: name,
      description: description,
      pointsRequired: pointsRequired,
      type: type,
      icon: icon,
      createdAt: DateTime.now(), // Provisional, el repo lo sobrescribirá
      updatedAt: DateTime.now(), // Provisional, el repo lo sobrescribirá
      createdBy: '', // El repositorio asignará esto
      status: RewardStatus.available, // Por defecto
      typeSpecificData: typeSpecificData,
      isUnique: isUnique,
      isEnabled: isEnabled,
    );

    final result = await _rewardRepository.createReward(newReward);
    result.fold(
      (failure) {
        _logger.e('Failed to create reward: ${failure.message}');
        rewardActionError.value = _mapFailureToMessage(failure);
        rewardActionStatus.value = RewardOperationStatus.error;
      },
      (createdReward) {
        _logger.i('Reward created successfully: ${createdReward.id}');
        rewardActionStatus.value = RewardOperationStatus.success;
        // No es necesario añadir a rewardsList manualmente si el stream ya lo hace.
        // Si no, se podría añadir: rewardsList.add(createdReward);
        Get.back(); // Asumiendo que la creación se hace en un diálogo/nueva página
      },
    );
  }

  /// Actualiza una recompensa existente.
  Future<void> updateReward(Reward rewardToUpdate) async {
    _logger.i('Attempting to update reward: ${rewardToUpdate.id}');
    rewardActionStatus.value = RewardOperationStatus.loading;
    rewardActionError.value = '';

    final result = await _rewardRepository.updateReward(rewardToUpdate);
    result.fold(
      (failure) {
        _logger.e('Failed to update reward: ${failure.message}');
        rewardActionError.value = _mapFailureToMessage(failure);
        rewardActionStatus.value = RewardOperationStatus.error;
      },
      (updatedReward) {
        _logger.i('Reward updated successfully: ${updatedReward.id}');
        rewardActionStatus.value = RewardOperationStatus.success;
        // El stream debería actualizar la lista automáticamente.
        // Si no, encontrar y reemplazar:
        // final index = rewardsList.indexWhere((r) => r.id == updatedReward.id);
        // if (index != -1) {
        //   rewardsList[index] = updatedReward;
        // }
        Get.back(); // Asumiendo que la edición se hace en un diálogo/nueva página
      },
    );
  }

  /// Elimina una recompensa.
  Future<void> deleteReward(String rewardId) async {
    _logger.i('Attempting to delete reward: $rewardId');
    rewardActionStatus.value = RewardOperationStatus.loading;
    rewardActionError.value = '';

    final familyId = _sessionController.currentUser.value?.familyId;
    if (familyId == null) {
      _logger.w('Cannot delete reward: familyId is null.');
      rewardActionError.value = TrKeys.userNotAuthenticatedError.tr;
      rewardActionStatus.value = RewardOperationStatus.error;
      return;
    }

    final result = await _rewardRepository.deleteReward(
        familyId: familyId, rewardId: rewardId);
    result.fold(
      (failure) {
        _logger.e('Failed to delete reward: ${failure.message}');
        rewardActionError.value = _mapFailureToMessage(failure);
        rewardActionStatus.value = RewardOperationStatus.error;
      },
      (_) {
        _logger.i('Reward deleted successfully: $rewardId');
        rewardActionStatus.value = RewardOperationStatus.success;
        // El stream debería actualizar la lista automáticamente.
        // Si no: rewardsList.removeWhere((r) => r.id == rewardId);
      },
    );
  }

  /// Ajusta manualmente los puntos de un niño.
  Future<void> adjustChildPointsManually({
    required String childId,
    required int pointsToAdjust,
    required String childName, // Para mensajes de feedback
  }) async {
    _logger
        .i('Attempting to adjust points for child $childId by $pointsToAdjust');
    pointsAdjustmentStatus.value = RewardOperationStatus.loading;
    pointsAdjustmentError.value = '';

    final eitherChild = await _familyChildRepository.getChildById(childId);

    await eitherChild.fold(
      (failure) async {
        _logger.e(
            'Failed to get child $childId for points adjustment: ${failure.message}');
        pointsAdjustmentError.value = _mapFailureToMessage(failure);
        pointsAdjustmentStatus.value = RewardOperationStatus.error;
      },
      (child) async {
        int newTotalPoints = child.points + pointsToAdjust;

        if (newTotalPoints < 0) {
          // Según rewards.md: "Los puntos de un niño no pueden ser negativos."
          // Si el ajuste los haría negativos, se establece a 0.
          newTotalPoints = 0;
          _logger.w(
              'Points adjustment for child $childId resulted in negative value. Setting points to 0.');
        }

        final result = await _familyChildRepository.updateChildPoints(
            childId, newTotalPoints);
        result.fold(
          (failure) {
            _logger.e(
                'Failed to adjust points for child $childId: ${failure.message}');
            pointsAdjustmentError.value = _mapFailureToMessage(failure);
            pointsAdjustmentStatus.value = RewardOperationStatus.error;
          },
          (_) {
            _logger.i(
                'Points for child $childId adjusted successfully to $newTotalPoints');
            pointsAdjustmentStatus.value = RewardOperationStatus.success;

            // Actualizar la información del niño en ChildProfileController si es necesario
            // para que la UI refleje el cambio de puntos inmediatamente en otros lugares.
            final childProfileController = Get.find<ChildProfileController>();
            // 'child' aquí es el FamilyChild que obtuvimos antes de la actualización de puntos
            childProfileController.updateChildProfileLocally(
                child.copyWith(points: newTotalPoints));

            Get.snackbar(
              TrKeys.pointsAdjustedTitle.tr, // "Puntos Ajustados"
              TrKeys.pointsAdjustedMessage.trParams({
                // "Los puntos de @childName ahora son @points."
                'childName': childName,
                'points': newTotalPoints.toString(),
              }),
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        );
      },
    );
  }

  /// Método auxiliar para mapear errores a mensajes.
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message.isNotEmpty
          ? failure.message
          : TrKeys.serverErrorMessage.tr;
    } else if (failure is AuthFailure) {
      return failure.message.isNotEmpty
          ? failure.message
          : TrKeys.authGenericError.tr;
    } else if (failure is NetworkFailure) {
      return TrKeys.connectionErrorMessage.tr;
    }
    return TrKeys.unexpectedErrorMessage.tr;
  }

  /// Limpia los errores de acción para permitir reintentos o nuevas operaciones.
  void clearActionStatus() {
    rewardActionStatus.value = RewardOperationStatus.initial;
    rewardActionError.value = '';
  }

  void clearPointsAdjustmentStatus() {
    pointsAdjustmentStatus.value = RewardOperationStatus.initial;
    pointsAdjustmentError.value = '';
  }
}
