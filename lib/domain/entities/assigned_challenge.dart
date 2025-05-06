import 'package:equatable/equatable.dart';
import 'challenge_execution.dart';

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
  final String challengeId;
  final String childId;
  final String familyId;
  final AssignedChallengeStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final int pointsEarned;
  final DateTime createdAt;
  final bool isContinuous; // Indica si el reto se reinicia automáticamente
  final List<ChallengeExecution> executions; // Lista de ejecuciones del reto

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
    );
  }

  /// Verifica si este es un reto continuo
  bool get isContinuousChallenge => isContinuous;

  /// Obtiene la ejecución actual del reto
  ChallengeExecution? get currentExecution {
    if (executions.isEmpty) return null;

    // La ejecución actual es la más reciente en la lista
    try {
      return executions.lastWhere(
        (execution) =>
            execution.status == AssignedChallengeStatus.active ||
            execution.status == AssignedChallengeStatus.pending,
      );
    } catch (e) {
      // Si no hay ninguna ejecución activa o pendiente, devolver la última
      return executions.isNotEmpty ? executions.last : null;
    }
  }
}
