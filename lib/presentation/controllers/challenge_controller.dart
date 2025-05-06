import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/data/predefined_challenges.dart';
import 'package:kidsdo/core/errors/failures.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/data/datasources/remote/challenge_remote_datasource.dart';
import 'package:kidsdo/data/models/challenge_model.dart';
import 'package:kidsdo/domain/entities/challenge.dart';
import 'package:kidsdo/domain/entities/assigned_challenge.dart';
import 'package:kidsdo/domain/entities/challenge_execution.dart';
import 'package:kidsdo/domain/repositories/challenge_repository.dart';
import 'package:kidsdo/presentation/controllers/session_controller.dart';
import 'package:logger/logger.dart';

enum ChallengeStatus {
  initial,
  loading,
  success,
  error,
}

/// Controlador para la gestión de retos
class ChallengeController extends GetxController {
  final IChallengeRepository _challengeRepository;
  final SessionController _sessionController;
  final Logger _logger;

  // Observable state
  final Rx<ChallengeStatus> status =
      Rx<ChallengeStatus>(ChallengeStatus.initial);
  final RxString errorMessage = RxString('');

  // Challenges
  final RxList<Challenge> familyChallenges = RxList<Challenge>([]);
  final RxList<Challenge> predefinedChallenges = RxList<Challenge>([]);
  final Rx<Challenge?> selectedChallenge = Rx<Challenge?>(null);

  // Assigned challenges
  final RxList<AssignedChallenge> assignedChallenges =
      RxList<AssignedChallenge>([]);
  final Rx<AssignedChallenge?> selectedAssignedChallenge =
      Rx<AssignedChallenge?>(null);

  // Estados de carga
  final RxBool isLoadingFamilyChallenges = RxBool(false);
  final RxBool isLoadingPredefinedChallenges = RxBool(false);
  final RxBool isCreatingChallenge = RxBool(false);
  final RxBool isUpdatingChallenge = RxBool(false);
  final RxBool isDeletingChallenge = RxBool(false);
  final RxBool isAssigningChallenge = RxBool(false);
  final RxBool isLoadingAssignedChallenges = RxBool(false);
  final RxBool isEvaluatingChallenge = RxBool(false);
  final RxBool isCreatingNextExecution = RxBool(false);

  // Form controllers
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController pointsController;

  // Campos seleccionables
  final Rx<ChallengeCategory> selectedCategory =
      Rx<ChallengeCategory>(ChallengeCategory.hygiene);
  final Rx<ChallengeDuration> selectedDuration =
      Rx<ChallengeDuration>(ChallengeDuration.weekly);
  final RxMap<String, dynamic> selectedAgeRange =
      RxMap<String, dynamic>({'min': 3, 'max': 12});
  final RxBool isTemplateChallenge = RxBool(false);
  final RxString selectedIcon = RxString('');

  // Campos para asignación
  final Rx<DateTime> startDate = Rx<DateTime>(DateTime.now());
  final Rx<DateTime> endDate =
      Rx<DateTime>(DateTime.now().add(const Duration(days: 7)));
  final RxBool isContinuousChallenge = RxBool(false);
  final RxString selectedEvaluationFrequency = RxString('daily');
  final RxString selectedChildId = RxString('');

  // Filtrado y búsqueda para biblioteca de retos
  final RxList<Challenge> filteredChallenges = RxList<Challenge>([]);
  final RxString searchQuery = RxString('');
  final Rx<ChallengeCategory?> filterCategory = Rx<ChallengeCategory?>(null);
  final RxInt filterMinAge = RxInt(0);
  final RxInt filterMaxAge = RxInt(18);
  final RxBool showOnlyAgeAppropriate = RxBool(false);
  final Rx<ChallengeDuration?> filterDuration = Rx<ChallengeDuration?>(null);
  final TextEditingController searchController = TextEditingController();

  // Para la adaptación de dificultad por edad
  final RxInt selectedChildAge = RxInt(5); // Valor predeterminado
  final RxList<String> selectedChallengeIds = RxList<String>([]);

  // Importación y exportación
  final RxBool isImporting = RxBool(false);
  final RxBool isExporting = RxBool(false);

  final RxBool useLocalChallenges = RxBool(false);
  final RxString dataSource = RxString('loading');

  ChallengeController({
    required IChallengeRepository challengeRepository,
    required SessionController sessionController,
    Logger? logger,
  })  : _challengeRepository = challengeRepository,
        _sessionController = sessionController,
        _logger = logger ?? Get.find<Logger>();

  /// Método que se llamará cuando cambie el idioma
  void onLanguageChanged() {
    _updateChallengeTranslations();
  }

  /// Actualiza las traducciones de los retos cuando cambia el idioma
  void _updateChallengeTranslations() {
    // Actualizar los retos predefinidos
    for (int i = 0; i < predefinedChallenges.length; i++) {
      final challenge = predefinedChallenges[i];
      if (challenge is ChallengeModel && challenge.titleKey != null) {
        // Crear una copia actualizada del reto con las traducciones actualizadas
        final updatedChallenge = ChallengeModel(
            id: challenge.id,
            title: challenge.titleKey!.tr,
            description: challenge.descriptionKey?.tr ?? challenge.description,
            category: challenge.category,
            points: challenge.points,
            ageRange: challenge.ageRange,
            isTemplate: challenge.isTemplate,
            createdBy: challenge.createdBy,
            createdAt: challenge.createdAt,
            familyId: challenge.familyId,
            icon: challenge.icon,
            titleKey: challenge.titleKey,
            descriptionKey: challenge.descriptionKey,
            duration: ChallengeDuration.weekly);

        // Reemplazar el reto en la lista
        predefinedChallenges[i] = updatedChallenge;
      }
    }

    // Actualizar los retos filtrados
    applyFilters();

    // Actualizar el reto seleccionado si existe
    if (selectedChallenge.value != null &&
        selectedChallenge.value is ChallengeModel &&
        (selectedChallenge.value as ChallengeModel).titleKey != null) {
      final selectedChallengeModel = selectedChallenge.value as ChallengeModel;
      selectedChallenge.value = ChallengeModel(
          id: selectedChallengeModel.id,
          title: selectedChallengeModel.titleKey!.tr,
          description: selectedChallengeModel.descriptionKey?.tr ??
              selectedChallengeModel.description,
          category: selectedChallengeModel.category,
          points: selectedChallengeModel.points,
          ageRange: selectedChallengeModel.ageRange,
          isTemplate: selectedChallengeModel.isTemplate,
          createdBy: selectedChallengeModel.createdBy,
          createdAt: selectedChallengeModel.createdAt,
          familyId: selectedChallengeModel.familyId,
          icon: selectedChallengeModel.icon,
          titleKey: selectedChallengeModel.titleKey,
          descriptionKey: selectedChallengeModel.descriptionKey,
          duration: ChallengeDuration.weekly);
    }
  }

