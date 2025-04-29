import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/assigned_challenge.dart';
import 'package:kidsdo/domain/entities/challenge.dart';
import 'package:kidsdo/domain/entities/family_child.dart';
import 'package:kidsdo/domain/repositories/challenge_repository.dart';
import 'package:kidsdo/presentation/controllers/child_access_controller.dart';
import 'package:logger/logger.dart';

enum ChildChallengeStatus {
  initial,
  loading,
  success,
  error,
}

class ChildChallengesController extends GetxController {
  final IChallengeRepository _challengeRepository;
  final ChildAccessController _childAccessController;
  final Logger _logger;

  // Estado observable
  final Rx<ChildChallengeStatus> status =
      Rx<ChildChallengeStatus>(ChildChallengeStatus.initial);
  final RxString errorMessage = RxString('');

  // Retos asignados al niño
  final RxList<AssignedChallenge> assignedChallenges =
      RxList<AssignedChallenge>([]);
  final RxList<Challenge> challenges = RxList<Challenge>([]);

  // Retos filtrados
  final RxList<AssignedChallenge> pendingChallenges =
      RxList<AssignedChallenge>([]);
  final RxList<AssignedChallenge> completedChallenges =
      RxList<AssignedChallenge>([]);
  final RxList<AssignedChallenge> dailyChallenges =
      RxList<AssignedChallenge>([]);
  final RxList<AssignedChallenge> weeklyChallenges =
      RxList<AssignedChallenge>([]);

  // Estados de carga
  final RxBool isLoading = RxBool(false);
  final RxBool isUpdating = RxBool(false);

  // Estado de celebración cuando se completa un reto
  final RxBool showCelebration = RxBool(false);
  final RxInt pointsEarned = RxInt(0);
  final Rx<AssignedChallenge?> completedChallenge =
      Rx<AssignedChallenge?>(null);

  // Para el scroll infinito y paginación
  final RxBool hasMoreChallenges = RxBool(true);
  final RxInt page = RxInt(1);
  final int pageSize = 10;

  // Para filtrado y búsqueda
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = RxString('');
  final RxString selectedFilter =
      RxString('all'); // all, pending, completed, daily, weekly

  ChildChallengesController({
    required IChallengeRepository challengeRepository,
    required ChildAccessController childAccessController,
    Logger? logger,
  })  : _challengeRepository = challengeRepository,
        _childAccessController = childAccessController,
        _logger = logger ?? Get.find<Logger>();

