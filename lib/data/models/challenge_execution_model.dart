import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidsdo/domain/entities/assigned_challenge.dart';
import 'package:kidsdo/domain/entities/challenge_execution.dart';

/// Modelo para mapear los datos de una ejecución de reto desde/hacia Firebase
class ChallengeExecutionModel extends ChallengeExecution {
  const ChallengeExecutionModel({
    required super.startDate,
    required super.endDate,
    required super.status,
    super.evaluation,
  });

  /// Crea un ChallengeExecutionModel desde un mapa de Firestore
  factory ChallengeExecutionModel.fromFirestore(Map<String, dynamic> data) {
    // Extraer la evaluación si existe
    ChallengeEvaluation? evaluation;
    if (data['evaluation'] != null) {
      final evalData = data['evaluation'] as Map<String, dynamic>;
      evaluation = ChallengeEvaluation(
        date: (evalData['date'] as Timestamp).toDate(),
        status: _mapStringToStatus(evalData['status']),
        points: evalData['points'] ?? 0,
        note: evalData['note'],
      );
    }

    return ChallengeExecutionModel(
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      status: _mapStringToStatus(data['status'] ?? 'pending'),
      evaluation: evaluation,
    );
  }

  /// Convierte el modelo a un mapa para Firestore
  Map<String, dynamic> toFirestore() {
    final Map<String, dynamic> data = {
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': _statusToString(status),
    };

    // Añadir evaluación solo si existe
    if (evaluation != null) {
      data['evaluation'] = {
        'date': Timestamp.fromDate(evaluation!.date),
        'status': _statusToString(evaluation!.status),
        'points': evaluation!.points,
        'note': evaluation!.note,
      };
    }

    return data;
  }

  /// Crea un ChallengeExecutionModel desde ChallengeExecution
  factory ChallengeExecutionModel.fromEntity(ChallengeExecution execution) {
    return ChallengeExecutionModel(
      startDate: execution.startDate,
      endDate: execution.endDate,
      status: execution.status,
      evaluation: execution.evaluation,
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
      case 'inactive':
        return AssignedChallengeStatus.inactive;
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
      case AssignedChallengeStatus.inactive:
        return 'inactive';
    }
  }
}
