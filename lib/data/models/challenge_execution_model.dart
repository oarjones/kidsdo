import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidsdo/domain/entities/assigned_challenge.dart';
import 'package:kidsdo/domain/entities/challenge_execution.dart';

/// Modelo para mapear los datos de una ejecución de reto desde/hacia Firebase
class ChallengeExecutionModel extends ChallengeExecution {
  const ChallengeExecutionModel({
    required super.startDate,
    required super.endDate,
    required super.status,
    super.evaluations = const [],
  });

  /// Crea un ChallengeExecutionModel desde un mapa de Firestore
  factory ChallengeExecutionModel.fromFirestore(Map<String, dynamic> data) {
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

    return ChallengeExecutionModel(
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      status: _mapStringToStatus(data['status'] ?? 'pending'),
      evaluations: evaluations,
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
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': _statusToString(status),
      'evaluations': evaluationsList,
    };
  }

  /// Crea un ChallengeExecutionModel desde ChallengeExecution
  factory ChallengeExecutionModel.fromEntity(ChallengeExecution execution) {
    return ChallengeExecutionModel(
      startDate: execution.startDate,
      endDate: execution.endDate,
      status: execution.status,
      evaluations: execution.evaluations,
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
