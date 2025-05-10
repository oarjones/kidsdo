import 'package:equatable/equatable.dart';
import 'challenge_execution.dart';
import 'challenge.dart'; // Asegúrate de importar la entidad Challenge si aún no está

/// Enumeración de estados de retos asignados
enum AssignedChallengeStatus {
  active, // Activo
  completed, // Completado
  failed, // Fallido
  pending, // Pendiente
  inactive, // Inactivo (para retos no continuos que han terminado)
}

/// Clase para las evaluaciones de un reto
class ChallengeEvaluation extends Equatable {
  final DateTime date;
  final AssignedChallengeStatus status;
  final int points;
  final String? note;

  const ChallengeEvaluation({
    required this.date,
    required this.status,
    required this.points,
    this.note,
  });

  @override
  List<Object?> get props => [date, status, points, note];

  ChallengeEvaluation copyWith({
    DateTime? date,
    AssignedChallengeStatus? status,
    int? points,
    String? note,
  }) {
    return ChallengeEvaluation(
      date: date ?? this.date,
      status: status ?? this.status,
      points: points ?? this.points,
      note: note ?? this.note,
    );
  }
}

/// Entidad que representa un reto asignado a un niño
class AssignedChallenge extends Equatable {
  final String id;
  final String challengeId; // ID del reto original
  final String childId;
  final String familyId;
  final AssignedChallengeStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final int pointsEarned;
  final DateTime createdAt;
  final bool isContinuous; // Indica si el reto se reinicia automáticamente
  final List<ChallengeExecution> executions; // Lista de ejecuciones del reto

  // --- NUEVOS CAMPOS: Detalles del reto original sincronizados ---
  final String originalChallengeTitle;
  final String originalChallengeDescription;
  final int originalChallengePoints; // Puntos base del reto original
  final ChallengeDuration originalChallengeDuration;
  final ChallengeCategory originalChallengeCategory;
  final String? originalChallengeIcon; // Icono del reto original
  final Map<String, dynamic>
      originalChallengeAgeRange; // Rango de edad original
  // ------------------------------------------------------------

  const AssignedChallenge({
    required this.id,
    required this.challengeId,
    required this.childId,
    required this.familyId,
    required this.status,
    required this.startDate,
    this.endDate,
    this.pointsEarned = 0,
    required this.createdAt,
    this.isContinuous = false,
    this.executions = const [],
    // --- Inicialización de nuevos campos ---
    required this.originalChallengeTitle,
    required this.originalChallengeDescription,
    required this.originalChallengePoints,
    required this.originalChallengeDuration,
    required this.originalChallengeCategory,
    this.originalChallengeIcon,
    required this.originalChallengeAgeRange,
    // -------------------------------------
  });

  @override
  List<Object?> get props => [
        id,
        challengeId,
        childId,
        familyId,
        status,
        startDate,
        endDate,
        pointsEarned,
        createdAt,
        isContinuous,
        executions,
        // --- Añadir nuevos campos a props ---
        originalChallengeTitle,
        originalChallengeDescription,
        originalChallengePoints,
        originalChallengeDuration,
        originalChallengeCategory,
        originalChallengeIcon,
        originalChallengeAgeRange,
        // ---------------------------------
      ];

  AssignedChallenge copyWith({
    String? id,
    String? challengeId,
    String? childId,
    String? familyId,
    AssignedChallengeStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int? pointsEarned,
    DateTime? createdAt,
    bool? isContinuous,
    List<ChallengeExecution>? executions,
    // --- copyWith para nuevos campos ---
    String? originalChallengeTitle,
    String? originalChallengeDescription,
    int? originalChallengePoints,
    ChallengeDuration? originalChallengeDuration,
    ChallengeCategory? originalChallengeCategory,
    String? originalChallengeIcon,
    Map<String, dynamic>? originalChallengeAgeRange,
    // ---------------------------------
  }) {
    return AssignedChallenge(
      id: id ?? this.id,
      challengeId: challengeId ?? this.challengeId,
      childId: childId ?? this.childId,
      familyId: familyId ?? this.familyId,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate, // Puede ser null
      pointsEarned: pointsEarned ?? this.pointsEarned,
      createdAt: createdAt ?? this.createdAt,
      isContinuous: isContinuous ?? this.isContinuous,
      executions: executions ?? this.executions,
      // --- Copiar nuevos campos ---
      originalChallengeTitle:
          originalChallengeTitle ?? this.originalChallengeTitle,
      originalChallengeDescription:
          originalChallengeDescription ?? this.originalChallengeDescription,
      originalChallengePoints:
          originalChallengePoints ?? this.originalChallengePoints,
      originalChallengeDuration:
          originalChallengeDuration ?? this.originalChallengeDuration,
      originalChallengeCategory:
          originalChallengeCategory ?? this.originalChallengeCategory,
      originalChallengeIcon:
          originalChallengeIcon ?? this.originalChallengeIcon,
      originalChallengeAgeRange:
          originalChallengeAgeRange ?? this.originalChallengeAgeRange,
      // ---------------------------
    );
  }

  /// Verifica si este es un reto continuo
  bool get isContinuousChallenge => isContinuous;

  /// Obtiene la ejecución actual del reto
  ChallengeExecution? get currentExecution {
    if (executions.isEmpty) return null;

    // La ejecución actual es la última que no ha sido evaluada (estado active o pending)
    try {
      return executions.lastWhere(
        (execution) =>
            execution.status == AssignedChallengeStatus.active ||
            execution.status == AssignedChallengeStatus.pending,
      );
    } catch (e) {
      // Si no hay ninguna ejecución activa o pendiente, puede que sea la última
      // evaluada si ya terminó el ciclo o el reto no es continuo.
      // En este contexto, 'currentExecution' para UI de padres debería ser la
      // que necesita evaluación o la última si ya se evaluó.
      // Si no hay activas/pendientes, devolver la última (esté evaluada o no)
      return executions.isNotEmpty ? executions.last : null;
    }
  }

  /// Obtiene el último resultado de evaluación para la ejecución actual
  ChallengeEvaluation? get latestEvaluationForCurrentExecution {
    return currentExecution?.evaluation;
  }

  /// Obtiene el estado de la ejecución actual (o del reto asignado si no hay ejecuciones)
  AssignedChallengeStatus get currentStatus {
    return currentExecution?.status ?? status;
  }

  /// Calcula la fecha de fin de la ejecución actual
  DateTime? get currentEndDate {
    return currentExecution?.endDate;
  }
}
