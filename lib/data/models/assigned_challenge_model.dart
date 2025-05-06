import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidsdo/data/models/challenge_execution_model.dart';
import 'package:kidsdo/domain/entities/assigned_challenge.dart';
import 'package:kidsdo/domain/entities/challenge_execution.dart';

/// Modelo para mapear los datos de un reto asignado desde/hacia Firebase
class AssignedChallengeModel extends AssignedChallenge {
  const AssignedChallengeModel({
    required super.id,
    required super.challengeId,
    required super.childId,
    required super.familyId,
    required super.status,
    required super.startDate,
    super.endDate,
    super.pointsEarned = 0,
    required super.createdAt,
    super.isContinuous = false,
    super.executions = const [],
  });

  /// Crea un AssignedChallengeModel desde un documento de Firestore
  factory AssignedChallengeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Mapear las ejecuciones
    List<ChallengeExecution> executions = [];
    if (data['executions'] != null) {
      final execList = data['executions'] as List;
      executions = execList.map((e) {
        return ChallengeExecutionModel.fromFirestore(e as Map<String, dynamic>);
      }).toList();
    }

    return AssignedChallengeModel(
      id: doc.id,
      challengeId: data['challengeId'] ?? '',
      childId: data['childId'] ?? '',
      familyId: data['familyId'] ?? '',
      status: _mapStringToStatus(data['status'] ?? 'pending'),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      pointsEarned: data['pointsEarned'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isContinuous: data['isContinuous'] ?? false,
      executions: executions,
    );
  }

  /// Convierte el modelo a un mapa para Firestore
  Map<String, dynamic> toFirestore() {
    // Convertir las ejecuciones a lista de mapas
    final List<Map<String, dynamic>> executionsList = executions.map((e) {
      if (e is ChallengeExecutionModel) {
        return e.toFirestore();
      }
      return ChallengeExecutionModel.fromEntity(e).toFirestore();
    }).toList();

    final Map<String, dynamic> data = {
      'challengeId': challengeId,
      'childId': childId,
      'familyId': familyId,
      'status': _statusToString(status),
      'startDate': Timestamp.fromDate(startDate),
      'pointsEarned': pointsEarned,
      'createdAt': Timestamp.fromDate(createdAt),
      'isContinuous': isContinuous,
      'executions': executionsList,
    };

    // Solo añadir endDate si no es nulo
    if (endDate != null) {
      data['endDate'] = Timestamp.fromDate(endDate!);
    }

    return data;
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
      pointsEarned: assignedChallenge.pointsEarned,
      createdAt: assignedChallenge.createdAt,
      isContinuous: assignedChallenge.isContinuous,
      executions: assignedChallenge.executions,
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
