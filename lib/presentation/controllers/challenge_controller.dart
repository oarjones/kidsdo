import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/errors/failures.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/challenge.dart';
import 'package:kidsdo/domain/entities/assigned_challenge.dart';
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

  // Form controllers
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController pointsController;

  // Campos seleccionables
  final Rx<ChallengeCategory> selectedCategory =
      Rx<ChallengeCategory>(ChallengeCategory.hygiene);
  final Rx<ChallengeFrequency> selectedFrequency =
      Rx<ChallengeFrequency>(ChallengeFrequency.daily);
  final RxMap<String, dynamic> selectedAgeRange =
      RxMap<String, dynamic>({'min': 3, 'max': 12});
  final RxBool isTemplateChallenge = RxBool(false);
  final RxString selectedIcon = RxString('');

  // Campos para asignación
  final Rx<DateTime> startDate = Rx<DateTime>(DateTime.now());
  final Rx<DateTime> endDate =
      Rx<DateTime>(DateTime.now().add(const Duration(days: 7)));
  final RxString selectedEvaluationFrequency = RxString('daily');
  final RxString selectedChildId = RxString('');

  ChallengeController({
    required IChallengeRepository challengeRepository,
    required SessionController sessionController,
    Logger? logger,
  })  : _challengeRepository = challengeRepository,
        _sessionController = sessionController,
        _logger = logger ?? Get.find<Logger>();

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();

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

  /// Carga los retos predefinidos
  Future<void> loadPredefinedChallenges() async {
    isLoadingPredefinedChallenges.value = true;
    errorMessage.value = '';

    _logger.i("Loading predefined challenges");
    final result = await _challengeRepository.getPredefinedChallenges();

    result.fold(
      (failure) {
        status.value = ChallengeStatus.error;
        errorMessage.value = _mapFailureToMessage(failure);
        isLoadingPredefinedChallenges.value = false;
        _logger.e("Error loading predefined challenges: ${failure.message}");
      },
      (challenges) {
        predefinedChallenges.assignAll(challenges);
        status.value = ChallengeStatus.success;
        isLoadingPredefinedChallenges.value = false;
        _logger.i(
            "Predefined challenges loaded successfully: ${challenges.length}");
      },
    );
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

    // Crear objeto reto
    final challenge = Challenge(
      id: '', // Se asignará en Firestore
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      category: selectedCategory.value,
      points: int.parse(pointsController.text.trim()),
      frequency: selectedFrequency.value,
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

    // Actualizar objeto reto
    final updatedChallenge = selectedChallenge.value!.copyWith(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      category: selectedCategory.value,
      points: int.parse(pointsController.text.trim()),
      frequency: selectedFrequency.value,
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

    // Validar fechas
    if (endDate.value.isBefore(startDate.value)) {
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
      evaluationFrequency: selectedEvaluationFrequency.value,
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
  Future<void> evaluateAssignedChallenge({
    required String assignedChallengeId,
    required AssignedChallengeStatus newStatus,
    required int points,
    String? note,
  }) async {
    isEvaluatingChallenge.value = true;
    status.value = ChallengeStatus.loading;
    errorMessage.value = '';

    _logger.i(
        "Evaluating challenge: $assignedChallengeId with status: ${newStatus.toString()}");
    final result = await _challengeRepository.evaluateAssignedChallenge(
      assignedChallengeId: assignedChallengeId,
      status: newStatus,
      points: points,
      note: note,
    );

    result.fold(
      (failure) {
        status.value = ChallengeStatus.error;
        errorMessage.value = _mapFailureToMessage(failure);
        isEvaluatingChallenge.value = false;
        _logger.e("Error evaluating challenge: ${failure.message}");
      },
      (_) async {
        // Recargar el reto asignado para obtener los datos actualizados
        final updatedChallengeResult = await _challengeRepository
            .getAssignedChallengeById(assignedChallengeId);

        updatedChallengeResult.fold(
          (failure) {
            _logger.w(
                "Couldn't reload challenge after evaluation: ${failure.message}");
          },
          (updatedChallenge) {
            // Actualizar en la lista
            final index = assignedChallenges
                .indexWhere((c) => c.id == assignedChallengeId);
            if (index != -1) {
              assignedChallenges[index] = updatedChallenge;
            }

            // Actualizar el seleccionado si corresponde
            if (selectedAssignedChallenge.value?.id == assignedChallengeId) {
              selectedAssignedChallenge.value = updatedChallenge;
            }
          },
        );

        status.value = ChallengeStatus.success;
        isEvaluatingChallenge.value = false;

        _logger.i("Challenge evaluated successfully");

        // Mostrar mensaje de éxito
        Get.snackbar(
          'challenge_evaluated_title'.tr,
          'challenge_evaluated_message'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green,
        );
      },
    );
  }

  /// Elimina un reto asignado
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
    selectedFrequency.value = challenge.frequency;
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

    return true;
  }

  /// Limpia el formulario
  void _clearForm() {
    titleController.clear();
    descriptionController.clear();
    pointsController.text = '10';
    selectedCategory.value = ChallengeCategory.hygiene;
    selectedFrequency.value = ChallengeFrequency.daily;
    selectedAgeRange.value = {'min': 3, 'max': 12};
    isTemplateChallenge.value = false;
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