  @override
  void onInit() {
    super.onInit();

    // Inicializar búsqueda
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _filterChallenges();
    });

    // Cargar retos cuando el perfil activo cambia
    ever(_childAccessController.activeChildProfile, (_) {
      if (_childAccessController.activeChildProfile.value != null) {
        loadChildChallenges();
      }
    });

    // Cargar retos iniciales si ya hay un perfil activo
    if (_childAccessController.activeChildProfile.value != null) {
      loadChildChallenges();
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// Carga los retos asignados al niño activo
  Future<void> loadChildChallenges() async {
    final FamilyChild? activeChild =
        _childAccessController.activeChildProfile.value;
    if (activeChild == null) {
      _logger.w("No hay perfil infantil activo para cargar retos");
      return;
    }

    isLoading.value = true;
    status.value = ChildChallengeStatus.loading;
    errorMessage.value = '';

    try {
      // Cargar retos asignados
      final result = await _challengeRepository
          .getAssignedChallengesByChild(activeChild.id);

      result.fold(
        (failure) {
          status.value = ChildChallengeStatus.error;
          errorMessage.value = failure.message;
          isLoading.value = false;
          _logger.e("Error cargando retos del niño: ${failure.message}");
        },
        (loadedChallenges) async {
          // Guardar retos asignados
          assignedChallenges.assignAll(loadedChallenges);

          // Cargar los detalles de cada reto
          await _loadChallengeDetails();

          // Filtrar retos por estado
          _filterChallenges();

          status.value = ChildChallengeStatus.success;
          isLoading.value = false;
          _logger.i(
              "Retos del niño cargados con éxito: ${loadedChallenges.length}");
        },
      );
    } catch (e) {
      status.value = ChildChallengeStatus.error;
      errorMessage.value = TrKeys.unexpectedErrorMessage.tr;
      isLoading.value = false;
      _logger.e("Error inesperado al cargar retos del niño: $e");
    }
  }

  /// Carga los detalles de los retos asignados
  Future<void> _loadChallengeDetails() async {
    challenges.clear();

    for (final assignedChallenge in assignedChallenges) {
      final result = await _challengeRepository
          .getChallengeById(assignedChallenge.challengeId);

      result.fold(
        (failure) {
          _logger.w(
              "Error al cargar detalle de reto ${assignedChallenge.challengeId}: ${failure.message}");
        },
        (challenge) {
          challenges.add(challenge);
        },
      );
    }
  }

  /// Filtra los retos según el filtro y la búsqueda actuales
  void _filterChallenges() {
    final List<AssignedChallenge> filtered = [...assignedChallenges];

    // Filtrar por búsqueda
    if (searchQuery.value.isNotEmpty) {
      filtered.removeWhere((assignedChallenge) {
        final challenge = _findChallengeById(assignedChallenge.challengeId);
        if (challenge == null) return true;

        final title = challenge.title.toLowerCase();
        final description = challenge.description.toLowerCase();
        final query = searchQuery.value.toLowerCase();

        return !title.contains(query) && !description.contains(query);
      });
    }

    // Aplicar filtro seleccionado
    switch (selectedFilter.value) {
      case 'pending':
        pendingChallenges.assignAll(filtered.where((c) =>
            c.status == AssignedChallengeStatus.active ||
            c.status == AssignedChallengeStatus.pending));
        break;

      case 'completed':
        completedChallenges.assignAll(filtered
            .where((c) => c.status == AssignedChallengeStatus.completed));
        break;

      case 'daily':
        final challengeFrequencies = <String, ChallengeFrequency>{};

        // Obtener frecuencia de cada reto
        for (final assignedChallenge in filtered) {
          final challenge = _findChallengeById(assignedChallenge.challengeId);
          if (challenge != null) {
            challengeFrequencies[assignedChallenge.challengeId] =
                challenge.frequency;
          }
        }

        // Filtrar por retos diarios
        dailyChallenges.assignAll(filtered.where((c) =>
            challengeFrequencies[c.challengeId] == ChallengeFrequency.daily));
        break;

      case 'weekly':
        final challengeFrequencies = <String, ChallengeFrequency>{};

        // Obtener frecuencia de cada reto
        for (final assignedChallenge in filtered) {
          final challenge = _findChallengeById(assignedChallenge.challengeId);
          if (challenge != null) {
            challengeFrequencies[assignedChallenge.challengeId] =
                challenge.frequency;
          }
        }

        // Filtrar por retos semanales
        weeklyChallenges.assignAll(filtered.where((c) =>
            challengeFrequencies[c.challengeId] == ChallengeFrequency.weekly));
        break;

      case 'all':
      default:
        // Actualizar todas las listas filtradas
        pendingChallenges.assignAll(filtered.where((c) =>
            c.status == AssignedChallengeStatus.active ||
            c.status == AssignedChallengeStatus.pending));

        completedChallenges.assignAll(filtered
            .where((c) => c.status == AssignedChallengeStatus.completed));

        // Obtener frecuencia de cada reto
        final challengeFrequencies = <String, ChallengeFrequency>{};
        for (final assignedChallenge in filtered) {
          final challenge = _findChallengeById(assignedChallenge.challengeId);
          if (challenge != null) {
            challengeFrequencies[assignedChallenge.challengeId] =
                challenge.frequency;
          }
        }

        dailyChallenges.assignAll(filtered.where((c) =>
            challengeFrequencies[c.challengeId] == ChallengeFrequency.daily));

        weeklyChallenges.assignAll(filtered.where((c) =>
            challengeFrequencies[c.challengeId] == ChallengeFrequency.weekly));
        break;
    }
  }

  /// Cambia el filtro actual
  void changeFilter(String filter) {
    selectedFilter.value = filter;
    _filterChallenges();
  }

  /// Encuentra un reto por su ID
  Challenge? _findChallengeById(String challengeId) {
    return challenges
        .firstWhereOrNull((challenge) => challenge.id == challengeId);
  }

  /// Marca un reto como completado por el niño
  Future<void> markChallengeAsCompleted(String assignedChallengeId) async {
    isUpdating.value = true;

    try {
      final challenge = assignedChallenges
          .firstWhereOrNull((c) => c.id == assignedChallengeId);

      if (challenge == null) {
        _logger.w(
            "Reto no encontrado para marcar como completado: $assignedChallengeId");
        isUpdating.value = false;
        return;
      }

      // Obtener el reto completo para los puntos
      final challengeDetails = _findChallengeById(challenge.challengeId);
      if (challengeDetails == null) {
        _logger.w("Detalles del reto no encontrados: ${challenge.challengeId}");
        isUpdating.value = false;
        return;
      }

      // Actualizar estado en el repositorio (esto requiere intervención del padre para confirmar)
      // Solo marcamos como pendiente de aprobación
      final result = await _challengeRepository.evaluateAssignedChallenge(
        assignedChallengeId: assignedChallengeId,
        status: AssignedChallengeStatus.pending,
        points: 0, // Los puntos los asigna el padre al aprobar
        note: "Marcado como completado por el niño, pendiente de aprobación",
      );

      result.fold(
        (failure) {
          errorMessage.value = failure.message;
          _logger.e("Error al marcar reto como completado: ${failure.message}");
        },
        (_) async {
          // Recargar el reto actualizado
          final updatedResult = await _challengeRepository
              .getAssignedChallengeById(assignedChallengeId);

          updatedResult.fold(
            (failure) {
              _logger.w(
                  "Error al recargar reto después de actualizar: ${failure.message}");
            },
            (updatedChallenge) {
              // Actualizar en la lista local
              final index = assignedChallenges
                  .indexWhere((c) => c.id == assignedChallengeId);
              if (index != -1) {
                assignedChallenges[index] = updatedChallenge;
              }

              // Mostrar animación de celebración (simulado para la UI del niño)
              completedChallenge.value = updatedChallenge;
              pointsEarned.value = challengeDetails
                  .points; // Simulamos los puntos que podría ganar
              showCelebration.value = true;

              // Actualizar filtros
              _filterChallenges();

              _logger.i(
                  "Reto marcado como completado con éxito: $assignedChallengeId");

              // Auto-ocultar la celebración después de un tiempo
              Future.delayed(const Duration(seconds: 3), () {
                showCelebration.value = false;
              });
            },
          );
        },
      );
    } catch (e) {
      errorMessage.value = TrKeys.unexpectedErrorMessage.tr;
      _logger.e("Error inesperado al marcar reto como completado: $e");
    } finally {
      isUpdating.value = false;
    }
  }

  /// Carga más retos (para paginación)
  Future<void> loadMoreChallenges() async {
    if (!hasMoreChallenges.value || isLoading.value) return;

    page.value++;
    // Aquí implementaríamos la carga de más retos con paginación
    // Por ahora es un placeholder ya que no tenemos API con paginación
  }

  /// Obtiene el progreso del niño en porcentaje
  double getProgressPercentage() {
    if (assignedChallenges.isEmpty) return 0.0;

    final completed = assignedChallenges
        .where((c) => c.status == AssignedChallengeStatus.completed)
        .length;

    return completed / assignedChallenges.length;
  }

  /// Obtiene el número total de puntos ganados
  int getTotalPointsEarned() {
    return assignedChallenges.fold(
        0, (sum, challenge) => sum + challenge.pointsEarned);
  }

  /// Obtiene el número de retos completados
  int getCompletedChallengesCount() {
    return assignedChallenges
        .where((c) => c.status == AssignedChallengeStatus.completed)
        .length;
  }

  /// Obtiene el número de retos pendientes
  int getPendingChallengesCount() {
    return assignedChallenges
        .where((c) =>
            c.status == AssignedChallengeStatus.active ||
            c.status == AssignedChallengeStatus.pending)
        .length;
  }
}
