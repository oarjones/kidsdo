import 'package:equatable/equatable.dart';
import 'assigned_challenge.dart';

/// Clase para representar una ejecución específica de un reto
class ChallengeExecution extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final AssignedChallengeStatus status;
  final List<ChallengeEvaluation> evaluations;

  const ChallengeExecution({
    required this.startDate,
    required this.endDate,
    required this.status,
    this.evaluations = const [],
  });

  @override
  List<Object?> get props => [startDate, endDate, status, evaluations];

  ChallengeExecution copyWith({
    DateTime? startDate,
    DateTime? endDate,
    AssignedChallengeStatus? status,
    List<ChallengeEvaluation>? evaluations,
  }) {
    return ChallengeExecution(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      evaluations: evaluations ?? this.evaluations,
    );
  }
}