  @override
  void onInit() {
    super.onInit();

    IChallengeRemoteDataSource challengeDataSource =
        ChallengeRemoteDataSource(firestore: Get.find<FirebaseFirestore>());
    Get.put<IChallengeRemoteDataSource>(challengeDataSource);

    _initializeControllers();

    // Inicializar filteredChallenges con todos los retos predefinidos
    ever(predefinedChallenges, (_) {
      applyFilters();
    });

    // Añadir listener al controlador de búsqueda
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      applyFilters();
    });

    // Listen for changes in the session user
    ever(_sessionController.currentUser, (user) {
      if (user != null && user.familyId != null) {
        loadFamilyChallenges(user.familyId!);
      } else {
        // Clear challenges when user logs out or has no family
        familyChallenges.clear();
        assignedChallenges.clear();
      }
    });

    // Load predefined challenges on init
    loadPredefinedChallenges();

    // Initial load if user is already logged in with a family
    final currentUser = _sessionController.currentUser.value;
    if (currentUser != null && currentUser.familyId != null) {
      loadFamilyChallenges(currentUser.familyId!);
    }

    // Inicializar filtros
    initializeFilters();

    _logger.i("ChallengeController initialized");
  }

  void _initializeControllers() {
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    pointsController = TextEditingController(text: '10');

    // Add listeners to clear error message when typing
    titleController.addListener(_clearErrorOnChange);
    descriptionController.addListener(_clearErrorOnChange);
    pointsController.addListener(_clearErrorOnChange);

    _logger.d("Text controllers initialized");
  }

  @override
  void onClose() {
    _disposeControllers();
    searchController.dispose(); // Añadir esta línea
    _logger.i("ChallengeController closed");
    super.onClose();
  }

  void _disposeControllers() {
    titleController.removeListener(_clearErrorOnChange);
    descriptionController.removeListener(_clearErrorOnChange);
    pointsController.removeListener(_clearErrorOnChange);

    titleController.dispose();
    descriptionController.dispose();
    pointsController.dispose();

    _logger.d("Text controllers disposed");
  }

  void _clearErrorOnChange() {
    if (errorMessage.isNotEmpty) {
      errorMessage.value = '';
    }
  }

  /// Carga los retos de una familia específica
  Future<void> loadFamilyChallenges(String familyId) async {
    isLoadingFamilyChallenges.value = true;
    errorMessage.value = '';

    _logger.i("Loading family challenges for family: $familyId");
    final result = await _challengeRepository.getChallengesByFamily(familyId);

    result.fold(
      (failure) {
        status.value = ChallengeStatus.error;
        errorMessage.value = _mapFailureToMessage(failure);
        isLoadingFamilyChallenges.value = false;
        _logger.e("Error loading family challenges: ${failure.message}");
      },
      (challenges) {
        familyChallenges.assignAll(challenges);
        status.value = ChallengeStatus.success;
        isLoadingFamilyChallenges.value = false;
        _logger
            .i("Family challenges loaded successfully: ${challenges.length}");
      },
    );
  }

  DateTime calculateEndDate({
    required DateTime startDate,
    required ChallengeDuration duration,
  }) {
    switch (duration) {
      case ChallengeDuration.weekly:
        // Última fecha del período semanal (domingo)
        final int daysUntilSunday = 7 - startDate.weekday;
        return startDate
            .add(Duration(days: daysUntilSunday == 7 ? 0 : daysUntilSunday));

      case ChallengeDuration.monthly:
        // Último día del mes
        final nextMonth = startDate.month < 12
            ? DateTime(startDate.year, startDate.month + 1, 1)
            : DateTime(startDate.year + 1, 1, 1);
        return nextMonth.subtract(const Duration(days: 1));

      case ChallengeDuration.quarterly:
        // Último día del trimestre actual
        final int currentQuarter = (startDate.month - 1) ~/ 3;
        final int lastMonthOfQuarter = (currentQuarter + 1) * 3;
        final nextQuarter = lastMonthOfQuarter < 12
            ? DateTime(startDate.year, lastMonthOfQuarter + 1, 1)
            : DateTime(startDate.year + 1, 1, 1);
        return nextQuarter.subtract(const Duration(days: 1));

      case ChallengeDuration.yearly:
        // Último día del año
        return DateTime(startDate.year, 12, 31);

      case ChallengeDuration.punctual:
        // Por defecto, agregar una semana para retos puntuales
        return startDate.add(const Duration(days: 7));
    }
  }

  /// Carga los retos predefinidos
  Future<void> loadPredefinedChallenges() async {
    isLoadingPredefinedChallenges.value = true;
    errorMessage.value = '';
    dataSource.value = 'loading';

    _logger.i("Loading predefined challenges");

    try {
      // Intenta cargar desde Firestore primero
      final result = await _challengeRepository.getPredefinedChallenges();

      result.fold(
        (failure) {
          _logger.w(
              "Error loading from Firestore: ${failure.message}. Using local fallback.");
          _loadLocalPredefinedChallenges();
          dataSource.value = 'local';
          status.value = ChallengeStatus.success;
        },
        (challenges) {
          if (challenges.isEmpty) {
            // Si no hay retos en Firestore, intentar migrar los locales
            _logger.i(
                "No challenges found in Firestore. Attempting to migrate local challenges.");
            _migrateAndLoadChallenges();
          } else {
            _logger.i("Loaded ${challenges.length} challenges from Firestore");
            // Asegurarse de que las traducciones se aplican correctamente
            final translatedChallenges = challenges.map((challenge) {
              if (challenge is ChallengeModel && challenge.titleKey != null) {
                return ChallengeModel(
                  id: challenge.id,
                  title: challenge.titleKey!.tr,
                  description:
                      challenge.descriptionKey?.tr ?? challenge.description,
                  category: challenge.category,
                  points: challenge.points,
                  ageRange: challenge.ageRange,
                  isTemplate: challenge.isTemplate,
                  createdBy: challenge.createdBy,
                  createdAt: challenge.createdAt,
                  familyId: challenge.familyId,
                  icon: challenge.icon,
                  titleKey: challenge.titleKey,
                  descriptionKey: challenge.descriptionKey,
                  duration: challenge.duration,
                );
              }
              return challenge;
            }).toList();

            predefinedChallenges.assignAll(translatedChallenges);
            dataSource.value = 'firestore';
            status.value = ChallengeStatus.success;
          }
        },
      );
    } catch (e) {
      _logger.e("Unexpected error loading challenges: $e");
      _loadLocalPredefinedChallenges();
      dataSource.value = 'local';
    } finally {
      isLoadingPredefinedChallenges.value = false;
    }
  }

  void _loadLocalPredefinedChallenges() {
    _logger.i("Loading local predefined challenges");
    // Cargar retos desde el archivo local
    final localChallenges = PredefinedChallenges.getAll();

    // Asegurarse de aplicar las traducciones correctamente
    final translatedChallenges = localChallenges.map((challenge) {
      if (challenge is ChallengeModel && challenge.titleKey != null) {
        return ChallengeModel(
          id: challenge.id,
          title: challenge.titleKey!.tr,
          description: challenge.descriptionKey?.tr ?? challenge.description,
          category: challenge.category,
          points: challenge.points,
          ageRange: challenge.ageRange,
          isTemplate: challenge.isTemplate,
          createdBy: challenge.createdBy,
          createdAt: challenge.createdAt,
          familyId: challenge.familyId,
          icon: challenge.icon,
          titleKey: challenge.titleKey,
          descriptionKey: challenge.descriptionKey,
          duration: challenge.duration,
        );
      }
      return challenge;
    }).toList();

    predefinedChallenges.assignAll(translatedChallenges);
    useLocalChallenges.value = true;
    _logger.i("Loaded ${localChallenges.length} challenges from local data");
  }

  // Nueva función expuesta para implementación sin efectos secundarios (para uso en batch assign)
  Future<Either<Failure, AssignedChallenge>> assignChallengeToChildImpl({
    required String challengeId,
    required String childId,
    required String familyId,
    required DateTime startDate,
    DateTime? endDate,
    required String evaluationFrequency,
    bool isContinuous = false, // Nuevo parámetro
  }) async {
    _logger.i("Assigning challenge to child: $challengeId -> $childId");

    return await _challengeRepository.assignChallengeToChild(
      challengeId: challengeId,
      childId: childId,
      familyId: familyId,
      startDate: startDate,
      endDate: endDate,
      isContinuous: isContinuous,
    );
  }

  Future<void> _migrateAndLoadChallenges() async {
    try {
      // Primero cargar los locales
      final localChallenges = PredefinedChallenges.getAll();

      // Convertir de Challenge a ChallengeModel
      final challengeModels = localChallenges
          .map((challenge) => ChallengeModel.fromEntity(challenge))
          .toList();

      // Intentar migrarlos a Firestore
      _logger.i(
          "Attempting to migrate ${challengeModels.length} local challenges to Firestore");

      // Acceder directamente al datasource para migrar
      final remoteDataSource = Get.find<IChallengeRemoteDataSource>();
      await remoteDataSource.migrateLocalChallengesToFirestore(challengeModels);

      // Volver a cargar desde Firestore
      _logger.i("Migration successful, loading from Firestore");
      final result = await _challengeRepository.getPredefinedChallenges();

      result.fold(
        (failure) {
          _logger.e(
              "Error after migration: ${failure.message}. Using local fallback.");
          predefinedChallenges.assignAll(localChallenges);
          dataSource.value = 'local';
        },
        (challenges) {
          _logger.i(
              "Loaded ${challenges.length} challenges from Firestore after migration");
          predefinedChallenges.assignAll(challenges);
          dataSource.value = 'firestore';
        },
      );
    } catch (e) {
      _logger.e("Error during migration: $e. Using local fallback.");
      _loadLocalPredefinedChallenges();
      dataSource.value = 'local';
    }
  }

  Future<void> saveTemplateChallengeToFirestore(Challenge challenge) async {
    try {
      // Solo si estamos usando Firestore como fuente de datos
      if (dataSource.value != 'firestore') {
        errorMessage.value = 'template_save_requires_cloud'.tr;
        return;
      }

      isCreatingChallenge.value = true;
      status.value = ChallengeStatus.loading;

      // Crear copia del reto asegurando que es un template
      final templateChallenge = challenge.copyWith(
        isTemplate: true,
      );

      // Guardar en Firestore
      final result =
          await _challengeRepository.createChallenge(templateChallenge);

      result.fold(
        (failure) {
          status.value = ChallengeStatus.error;
          errorMessage.value = _mapFailureToMessage(failure);
          _logger.e("Error saving template challenge: ${failure.message}");
        },
        (savedChallenge) {
          // Actualizar lista de retos predefinidos
          final index =
              predefinedChallenges.indexWhere((c) => c.id == savedChallenge.id);
          if (index >= 0) {
            predefinedChallenges[index] = savedChallenge;
          } else {
            predefinedChallenges.add(savedChallenge);
          }

          status.value = ChallengeStatus.success;
          _logger.i(
              "Template challenge saved to Firestore: ${savedChallenge.title}");

          Get.snackbar(
            'template_saved_title'.tr,
            'template_saved_message'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green,
          );
        },
      );
    } catch (e) {
      status.value = ChallengeStatus.error;
      errorMessage.value = e.toString();
      _logger.e("Error saving template challenge: $e");
    } finally {
      isCreatingChallenge.value = false;
    }
  }

  /// Obtiene un reto por su id
  Future<void> getChallengeById(String challengeId) async {
    status.value = ChallengeStatus.loading;
    errorMessage.value = '';

    _logger.i("Getting challenge by id: $challengeId");
    final result = await _challengeRepository.getChallengeById(challengeId);

    result.fold(
      (failure) {
        status.value = ChallengeStatus.error;
        errorMessage.value = _mapFailureToMessage(failure);
        _logger.e("Error getting challenge: ${failure.message}");
      },
      (challenge) {
        selectedChallenge.value = challenge;
        status.value = ChallengeStatus.success;
        _logger.i("Challenge loaded successfully: ${challenge.title}");

        // Actualizar controladores con los datos del reto
        _populateFormWithChallenge(challenge);
      },
    );
  }

  /// Crea un nuevo reto
  Future<void> createChallenge() async {
    final currentUser = _sessionController.currentUser.value;
    if (currentUser == null) {
      _logger.e("No user logged in, can't create challenge");
      errorMessage.value = 'not_logged_in'.tr;
      return;
    }

    // Validar formulario
    if (!_validateChallengeForm()) {
      return;
    }

    isCreatingChallenge.value = true;
    status.value = ChallengeStatus.loading;
    errorMessage.value = '';

    // Crear objeto reto con el nuevo campo de duración
    final challenge = Challenge(
      id: '', // Se asignará en Firestore
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      category: selectedCategory.value,
      points: int.parse(pointsController.text.trim()),
      duration: selectedDuration.value, // Nuevo campo de duración
      ageRange: selectedAgeRange,
      isTemplate: isTemplateChallenge.value,
      createdBy: currentUser.uid,
      createdAt: DateTime.now(),
      familyId: isTemplateChallenge.value ? null : currentUser.familyId,
      icon: selectedIcon.value.isEmpty ? null : selectedIcon.value,
    );

    _logger.i("Creating challenge: ${challenge.title}");
    final result = await _challengeRepository.createChallenge(challenge);

    result.fold(
      (failure) {
        status.value = ChallengeStatus.error;
        errorMessage.value = _mapFailureToMessage(failure);
        isCreatingChallenge.value = false;
        _logger.e("Error creating challenge: ${failure.message}");
      },
      (createdChallenge) {
        // Añadir el nuevo reto a la lista correspondiente
        if (isTemplateChallenge.value) {
          predefinedChallenges.add(createdChallenge);
        } else if (currentUser.familyId != null) {
          familyChallenges.add(createdChallenge);
        }

        status.value = ChallengeStatus.success;
        isCreatingChallenge.value = false;
        _clearForm();

        _logger.i("Challenge created successfully: ${createdChallenge.title}");

        // Mostrar mensaje de éxito
        Get.snackbar(
          'challenge_created_title'.tr,
          'challenge_created_message'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green,
        );
      },
    );
  }

  /// Actualiza un reto existente
  Future<void> updateChallenge() async {
    if (selectedChallenge.value == null) {
      _logger.e("No challenge selected for update");
      errorMessage.value = 'no_challenge_selected'.tr;
      return;
    }

    // Validar formulario
    if (!_validateChallengeForm()) {
      return;
    }

    isUpdatingChallenge.value = true;
    status.value = ChallengeStatus.loading;
    errorMessage.value = '';

    // Actualizar objeto reto con el nuevo campo de duración
    final updatedChallenge = selectedChallenge.value!.copyWith(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      category: selectedCategory.value,
      points: int.parse(pointsController.text.trim()),
      duration: selectedDuration.value, // Nuevo campo de duración
      ageRange: selectedAgeRange,
      isTemplate: isTemplateChallenge.value,
      icon: selectedIcon.value.isEmpty ? null : selectedIcon.value,
    );

    _logger.i("Updating challenge: ${updatedChallenge.title}");
    final result = await _challengeRepository.updateChallenge(updatedChallenge);

    result.fold(
      (failure) {
        status.value = ChallengeStatus.error;
        errorMessage.value = _mapFailureToMessage(failure);
        isUpdatingChallenge.value = false;
        _logger.e("Error updating challenge: ${failure.message}");
      },
      (_) {
        // Actualizar en la lista correspondiente
        if (updatedChallenge.isTemplate) {
          final index = predefinedChallenges
              .indexWhere((c) => c.id == updatedChallenge.id);
          if (index != -1) {
            predefinedChallenges[index] = updatedChallenge;
          }
        } else {
          final index =
              familyChallenges.indexWhere((c) => c.id == updatedChallenge.id);
          if (index != -1) {
            familyChallenges[index] = updatedChallenge;
          }
        }

        // Actualizar el reto seleccionado
        selectedChallenge.value = updatedChallenge;

        status.value = ChallengeStatus.success;
        isUpdatingChallenge.value = false;

        _logger.i("Challenge updated successfully: ${updatedChallenge.title}");

        // Mostrar mensaje de éxito
        Get.snackbar(
          'challenge_updated_title'.tr,
          'challenge_updated_message'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green,
        );
      },
    );
  }

  /// Elimina un reto
  Future<void> deleteChallenge(String challengeId) async {
    isDeletingChallenge.value = true;
    status.value = ChallengeStatus.loading;
    errorMessage.value = '';

    _logger.i("Deleting challenge: $challengeId");
    final result = await _challengeRepository.deleteChallenge(challengeId);

    result.fold(
      (failure) {
        status.value = ChallengeStatus.error;
        errorMessage.value = _mapFailureToMessage(failure);
        isDeletingChallenge.value = false;
        _logger.e("Error deleting challenge: ${failure.message}");
      },
      (_) {
        // Eliminar de la lista correspondiente
        predefinedChallenges.removeWhere((c) => c.id == challengeId);
        familyChallenges.removeWhere((c) => c.id == challengeId);

        // Si es el reto seleccionado, deseleccionar
        if (selectedChallenge.value?.id == challengeId) {
          selectedChallenge.value = null;
          _clearForm();
        }

        status.value = ChallengeStatus.success;
        isDeletingChallenge.value = false;

        _logger.i("Challenge deleted successfully");

        // Mostrar mensaje de éxito
        Get.snackbar(
          'challenge_deleted_title'.tr,
          'challenge_deleted_message'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green,
        );
      },
    );
  }

  /// Asigna un reto a un niño
  Future<void> assignChallengeToChild() async {
    final currentUser = _sessionController.currentUser.value;
    if (currentUser == null || currentUser.familyId == null) {
      _logger.e("No user logged in or no family, can't assign challenge");
      errorMessage.value = 'not_in_family'.tr;
      return;
    }

    if (selectedChallenge.value == null) {
      _logger.e("No challenge selected for assignment");
      errorMessage.value = 'no_challenge_selected'.tr;
      return;
    }

    if (selectedChildId.value.isEmpty) {
      _logger.e("No child selected for assignment");
      errorMessage.value = 'no_child_selected'.tr;
      return;
    }

    // Validar fechas solo si no es un reto continuo
    if (!isContinuousChallenge.value &&
        endDate.value.isBefore(startDate.value)) {
      errorMessage.value = 'end_date_before_start_date'.tr;
      return;
    }

    isAssigningChallenge.value = true;
    status.value = ChallengeStatus.loading;
    errorMessage.value = '';

    _logger.i(
        "Assigning challenge to child: ${selectedChallenge.value!.title} -> ${selectedChildId.value}");

    final result = await _challengeRepository.assignChallengeToChild(
      challengeId: selectedChallenge.value!.id,
      childId: selectedChildId.value,
      familyId: currentUser.familyId!,
      startDate: startDate.value,
      endDate: endDate.value,
      isContinuous: isContinuousChallenge.value, // Nuevo parámetro
    );

    result.fold(
      (failure) {
        status.value = ChallengeStatus.error;
        errorMessage.value = _mapFailureToMessage(failure);
        isAssigningChallenge.value = false;
        _logger.e("Error assigning challenge: ${failure.message}");
      },
      (assignedChallenge) {
        // Añadir a la lista de retos asignados
        assignedChallenges.add(assignedChallenge);

        status.value = ChallengeStatus.success;
        isAssigningChallenge.value = false;

        _logger.i("Challenge assigned successfully");

        // Mostrar mensaje de éxito
        Get.snackbar(
          'challenge_assigned_title'.tr,
          'challenge_assigned_message'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green,
        );
      },
    );
  }

  /// Evalúa una ejecución específica de un reto
  Future<void> evaluateExecution({
    required String assignedChallengeId,
    required int executionIndex,
    required AssignedChallengeStatus status,
    required int points,
    String? note,
  }) async {
    isEvaluatingChallenge.value = true;
    errorMessage.value = '';

    _logger.i(
        "Evaluating execution $executionIndex for challenge: $assignedChallengeId");

    final result = await _challengeRepository.evaluateExecution(
      assignedChallengeId: assignedChallengeId,
      executionIndex: executionIndex,
      status: status,
      points: points,
      note: note,
    );

    result.fold(
      (failure) {
        errorMessage.value = _mapFailureToMessage(failure);
        _logger.e("Error evaluating execution: ${failure.message}");
      },
      (_) async {
        await _reloadAssignedChallenge(assignedChallengeId);
        _logger.i("Execution evaluated successfully");
      },
    );

    isEvaluatingChallenge.value = false;
  }

  /// Carga los retos asignados a un niño
  Future<void> loadAssignedChallengesByChild(String childId) async {
    isLoadingAssignedChallenges.value = true;
    errorMessage.value = '';

    _logger.i("Loading assigned challenges for child: $childId");
    final result =
        await _challengeRepository.getAssignedChallengesByChild(childId);

    result.fold(
      (failure) {
        status.value = ChallengeStatus.error;
        errorMessage.value = _mapFailureToMessage(failure);
        isLoadingAssignedChallenges.value = false;
        _logger.e("Error loading assigned challenges: ${failure.message}");
      },
      (challenges) {
        assignedChallenges.assignAll(challenges);
        status.value = ChallengeStatus.success;
        isLoadingAssignedChallenges.value = false;
        _logger
            .i("Assigned challenges loaded successfully: ${challenges.length}");
      },
    );
  }

  /// Evalúa un reto asignado

  // Future<void> evaluateAssignedChallenge({
  //   required String assignedChallengeId,
  //   required AssignedChallengeStatus newStatus,
  //   required int points,
  //   String? note,
  // }) async {
  //   isEvaluatingChallenge.value = true;
  //   status.value = ChallengeStatus.loading;
  //   errorMessage.value = '';

  //   _logger.i(
  //       "Evaluating challenge: $assignedChallengeId with status: ${newStatus.toString()}");

  //   // Obtener el reto asignado para determinar cómo evaluarlo
  //   final assignedChallengeResult = await _challengeRepository
  //       .getAssignedChallengeById(assignedChallengeId);

  //   await assignedChallengeResult.fold(
  //     (failure) {
  //       status.value = ChallengeStatus.error;
  //       errorMessage.value = _mapFailureToMessage(failure);
  //       isEvaluatingChallenge.value = false;
  //       _logger.e("Error getting assigned challenge: ${failure.message}");
  //     },
  //     (assignedChallenge) async {
  //       // Si tiene ejecuciones, usar el nuevo método para evaluar la última ejecución
  //       if (assignedChallenge.executions.isNotEmpty) {
  //         // Evaluar la ejecución actual (última)
  //         final executionIndex = assignedChallenge.executions.length - 1;

  //         final result = await _challengeRepository.evaluateExecution(
  //           assignedChallengeId: assignedChallengeId,
  //           executionIndex: executionIndex,
  //           status: newStatus,
  //           points: points,
  //           note: note,
  //         );

  //         result.fold(
  //           (failure) {
  //             status.value = ChallengeStatus.error;
  //             errorMessage.value = _mapFailureToMessage(failure);
  //             _logger.e("Error evaluating execution: ${failure.message}");
  //           },
  //           (_) async {
  //             // Si es un reto continuo y se completó/falló, ya se creará automáticamente la siguiente ejecución
  //             // No necesitamos hacer nada adicional aquí

  //             // Recargar el reto para obtener datos actualizados
  //             await _reloadAssignedChallenge(assignedChallengeId);

  //             status.value = ChallengeStatus.success;
  //             _logger.i("Challenge execution evaluated successfully");
  //           },
  //         );
  //       }
  //       // else {
  //       //   // Por compatibilidad con retos antiguos, usar el método legacy solo si no hay ejecuciones
  //       //   _logger.i(
  //       //       "Using legacy evaluation method for challenge without executions");

  //       //   final result = await _challengeRepository.evaluateAssignedChallenge(
  //       //     assignedChallengeId: assignedChallengeId,
  //       //     status: newStatus,
  //       //     points: points,
  //       //     note: note,
  //       //   );

  //       //   result.fold(
  //       //     (failure) {
  //       //       status.value = ChallengeStatus.error;
  //       //       errorMessage.value = _mapFailureToMessage(failure);
  //       //       _logger.e("Error evaluating challenge: ${failure.message}");
  //       //     },
  //       //     (_) async {
  //       //       // Recargar el reto para obtener datos actualizados
  //       //       await _reloadAssignedChallenge(assignedChallengeId);

  //       //       status.value = ChallengeStatus.success;
  //       //       _logger.i("Challenge evaluated successfully");
  //       //     },
  //       //   );
  //       // }
  //     },
  //   );

  //   isEvaluatingChallenge.value = false;

  //   // Mostrar mensaje de éxito si no hay errores
  //   if (status.value == ChallengeStatus.success) {
  //     Get.snackbar(
  //       'challenge_evaluated_title'.tr,
  //       'challenge_evaluated_message'.tr,
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Colors.green.shade50,
  //       colorText: Colors.green,
  //     );
  //   }
  // }

  /// Crea la siguiente ejecución para un reto continuo
  @Deprecated('The next execution is created automatically by the repository')
  Future<void> _createNextExecution(AssignedChallenge assignedChallenge) async {
    if (!assignedChallenge.isContinuous) return;

    isCreatingNextExecution.value = true;

    try {
      // Obtener el challenge original para calcular la duración de la nueva ejecución
      final challengeResult = await _challengeRepository
          .getChallengeById(assignedChallenge.challengeId);

      await challengeResult.fold(
        (failure) {
          _logger.e("Error getting challenge: ${failure.message}");
        },
        (challenge) async {
          // Obtener la última ejecución
          final lastExecution = assignedChallenge.executions.last;

          // Calcular nuevas fechas basadas en la duración
          final newStartDate =
              lastExecution.endDate.add(const Duration(days: 1));
          final newEndDate =
              _calculateEndDate(newStartDate, challenge.duration);

          // Crear nueva ejecución
          final result = await _challengeRepository.createNextExecution(
            assignedChallengeId: assignedChallenge.id,
            startDate: newStartDate,
            endDate: newEndDate,
          );

          result.fold(
            (failure) {
              _logger.e("Error creating next execution: ${failure.message}");
            },
            (_) {
              _logger.i("Next execution created successfully");
            },
          );
        },
      );
    } catch (e) {
      _logger.e("Unexpected error creating next execution: $e");
    } finally {
      isCreatingNextExecution.value = false;
    }
  }

  /// Recarga un reto asignado para obtener datos actualizados
  Future<void> _reloadAssignedChallenge(String assignedChallengeId) async {
    final updatedChallengeResult = await _challengeRepository
        .getAssignedChallengeById(assignedChallengeId);

    updatedChallengeResult.fold(
      (failure) {
        _logger.w(
            "Couldn't reload challenge after evaluation: ${failure.message}");
      },
      (updatedChallenge) {
        // Actualizar en la lista
        final index =
            assignedChallenges.indexWhere((c) => c.id == assignedChallengeId);
        if (index != -1) {
          assignedChallenges[index] = updatedChallenge;
        }

        // Actualizar el seleccionado si corresponde
        if (selectedAssignedChallenge.value?.id == assignedChallengeId) {
          selectedAssignedChallenge.value = updatedChallenge;
        }
      },
    );
  }

  Future<void> deleteAssignedChallenge(String assignedChallengeId) async {
    status.value = ChallengeStatus.loading;
    errorMessage.value = '';

    _logger.i("Deleting assigned challenge: $assignedChallengeId");
    final result =
        await _challengeRepository.deleteAssignedChallenge(assignedChallengeId);

    result.fold(
      (failure) {
        status.value = ChallengeStatus.error;
        errorMessage.value = _mapFailureToMessage(failure);
        _logger.e("Error deleting assigned challenge: ${failure.message}");
      },
      (_) {
        // Eliminar de la lista
        assignedChallenges.removeWhere((c) => c.id == assignedChallengeId);

        // Si es el seleccionado, deseleccionar
        if (selectedAssignedChallenge.value?.id == assignedChallengeId) {
          selectedAssignedChallenge.value = null;
        }

        status.value = ChallengeStatus.success;

        _logger.i("Assigned challenge deleted successfully");

        // Mostrar mensaje de éxito
        Get.snackbar(
          'assigned_challenge_deleted_title'.tr,
          'assigned_challenge_deleted_message'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green,
        );
      },
    );
  }

  /// Rellena el formulario con los datos de un reto
  void _populateFormWithChallenge(Challenge challenge) {
    titleController.text = challenge.title;
    descriptionController.text = challenge.description;
    pointsController.text = challenge.points.toString();
    selectedCategory.value = challenge.category;
    selectedDuration.value = challenge.duration; // Nuevo campo
    selectedAgeRange.value = challenge.ageRange;
    isTemplateChallenge.value = challenge.isTemplate;
    selectedIcon.value = challenge.icon ?? '';
  }

  /// Valida el formulario de reto
  bool _validateChallengeForm() {
    if (titleController.text.trim().isEmpty) {
      errorMessage.value = 'title_required'.tr;
      return false;
    }

    if (descriptionController.text.trim().isEmpty) {
      errorMessage.value = 'description_required'.tr;
      return false;
    }

    if (pointsController.text.trim().isEmpty) {
      errorMessage.value = 'points_required'.tr;
      return false;
    }

    try {
      final points = int.parse(pointsController.text.trim());
      if (points <= 0) {
        errorMessage.value = 'points_must_be_positive'.tr;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'invalid_points'.tr;
      return false;
    }

    if (selectedAgeRange['min'] > selectedAgeRange['max']) {
      errorMessage.value = 'invalid_age_range'.tr;
      return false;
    }

    // Añadir validación adicional para retos puntuales si es necesario
    if (selectedDuration.value == ChallengeDuration.punctual &&
        isTemplateChallenge.value) {
      errorMessage.value = 'punctual_challenges_cannot_be_template'.tr;
      return false;
    }

    return true;
  }

  /// Limpia el formulario
  void _clearForm() {
    titleController.clear();
    descriptionController.clear();
    pointsController.text = '10';
    selectedCategory.value = ChallengeCategory.hygiene;
    selectedDuration.value = ChallengeDuration.weekly; // Valor predeterminado
    selectedAgeRange.value = {'min': 3, 'max': 12};
    isTemplateChallenge.value = false;
    isContinuousChallenge.value = false; // Reiniciar flag de reto continuo
    selectedIcon.value = '';
    selectedChallenge.value = null;
  }

  /// Selecciona un reto para editar
  void selectChallengeForEdit(Challenge challenge) {
    selectedChallenge.value = challenge;
    _populateFormWithChallenge(challenge);
  }

  /// Selecciona un reto asignado
  void selectAssignedChallenge(AssignedChallenge assignedChallenge) {
    selectedAssignedChallenge.value = assignedChallenge;
  }

  /// Selecciona un niño para asignar reto
  void selectChildForAssignment(String childId) {
    selectedChildId.value = childId;
  }

  /// Convierte un reto predefinido en un reto personalizado para la familia
  Future<void> convertTemplateToFamilyChallenge(
      Challenge templateChallenge) async {
    final currentUser = _sessionController.currentUser.value;
    if (currentUser == null || currentUser.familyId == null) {
      _logger.e("No user logged in or no family, can't convert template");
      errorMessage.value = 'not_in_family'.tr;
      return;
    }

    status.value = ChallengeStatus.loading;
    errorMessage.value = '';

    // Crear una copia del reto pero como reto familiar
    final familyChallenge = templateChallenge.copyWith(
      id: '', // Se asignará en Firestore
      isTemplate: false,
      familyId: currentUser.familyId,
      createdBy: currentUser.uid,
      createdAt: DateTime.now(),
    );

    _logger.i(
        "Converting template challenge to family challenge: ${templateChallenge.title}");
    final result = await _challengeRepository.createChallenge(familyChallenge);

    result.fold(
      (failure) {
        status.value = ChallengeStatus.error;
        errorMessage.value = _mapFailureToMessage(failure);
        _logger.e("Error converting template challenge: ${failure.message}");
      },
      (createdChallenge) {
        // Añadir a la lista de retos familiares
        familyChallenges.add(createdChallenge);

        status.value = ChallengeStatus.success;

        _logger.i("Template challenge converted successfully");

        // Mostrar mensaje de éxito
        Get.snackbar(
          'template_converted_title'.tr,
          'template_converted_message'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green,
        );
      },
    );
  }

  /// Inicializa los filtros
  void initializeFilters() {
    filterCategory.value = null;
    filterMinAge.value = 0;
    filterMaxAge.value = 18;
    searchQuery.value = '';
    searchController.text = '';

    // Aplica el filtro inicial
    applyFilters();
  }

  /// Aplica los filtros a la lista de retos predefinidos
  void applyFilters() {
    // Comenzar con todos los retos predefinidos o familiares según el contexto
    List<Challenge> challenges = [...predefinedChallenges];

    // Filtrar por categoría si está seleccionada
    if (filterCategory.value != null) {
      challenges = challenges
          .where((challenge) => challenge.category == filterCategory.value)
          .toList();
    }

    // Filtrar por frecuencia si está seleccionada
    if (filterDuration.value != null) {
      challenges = challenges
          .where((challenge) => challenge.duration == filterDuration.value)
          .toList();
    }

    // Filtrar por rango de edad
    challenges = challenges.where((challenge) {
      final minAge = challenge.ageRange['min'] as int;
      final maxAge = challenge.ageRange['max'] as int;

      // Verificar superposición de rangos de edad
      return maxAge >= filterMinAge.value && minAge <= filterMaxAge.value;
    }).toList();

    // Filtrar por edad apropiada si está habilitado
    if (showOnlyAgeAppropriate.value) {
      challenges = challenges.where((challenge) {
        final minAge = challenge.ageRange['min'] as int;
        final maxAge = challenge.ageRange['max'] as int;
        return selectedChildAge.value >= minAge &&
            selectedChildAge.value <= maxAge;
      }).toList();
    }

    // Filtrar por búsqueda de texto
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      challenges = challenges
          .where((challenge) =>
              challenge.title.toLowerCase().contains(query) ||
              challenge.description.toLowerCase().contains(query))
          .toList();
    }

    // Actualizar la lista filtrada
    filteredChallenges.assignAll(challenges);
  }

  /// Cambia la categoría de filtro
  void setFilterCategory(ChallengeCategory? category) {
    filterCategory.value = category;
    applyFilters();
  }

  /// Cambia la frecuencia de filtro
  void setFilterFrequency(ChallengeDuration? durtation) {
    filterDuration.value = durtation;
    applyFilters();
  }

  /// Establece el rango de edad para filtrar
  void setAgeRange(int min, int max) {
    filterMinAge.value = min;
    filterMaxAge.value = max;
    applyFilters();
  }

  /// Cambia el modo de mostrar solo retos apropiados para la edad
  void toggleAgeAppropriate(bool value) {
    showOnlyAgeAppropriate.value = value;
    applyFilters();
  }

  /// Actualiza la consulta de búsqueda
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  /// Limpia todos los filtros
  void clearFilters() {
    initializeFilters();
  }

  /// Selecciona o deselecciona un reto
  void toggleChallengeSelection(String challengeId) {
    if (selectedChallengeIds.contains(challengeId)) {
      selectedChallengeIds.remove(challengeId);
    } else {
      selectedChallengeIds.add(challengeId);
    }
  }

  /// Verifica si un reto está seleccionado
  bool isChallengeSelected(String challengeId) {
    return selectedChallengeIds.contains(challengeId);
  }

  /// Limpia la selección de retos
  void clearSelection() {
    selectedChallengeIds.clear();
  }

  /// Adapta la dificultad del reto según la edad
  int adaptPointsByAge(int basePoints, int ageMin, int ageMax, int childAge) {
    // Si la edad del niño está fuera del rango, mantener puntos base
    if (childAge < ageMin || childAge > ageMax) {
      return basePoints;
    }

    // Adaptar puntos según la edad relativa dentro del rango
    final ageRange = ageMax - ageMin;
    if (ageRange == 0) return basePoints;

    final relativeAge = (childAge - ageMin) / ageRange;

    // Para edades más jóvenes dentro del rango, dar más puntos
    // Para edades mayores, dar menos puntos (aumentar la dificultad)
    if (relativeAge < 0.5) {
      // Más joven, hasta 40% más puntos
      return (basePoints * (1 + 0.4 * (0.5 - relativeAge) * 2)).round();
    } else {
      // Mayor, hasta 20% menos puntos
      return (basePoints * (1 - 0.2 * (relativeAge - 0.5) * 2)).round();
    }
  }

  /// Importa retos desde JSON
  Future<void> importChallengesFromJson(String jsonString) async {
    isImporting.value = true;
    errorMessage.value = '';

    try {
      // Parsing y validación del JSON aquí
      // Convertir a modelos de reto
      // Guardar en Firebase

      isImporting.value = false;
      Get.snackbar(
        'import_success_title'.tr,
        'import_success_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green,
      );
    } catch (e) {
      isImporting.value = false;
      errorMessage.value = e.toString();
      _logger.e("Error importing challenges: $e");

      Get.snackbar(
        'import_error_title'.tr,
        'import_error_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red,
      );
    }
  }

  /// Exporta retos a JSON
  Future<String> exportChallengesToJson(List<Challenge> challenges) async {
    isExporting.value = true;
    errorMessage.value = '';

    try {
      // Convertir retos a formato JSON
      final jsonData = challenges.map((challenge) {
        // Crear mapa con propiedades del reto
        return {
          'title': challenge.title,
          'description': challenge.description,
          'category': _categoryToString(challenge.category),
          'duration': _durationToString(challenge.duration),
          'points': challenge.points,
          'ageRange': challenge.ageRange,
          'icon': challenge.icon,
        };
      }).toList();

      // Convertir a string JSON
      final jsonString = jsonEncode(jsonData);

      isExporting.value = false;
      return jsonString;
    } catch (e) {
      isExporting.value = false;
      errorMessage.value = e.toString();
      _logger.e("Error exporting challenges: $e");

      Get.snackbar(
        'export_error_title'.tr,
        'export_error_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red,
      );

      return '';
    }
  }

  static String _durationToString(ChallengeDuration duration) {
    switch (duration) {
      case ChallengeDuration.weekly:
        return 'weekly';
      case ChallengeDuration.monthly:
        return 'monthly';
      case ChallengeDuration.quarterly:
        return 'quarterly';
      case ChallengeDuration.yearly:
        return 'yearly';
      case ChallengeDuration.punctual:
        return 'punctual';
    }
  }

  /// Calcula la fecha de fin en función de la duración del reto
  DateTime _calculateEndDate(DateTime startDate, ChallengeDuration duration) {
    switch (duration) {
      case ChallengeDuration.weekly:
        // Obtener el próximo domingo
        final int daysUntilSunday = 7 - startDate.weekday;
        return startDate.add(Duration(days: daysUntilSunday));

      case ChallengeDuration.monthly:
        // Último día del mes
        final nextMonth = startDate.month < 12
            ? DateTime(startDate.year, startDate.month + 1, 1)
            : DateTime(startDate.year + 1, 1, 1);
        return nextMonth.subtract(const Duration(days: 1));

      case ChallengeDuration.quarterly:
        // Último día del trimestre actual
        final int currentQuarter = (startDate.month - 1) ~/ 3;
        final int lastMonthOfQuarter = (currentQuarter + 1) * 3;
        final nextQuarter = lastMonthOfQuarter < 12
            ? DateTime(startDate.year, lastMonthOfQuarter + 1, 1)
            : DateTime(startDate.year + 1, 1, 1);
        return nextQuarter.subtract(const Duration(days: 1));

      case ChallengeDuration.yearly:
        // Último día del año
        return DateTime(startDate.year, 12, 31);

      case ChallengeDuration.punctual:
        // Por defecto, una semana
        return startDate.add(const Duration(days: 7));
    }
  }

  // Métodos auxiliares para convertir enumeraciones a strings
  static String _categoryToString(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.hygiene:
        return 'hygiene';
      case ChallengeCategory.school:
        return 'school';
      case ChallengeCategory.order:
        return 'order';
      case ChallengeCategory.responsibility:
        return 'responsibility';
      case ChallengeCategory.help:
        return 'help';
      case ChallengeCategory.special:
        return 'special';
      case ChallengeCategory.sibling:
        return 'sibling';
    }
  }

  /// Maps failure types to user-friendly messages
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return TrKeys.serverErrorMessage.tr;
      case NetworkFailure:
        return TrKeys.connectionErrorMessage.tr;
      case NotFoundFailure:
        return failure.message;
      case ValidationFailure:
        return failure.message;
      default:
        return TrKeys.unexpectedErrorMessage.tr;
    }
  }
}
