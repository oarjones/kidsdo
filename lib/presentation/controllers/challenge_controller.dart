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
  final Rx<ChallengeFrequency> selectedFrequency =
      Rx<ChallengeFrequency>(ChallengeFrequency.daily);
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
  final Rx<ChallengeFrequency?> filterFrequency = Rx<ChallengeFrequency?>(null);
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
    // [Código existente para actualizar traducciones...]
  }

  @override
  void onInit() {
    super.onInit();

    // [Código de inicialización existente...]

    _initializeControllers();

    // [Resto del código de inicialización...]
  }

  void _initializeControllers() {
    // [Código existente de inicialización de controladores...]
  }

  @override
  void onClose() {
    // [Código existente de onClose...]
    super.onClose();
  }

  void _disposeControllers() {
    // [Código existente de disposición de controladores...]
  }

  void _clearErrorOnChange() {
    // [Código existente...]
  }

  /// Carga los retos de una familia específica
  Future<void> loadFamilyChallenges(String familyId) async {
    // [Código existente...]
  }

  /// Carga los retos predefinidos
  Future<void> loadPredefinedChallenges() async {
    // [Código existente...]
  }

  void _loadLocalPredefinedChallenges() {
    // [Código existente...]
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
      endDate:
          isContinuous ? null : endDate, // Si es continuo, no tiene fecha fin
      evaluationFrequency: evaluationFrequency,
      isContinuous: isContinuous,
    );
  }

  Future<void> _migrateAndLoadChallenges() async {
    // [Código existente...]
  }

  Future<void> saveTemplateChallengeToFirestore(Challenge challenge) async {
    // [Código existente...]
  }

  /// Obtiene un reto por su id
  Future<void> getChallengeById(String challengeId) async {
    // [Código existente...]
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
      frequency: selectedFrequency.value,
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

    // [Resto del código para manejar el resultado...]
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
      frequency: selectedFrequency.value,
      duration: selectedDuration.value, // Nuevo campo de duración
      ageRange: selectedAgeRange,
      isTemplate: isTemplateChallenge.value,
      icon: selectedIcon.value.isEmpty ? null : selectedIcon.value,
    );

    // [Resto del código para actualizar el reto...]
  }

  /// Elimina un reto
  Future<void> deleteChallenge(String challengeId) async {
    // [Código existente...]
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
      endDate: isContinuousChallenge.value
          ? null
          : endDate.value, // Nulo si es continuo
      evaluationFrequency: selectedEvaluationFrequency.value,
      isContinuous: isContinuousChallenge.value, // Nuevo parámetro
    );

    // [Resto del código para manejar el resultado...]
  }

  /// Carga los retos asignados a un niño
  Future<void> loadAssignedChallengesByChild(String childId) async {
    // [Código existente...]
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

    // Obtener el reto asignado para saber el índice de la ejecución actual
    final assignedChallengeResult = await _challengeRepository
        .getAssignedChallengeById(assignedChallengeId);

    await assignedChallengeResult.fold(
      (failure) {
        status.value = ChallengeStatus.error;
        errorMessage.value = _mapFailureToMessage(failure);
        isEvaluatingChallenge.value = false;
        _logger.e("Error getting assigned challenge: ${failure.message}");
      },
      (assignedChallenge) async {
        // Si tiene ejecuciones, usar el nuevo método
        if (assignedChallenge.executions.isNotEmpty) {
          // Evaluar la ejecución actual (última)
          final executionIndex = assignedChallenge.executions.length - 1;

          final result = await _challengeRepository.evaluateExecution(
            assignedChallengeId: assignedChallengeId,
            executionIndex: executionIndex,
            status: newStatus,
            points: points,
            note: note,
          );

          result.fold(
            (failure) {
              status.value = ChallengeStatus.error;
              errorMessage.value = _mapFailureToMessage(failure);
              _logger.e("Error evaluating execution: ${failure.message}");
            },
            (_) async {
              // Si es un reto continuo y se completó/falló, crear la siguiente ejecución
              if (assignedChallenge.isContinuous &&
                  (newStatus == AssignedChallengeStatus.completed ||
                      newStatus == AssignedChallengeStatus.failed)) {
                await _createNextExecution(assignedChallenge);
              }

              // Recargar el reto para obtener datos actualizados
              await _reloadAssignedChallenge(assignedChallengeId);

              status.value = ChallengeStatus.success;
              _logger.i("Challenge execution evaluated successfully");
            },
          );
        } else {
          // Usar el método legacy para compatibilidad
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
              _logger.e("Error evaluating challenge: ${failure.message}");
            },
            (_) async {
              // Recargar el reto para obtener datos actualizados
              await _reloadAssignedChallenge(assignedChallengeId);

              status.value = ChallengeStatus.success;
              _logger.i("Challenge evaluated successfully");
            },
          );
        }
      },
    );

    isEvaluatingChallenge.value = false;

    // Mostrar mensaje de éxito si no hay errores
    if (status.value == ChallengeStatus.success) {
      Get.snackbar(
        'challenge_evaluated_title'.tr,
        'challenge_evaluated_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green,
      );
    }
  }

  /// Crea la siguiente ejecución para un reto continuo
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

  /// Elimina un reto asignado
  Future<void> deleteAssignedChallenge(String assignedChallengeId) async {
    // [Código existente...]
  }

  /// Rellena el formulario con los datos de un reto
  void _populateFormWithChallenge(Challenge challenge) {
    titleController.text = challenge.title;
    descriptionController.text = challenge.description;
    pointsController.text = challenge.points.toString();
    selectedCategory.value = challenge.category;
    selectedFrequency.value = challenge.frequency;
    selectedDuration.value = challenge.duration; // Nuevo campo
    selectedAgeRange.value = challenge.ageRange;
    isTemplateChallenge.value = challenge.isTemplate;
    selectedIcon.value = challenge.icon ?? '';
  }

  /// Valida el formulario de reto
  bool _validateChallengeForm() {
    // [Código existente...]
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
    selectedFrequency.value = ChallengeFrequency.daily;
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
    // [Código existente...]
  }

  /// Inicializa los filtros
  void initializeFilters() {
    // [Código existente...]
  }

  /// Aplica los filtros a la lista de retos predefinidos
  void applyFilters() {
    // [Código existente...]
  }

  /// Cambia la categoría de filtro
  void setFilterCategory(ChallengeCategory? category) {
    // [Código existente...]
  }

  /// Cambia la frecuencia de filtro
  void setFilterFrequency(ChallengeFrequency? frequency) {
    // [Código existente...]
  }

  /// Establece el rango de edad para filtrar
  void setAgeRange(int min, int max) {
    // [Código existente...]
  }

  /// Cambia el modo de mostrar solo retos apropiados para la edad
  void toggleAgeAppropriate(bool value) {
    // [Código existente...]
  }

  /// Actualiza la consulta de búsqueda
  void updateSearchQuery(String query) {
    // [Código existente...]
  }

  /// Limpia todos los filtros
  void clearFilters() {
    // [Código existente...]
  }

  /// Selecciona o deselecciona un reto
  void toggleChallengeSelection(String challengeId) {
    // [Código existente...]
  }

  /// Verifica si un reto está seleccionado
  bool isChallengeSelected(String challengeId) {
    // [Código existente...]
    return selectedChallengeIds.contains(challengeId);
  }

  /// Limpia la selección de retos
  void clearSelection() {
    // [Código existente...]
  }

  /// Adapta la dificultad del reto según la edad
  int adaptPointsByAge(int basePoints, int ageMin, int ageMax, int childAge) {
    // [Código existente...]
    return basePoints;
  }

  /// Importa retos desde JSON
  Future<void> importChallengesFromJson(String jsonString) async {
    // [Código existente...]
  }

  /// Exporta retos a JSON
  Future<String> exportChallengesToJson(List<Challenge> challenges) async {
    // [Código existente...]
    return '';
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
      default:
        // Por defecto, una semana
        return startDate.add(const Duration(days: 7));
    }
  }

  /// Maps failure types to user-friendly messages
  String _mapFailureToMessage(Failure failure) {
    // [Código existente...]
    return failure.message;
  }
}
