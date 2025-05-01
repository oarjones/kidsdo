import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:kidsdo/data/models/challenge_model.dart';
import 'package:kidsdo/data/models/assigned_challenge_model.dart';
import 'package:kidsdo/data/models/challenge_execution_model.dart';
import 'package:kidsdo/domain/entities/assigned_challenge.dart';
import 'package:kidsdo/domain/entities/challenge.dart';
import 'package:kidsdo/domain/entities/challenge_execution.dart';
import 'package:logger/logger.dart';

abstract class IChallengeRemoteDataSource {
  /// Obtiene todos los retos para una familia
  Future<List<ChallengeModel>> getChallengesByFamily(String familyId);

  /// Obtiene retos predefinidos (templates)
  Future<List<ChallengeModel>> getPredefinedChallenges();

  /// Obtiene un reto por su id
  Future<ChallengeModel> getChallengeById(String challengeId);

  /// Crea un nuevo reto
  Future<ChallengeModel> createChallenge(ChallengeModel challenge);

  /// Actualiza un reto existente
  Future<void> updateChallenge(ChallengeModel challenge);

  /// Elimina un reto
  Future<void> deleteChallenge(String challengeId);

  /// Asigna un reto a un niño
  Future<AssignedChallengeModel> assignChallengeToChild({
    required String challengeId,
    required String childId,
    required String familyId,
    required DateTime startDate,
    DateTime? endDate,
    required String evaluationFrequency,
    bool isContinuous = false, // Nuevo parámetro para indicar si es continuo
  });

  /// Obtiene los retos asignados a un niño
  Future<List<AssignedChallengeModel>> getAssignedChallengesByChild(
      String childId);

  /// Obtiene un reto asignado por su id
  Future<AssignedChallengeModel> getAssignedChallengeById(
      String assignedChallengeId);

  /// Actualiza un reto asignado
  Future<void> updateAssignedChallenge(
      AssignedChallengeModel assignedChallenge);

  /// Elimina un reto asignado
  Future<void> deleteAssignedChallenge(String assignedChallengeId);

  /// Evalúa una ejecución específica de un reto asignado
  Future<void> evaluateExecution({
    required String assignedChallengeId,
    required int executionIndex,
    required AssignedChallengeStatus status,
    required int points,
    String? note,
  });

