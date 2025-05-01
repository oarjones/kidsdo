import 'package:equatable/equatable.dart';

/// Enumeración de estados de retos asignados
enum AssignedChallengeStatus {
  active, // Activo
  completed, // Completado
  failed, // Fallido
  pending, // Pendiente
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
  final DateTime? endDate; // Ahora puede ser nulo para retos continuos
  final String evaluationFrequency; // 'daily', 'weekly'
  final int pointsEarned;
  final List<ChallengeEvaluation> evaluations;
  final DateTime createdAt;

  const AssignedChallenge({
    required this.id,
    required this.challengeId,
    required this.childId,
    required this.familyId,
    required this.status,
    required this.startDate,
    this.endDate, // Ya no es required
    required this.evaluationFrequency,
    this.pointsEarned = 0,
    this.evaluations = const [],
    required this.createdAt,
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
        evaluationFrequency,
        pointsEarned,
        evaluations,
        createdAt,
      ];

  AssignedChallenge copyWith({
    String? id,
    String? challengeId,
    String? childId,
    String? familyId,
    AssignedChallengeStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? evaluationFrequency,
    int? pointsEarned,
    List<ChallengeEvaluation>? evaluations,
    DateTime? createdAt,
  }) {
    return AssignedChallenge(
      id: id ?? this.id,
      challengeId: challengeId ?? this.challengeId,
      childId: childId ?? this.childId,
      familyId: familyId ?? this.familyId,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate, // Manejo especial - puede establecerse a null
      evaluationFrequency: evaluationFrequency ?? this.evaluationFrequency,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      evaluations: evaluations ?? this.evaluations,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Verifica si este es un reto continuo (sin fecha de fin)
  bool get isContinuous => endDate == null;
}
