import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidsdo/data/models/challenge_execution_model.dart';
import 'package:kidsdo/domain/entities/assigned_challenge.dart';
import 'package:kidsdo/domain/entities/challenge_execution.dart';
import 'package:kidsdo/domain/entities/challenge.dart'; // Importar Challenge para las enumeraciones

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
    // --- Inicialización de nuevos campos heredados ---
    required super.originalChallengeTitle,
    required super.originalChallengeDescription,
    required super.originalChallengePoints,
    required super.originalChallengeDuration,
    required super.originalChallengeCategory,
    super.originalChallengeIcon,
    required super.originalChallengeAgeRange,
    // ------------------------------------------------
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
      // --- Mapeo de nuevos campos desde Firestore ---
      originalChallengeTitle: data['originalChallengeTitle'] ?? '',
      originalChallengeDescription: data['originalChallengeDescription'] ?? '',
      originalChallengePoints: data['originalChallengePoints'] ?? 0,
      originalChallengeDuration:
          _mapStringToDuration(data['originalChallengeDuration'] ?? 'weekly'),
      originalChallengeCategory:
          _mapStringToCategory(data['originalChallengeCategory'] ?? 'hygiene'),
      originalChallengeIcon: data['originalChallengeIcon'],
      originalChallengeAgeRange:
          data['originalChallengeAgeRange'] as Map<String, dynamic>? ??
              {'min': 0, 'max': 18},
      // ---------------------------------------------
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
      // --- Mapeo de nuevos campos hacia Firestore ---
      'originalChallengeTitle': originalChallengeTitle,
      'originalChallengeDescription': originalChallengeDescription,
      'originalChallengePoints': originalChallengePoints,
      'originalChallengeDuration': _durationToString(originalChallengeDuration),
      'originalChallengeCategory': _categoryToString(originalChallengeCategory),
      'originalChallengeIcon': originalChallengeIcon,
      'originalChallengeAgeRange': originalChallengeAgeRange,
      // --------------------------------------------
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
    // Al crear desde una entidad, poblamos los campos originales
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
      // --- Poblar nuevos campos desde la entidad ---
      originalChallengeTitle: assignedChallenge.originalChallengeTitle,
      originalChallengeDescription:
          assignedChallenge.originalChallengeDescription,
      originalChallengePoints: assignedChallenge.originalChallengePoints,
      originalChallengeDuration: assignedChallenge.originalChallengeDuration,
      originalChallengeCategory: assignedChallenge.originalChallengeCategory,
      originalChallengeIcon: assignedChallenge.originalChallengeIcon,
      originalChallengeAgeRange: assignedChallenge.originalChallengeAgeRange,
      // ---------------------------------------------
    );
  }

  // Métodos de ayuda para mapear enumeraciones (ya existen en ChallengeModel, podemos copiarlos o refactorizar)
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

  // Nuevos métodos para mapear ChallengeCategory y ChallengeDuration
  static ChallengeCategory _mapStringToCategory(String category) {
    switch (category) {
      case 'hygiene':
        return ChallengeCategory.hygiene;
      case 'school':
        return ChallengeCategory.school;
      case 'order':
        return ChallengeCategory.order;
      case 'responsibility':
        return ChallengeCategory.responsibility;
      case 'help':
        return ChallengeCategory.help;
      case 'special':
        return ChallengeCategory.special;
      case 'sibling':
        return ChallengeCategory.sibling;
      default:
        return ChallengeCategory.hygiene;
    }
  }

  static String _categoryToString(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.hygiene:
        return 'hygiene';
      case ChallengeCategory.school:
        return 'school';
      case ChallengeCategory.order:
        return 'order';
      case ChallengeCategory.responsibility:
        return 'responsibility';
      case ChallengeCategory.help:
        return 'help';
      case ChallengeCategory.special:
        return 'special';
      case ChallengeCategory.sibling:
        return 'sibling';
    }
  }

  static ChallengeDuration _mapStringToDuration(String duration) {
    switch (duration) {
      case 'weekly':
        return ChallengeDuration.weekly;
      case 'monthly':
        return ChallengeDuration.monthly;
      case 'quarterly':
        return ChallengeDuration.quarterly;
      case 'yearly':
        return ChallengeDuration.yearly;
      case 'punctual':
        return ChallengeDuration.punctual;
      default:
        return ChallengeDuration.weekly;
    }
  }

  static String _durationToString(ChallengeDuration duration) {
    switch (duration) {
      case ChallengeDuration.weekly:
        return 'weekly';
      case ChallengeDuration.monthly:
        return 'monthly';
      case ChallengeDuration.quarterly:
        return 'quarterly';
      case ChallengeDuration.yearly:
        return 'yearly';
      case ChallengeDuration.punctual:
        return 'punctual';
    }
  }
}
