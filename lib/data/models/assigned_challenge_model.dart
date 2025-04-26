import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidsdo/domain/entities/assigned_challenge.dart';

/// Modelo para mapear los datos de un reto asignado desde/hacia Firebase
class AssignedChallengeModel extends AssignedChallenge {
  const AssignedChallengeModel({
    required super.id,
    required super.challengeId,
    required super.childId,
    required super.familyId,
    required super.status,
    required super.startDate,
    required super.endDate,
    required super.evaluationFrequency,
    super.pointsEarned = 0,
    super.evaluations = const [],
    required super.createdAt,
  });

  /// Crea un AssignedChallengeModel desde un documento de Firestore
  factory AssignedChallengeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Mapear las evaluaciones
    List<ChallengeEvaluation> evaluations = [];
    if (data['evaluations'] != null) {
      final evalList = data['evaluations'] as List;
      evaluations = evalList.map((e) {
        return ChallengeEvaluation(
          date: (e['date'] as Timestamp).toDate(),
          status: _mapStringToStatus(e['status']),
          points: e['points'] ?? 0,
          note: e['note'],
        );
      }).toList();
    }

    return AssignedChallengeModel(
      id: doc.id,
      challengeId: data['challengeId'] ?? '',
      childId: data['childId'] ?? '',
      familyId: data['familyId'] ?? '',
      status: _mapStringToStatus(data['status'] ?? 'pending'),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      evaluationFrequency: data['evaluationFrequency'] ?? 'daily',
      pointsEarned: data['pointsEarned'] ?? 0,
      evaluations: evaluations,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Convierte el modelo a un mapa para Firestore
  Map<String, dynamic> toFirestore() {
    // Convertir las evaluaciones a lista de mapas
    final List<Map<String, dynamic>> evaluationsList = evaluations.map((e) {
      return {
        'date': Timestamp.fromDate(e.date),
        'status': _statusToString(e.status),
        'points': e.points,
        'note': e.note,
      };
    }).toList();

    return {
      'challengeId': challengeId,
      'childId': childId,
      'familyId': familyId,
      'status': _statusToString(status),
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'evaluationFrequency': evaluationFrequency,
      'pointsEarned': pointsEarned,
      'evaluations': evaluationsList,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Crea un AssignedChallengeModel desde AssignedChallenge
  factory AssignedChallengeModel.fromEntity(
      AssignedChallenge assignedChallenge) {
    return AssignedChallengeModel(
      id: assignedChallenge.id,
      challengeId: assignedChallenge.challengeId,
      childId: assignedChallenge.childId,
      familyId: assignedChallenge.familyId,
      status: assignedChallenge.status,
      startDate: assignedChallenge.startDate,
      endDate: assignedChallenge.endDate,
      evaluationFrequency: assignedChallenge.evaluationFrequency,
      pointsEarned: assignedChallenge.pointsEarned,
      evaluations: assignedChallenge.evaluations,
      createdAt: assignedChallenge.createdAt,
    );
  }

  // Métodos de ayuda para mapear enumeraciones
  static AssignedChallengeStatus _mapStringToStatus(String status) {
    switch (status) {
      case 'active':
        return AssignedChallengeStatus.active;
      case 'completed':
        return AssignedChallengeStatus.completed;
      case 'failed':
        return AssignedChallengeStatus.failed;
      case 'pending':
        return AssignedChallengeStatus.pending;
      default:
        return AssignedChallengeStatus.pending;
    }
  }

  static String _statusToString(AssignedChallengeStatus status) {
    switch (status) {
      case AssignedChallengeStatus.active:
        return 'active';
      case AssignedChallengeStatus.completed:
        return 'completed';
      case AssignedChallengeStatus.failed:
        return 'failed';
      case AssignedChallengeStatus.pending:
        return 'pending';
    }
  }
}