  /// Crea una nueva ejecución para un reto continuo
  Future<void> createNextExecution({
    required String assignedChallengeId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Evalúa un reto asignado (método legacy para compatibilidad)
  @Deprecated('Use evaluateExecution instead')
  Future<void> evaluateAssignedChallenge({
    required String assignedChallengeId,
    required AssignedChallengeStatus status,
    required int points,
    String? note,
  });

  Future<void> migrateLocalChallengesToFirestore(
      List<ChallengeModel> localChallenges);
}

class ChallengeRemoteDataSource implements IChallengeRemoteDataSource {
  final FirebaseFirestore _firestore;
  final String _challengesCollection = 'challenges';
  final String _assignedChallengesCollection = 'assignedChallenges';
  final String _predefinedChallengesCollection = 'predefinedChallenges';

  final Logger logger = Get.find<Logger>();

  ChallengeRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<List<ChallengeModel>> getChallengesByFamily(String familyId) async {
    final querySnapshot = await _firestore
        .collection(_challengesCollection)
        .where('familyId', isEqualTo: familyId)
        .get();

    return querySnapshot.docs
        .map((doc) => ChallengeModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<List<ChallengeModel>> getPredefinedChallenges() async {
    try {
      final querySnapshot =
          await _firestore.collection(_predefinedChallengesCollection).get();

      return querySnapshot.docs
          .map((doc) => ChallengeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      // En caso de error, registrarlo y devolver lista vacía
      // para que se use el respaldo local
      logger.i('Error loading predefined challenges from Firestore: $e');
      return [];
    }
  }

  @override
  Future<void> migrateLocalChallengesToFirestore(
      List<ChallengeModel> localChallenges) async {
    try {
      // Verificar primero si ya hay retos en Firestore
      final existingSnapshot = await _firestore
          .collection(_predefinedChallengesCollection)
          .limit(1)
          .get();

      // Si ya hay retos, no hacer nada
      if (existingSnapshot.docs.isNotEmpty) {
        return;
      }

      // Crear lotes para subir los datos (máximo 500 operaciones por lote)
      const int batchSize = 500;
      int currentIndex = 0;

      while (currentIndex < localChallenges.length) {
        final int endIndex = (currentIndex + batchSize < localChallenges.length)
            ? currentIndex + batchSize
            : localChallenges.length;

        final batch = _firestore.batch();

        for (int i = currentIndex; i < endIndex; i++) {
          final challenge = localChallenges[i];
          // Usar el ID existente o generar uno nuevo
          final docId = challenge.id.isNotEmpty && challenge.id != 'null'
              ? challenge.id
              : _firestore.collection(_predefinedChallengesCollection).doc().id;

          final docRef =
              _firestore.collection(_predefinedChallengesCollection).doc(docId);
          batch.set(docRef, challenge.toFirestore());
        }

        await batch.commit();
        currentIndex = endIndex;
      }

      logger.i(
          'Successfully migrated ${localChallenges.length} challenges to Firestore');
    } catch (e) {
      logger.i('Error migrating challenges to Firestore: $e');
      throw FirebaseException(
        plugin: 'firestore',
        code: 'migration-failed',
        message: 'Error migrating challenges to Firestore: $e',
      );
    }
  }

  @override
  Future<ChallengeModel> getChallengeById(String challengeId) async {
    final docSnapshot = await _firestore
        .collection(_challengesCollection)
        .doc(challengeId)
        .get();

    if (!docSnapshot.exists) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'not-found',
        message: 'Reto no encontrado',
      );
    }

    return ChallengeModel.fromFirestore(docSnapshot);
  }

  @override
  Future<ChallengeModel> createChallenge(ChallengeModel challenge) async {
    // Crear documento en Firestore
    final docRef = await _firestore.collection(_challengesCollection).add(
          challenge.toFirestore(),
        );

    // Obtener el documento recién creado
    final docSnapshot = await docRef.get();

    return ChallengeModel.fromFirestore(docSnapshot);
  }

  @override
  Future<void> updateChallenge(ChallengeModel challenge) async {
    await _firestore
        .collection(_challengesCollection)
        .doc(challenge.id)
        .update(challenge.toFirestore());
  }

  @override
  Future<void> deleteChallenge(String challengeId) async {
    await _firestore
        .collection(_challengesCollection)
        .doc(challengeId)
        .delete();
  }

  @override
  Future<AssignedChallengeModel> assignChallengeToChild({
    required String challengeId,
    required String childId,
    required String familyId,
    required DateTime startDate,
    DateTime? endDate,
    required String evaluationFrequency,
    bool isContinuous = false,
  }) async {
    // Obtener el reto original para conocer su duración
    final challenge = await getChallengeById(challengeId);

    // Crear la primera ejecución del reto
    final firstExecution = ChallengeExecutionModel(
      startDate: startDate,
      endDate: endDate ?? _calculateEndDate(startDate, challenge.duration),
      status: AssignedChallengeStatus.active,
      evaluations: [],
    );

    // Crear datos del reto asignado
    final Map<String, dynamic> assignedChallengeData = {
      'challengeId': challengeId,
      'childId': childId,
      'familyId': familyId,
      'status': 'active',
      'startDate': Timestamp.fromDate(startDate),
      'evaluationFrequency': evaluationFrequency,
      'pointsEarned': 0,
      'evaluations': [],
      'createdAt': Timestamp.now(),
      'isContinuous': isContinuous,
      'executions': [firstExecution.toFirestore()],
    };

    // Añadir endDate solo si no es nulo y no es continuo
    if (endDate != null && !isContinuous) {
      assignedChallengeData['endDate'] = Timestamp.fromDate(endDate);
    }

    // Crear documento en Firestore
    final docRef = await _firestore
        .collection(_assignedChallengesCollection)
        .add(assignedChallengeData);

    // Obtener el documento recién creado
    final docSnapshot = await docRef.get();

    return AssignedChallengeModel.fromFirestore(docSnapshot);
  }

  @override
  Future<List<AssignedChallengeModel>> getAssignedChallengesByChild(
      String childId) async {
    final querySnapshot = await _firestore
        .collection(_assignedChallengesCollection)
        .where('childId', isEqualTo: childId)
        .get();

    return querySnapshot.docs
        .map((doc) => AssignedChallengeModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<AssignedChallengeModel> getAssignedChallengeById(
      String assignedChallengeId) async {
    final docSnapshot = await _firestore
        .collection(_assignedChallengesCollection)
        .doc(assignedChallengeId)
        .get();

    if (!docSnapshot.exists) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'not-found',
        message: 'Reto asignado no encontrado',
      );
    }

    return AssignedChallengeModel.fromFirestore(docSnapshot);
  }

  @override
  Future<void> updateAssignedChallenge(
      AssignedChallengeModel assignedChallenge) async {
    await _firestore
        .collection(_assignedChallengesCollection)
        .doc(assignedChallenge.id)
        .update(assignedChallenge.toFirestore());
  }

  @override
  Future<void> deleteAssignedChallenge(String assignedChallengeId) async {
    await _firestore
        .collection(_assignedChallengesCollection)
        .doc(assignedChallengeId)
        .delete();
  }

  @override
  Future<void> evaluateExecution({
    required String assignedChallengeId,
    required int executionIndex,
    required AssignedChallengeStatus status,
    required int points,
    String? note,
  }) async {
    // Obtener reto asignado actual
    final assignedChallenge =
        await getAssignedChallengeById(assignedChallengeId);

    if (executionIndex < 0 ||
        executionIndex >= assignedChallenge.executions.length) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'invalid-argument',
        message: 'Índice de ejecución inválido',
      );
    }

    // Obtener la ejecución específica
    final List<ChallengeExecution> updatedExecutions =
        List.from(assignedChallenge.executions);
    final execution = updatedExecutions[executionIndex];

    // Crear nueva evaluación
    final evaluation = ChallengeEvaluation(
      date: DateTime.now(),
      status: status,
      points: points,
      note: note,
    );

    // Actualizar estado de la ejecución y añadir evaluación
    final updatedExecution = execution.copyWith(
      status: status,
      evaluations: [...execution.evaluations, evaluation],
    );
    updatedExecutions[executionIndex] = updatedExecution;

    // Actualizar puntos totales ganados
    final totalPoints = assignedChallenge.pointsEarned + points;

    // Determinar el nuevo estado global del reto asignado
    AssignedChallengeStatus newStatus = assignedChallenge.status;

    // Si es la ejecución actual (la última) y es completada/fallida
    if (executionIndex == assignedChallenge.executions.length - 1) {
      if (status == AssignedChallengeStatus.completed ||
          status == AssignedChallengeStatus.failed) {
        // Si es continuo, se mantiene activo para la siguiente ejecución
        // Si no es continuo, toma el estado de la evaluación
        newStatus = assignedChallenge.isContinuous
            ? AssignedChallengeStatus.active
            : status;
      }
    }

    // Crear modelo actualizado
    final updatedAssignedChallenge = assignedChallenge.copyWith(
      status: newStatus,
      pointsEarned: totalPoints,
      executions: updatedExecutions,
    );

    // Guardar en Firestore
    await updateAssignedChallenge(
        AssignedChallengeModel.fromEntity(updatedAssignedChallenge));
  }

  @override
  Future<void> createNextExecution({
    required String assignedChallengeId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Obtener reto asignado actual
    final assignedChallenge =
        await getAssignedChallengeById(assignedChallengeId);

    // Verificar que sea un reto continuo
    if (!assignedChallenge.isContinuous) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'invalid-argument',
        message:
            'No se puede crear una nueva ejecución para un reto no continuo',
      );
    }

    // Crear nueva ejecución
    final newExecution = ChallengeExecutionModel(
      startDate: startDate,
      endDate: endDate,
      status: AssignedChallengeStatus.active,
      evaluations: [],
    );

    // Añadir la nueva ejecución a la lista
    final updatedExecutions = [...assignedChallenge.executions, newExecution];

    // Actualizar el reto asignado
    final updatedAssignedChallenge = assignedChallenge.copyWith(
      executions: updatedExecutions,
      status:
          AssignedChallengeStatus.active, // Asegurar que el reto está activo
    );

    // Guardar en Firestore
    await updateAssignedChallenge(
        AssignedChallengeModel.fromEntity(updatedAssignedChallenge));
  }

