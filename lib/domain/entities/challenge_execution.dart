import 'package:equatable/equatable.dart';
import 'assigned_challenge.dart';

/// Clase para representar una ejecución específica de un reto
class ChallengeExecution extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final AssignedChallengeStatus status;
  final ChallengeEvaluation?
      evaluation; // Cambio de lista a un solo objeto opcional

  const ChallengeExecution({
    required this.startDate,
    required this.endDate,
    required this.status,
    this.evaluation, // Ahora es opcional
  });

  @override
  List<Object?> get props => [startDate, endDate, status, evaluation];

  ChallengeExecution copyWith({
    DateTime? startDate,
    DateTime? endDate,
    AssignedChallengeStatus? status,
    ChallengeEvaluation? evaluation,
  }) {
    return ChallengeExecution(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      evaluation: evaluation, // No usamos ?? para permitir establecerlo a null
    );
  }
}