  @override
  @Deprecated('Use evaluateExecution instead')
  Future<void> evaluateAssignedChallenge({
    required String assignedChallengeId,
    required AssignedChallengeStatus status,
    required int points,
    String? note,
  }) async {
    // Obtener reto asignado actual
    final assignedChallenge =
        await getAssignedChallengeById(assignedChallengeId);

    // Si tiene ejecuciones, evaluar la más reciente
    if (assignedChallenge.executions.isNotEmpty) {
      await evaluateExecution(
        assignedChallengeId: assignedChallengeId,
        executionIndex: assignedChallenge.executions.length - 1,
        status: status,
        points: points,
        note: note,
      );
      return;
    }

    // Si no tiene ejecuciones (compatibilidad con versiones antiguas)
    // Crear nueva evaluación
    final evaluation = ChallengeEvaluation(
      date: DateTime.now(),
      status: status,
      points: points,
      note: note,
    );

    // Actualizar puntos totales ganados
    final totalPoints = assignedChallenge.pointsEarned + points;

    // Actualizar estado del reto asignado (si es necesario)
    AssignedChallengeStatus newStatus = assignedChallenge.status;
    if (status == AssignedChallengeStatus.completed ||
        status == AssignedChallengeStatus.failed) {
      newStatus = assignedChallenge.isContinuous
          ? AssignedChallengeStatus.active
          : status;
    }

    // Añadir la evaluación a la lista
    final updatedEvaluations = [...assignedChallenge.evaluations, evaluation];

    // Crear modelo actualizado
    final updatedAssignedChallenge = assignedChallenge.copyWith(
      status: newStatus,
      pointsEarned: totalPoints,
      evaluations: updatedEvaluations,
    );

    // Guardar en Firestore
    await updateAssignedChallenge(
        AssignedChallengeModel.fromEntity(updatedAssignedChallenge));
  }

  // Método auxiliar para calcular la fecha de fin según la duración
  DateTime _calculateEndDate(DateTime startDate, ChallengeDuration duration) {
    switch (duration) {
      case ChallengeDuration.weekly:
        // Obtener el próximo domingo
        final int daysUntilSunday = 7 - startDate.weekday;
        return startDate.add(Duration(days: daysUntilSunday));

      case ChallengeDuration.monthly:
        // Último día del mes
        final nextMonth = startDate.month < 12
            ? DateTime(startDate.year, startDate.month + 1, 1)
            : DateTime(startDate.year + 1, 1, 1);
        return nextMonth.subtract(const Duration(days: 1));

      case ChallengeDuration.quarterly:
        // Último día del trimestre actual
        final int currentQuarter = (startDate.month - 1) ~/ 3;
        final int lastMonthOfQuarter = (currentQuarter + 1) * 3;
        final nextQuarter = lastMonthOfQuarter < 12
            ? DateTime(startDate.year, lastMonthOfQuarter + 1, 1)
            : DateTime(startDate.year + 1, 1, 1);
        return nextQuarter.subtract(const Duration(days: 1));

      case ChallengeDuration.yearly:
        // Último día del año
        return DateTime(startDate.year, 12, 31);

      case ChallengeDuration.punctual:
      default:
        // Por defecto, una semana
        return startDate.add(const Duration(days: 7));
    }
  }
}
