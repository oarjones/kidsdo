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
    bool isContinuous = false,
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
    // Este método podría necesitar buscar en retos familiares O predefinidos
    // si no hay una distinción clara al asignar.
    // Por ahora, asumiremos que busca en la colección 'challenges'
    // (donde se guardan los retos familiares y los templates importados a la familia)
    // o en 'predefinedChallenges' si no se encuentra en la primera.

    final docSnapshot = await _firestore
        .collection(_challengesCollection)
        .doc(challengeId)
        .get();

    if (docSnapshot.exists) {
      return ChallengeModel.fromFirestore(docSnapshot);
    } else {
      // Intentar buscar en la colección de retos predefinidos si no está en la de familia
      final predefinedDocSnapshot = await _firestore
          .collection(_predefinedChallengesCollection)
          .doc(challengeId)
          .get();

      if (predefinedDocSnapshot.exists) {
        return ChallengeModel.fromFirestore(predefinedDocSnapshot);
      }

      throw FirebaseException(
        plugin: 'firestore',
        code: 'not-found',
        message: 'Reto no encontrado',
      );
    }
  }

  @override
  Future<ChallengeModel> createChallenge(ChallengeModel challenge) async {
    // Determinar la colección según si es un template o un reto familiar
    final collectionRef = challenge.isTemplate && challenge.familyId == null
        ? _firestore.collection(
            _predefinedChallengesCollection) // Guardar templates en colección separada
        : _firestore.collection(
            _challengesCollection); // Retos familiares o templates importados a familia

    // Crear documento en Firestore
    final docRef = await collectionRef.add(
      challenge.toFirestore(),
    );

    // Obtener el documento recién creado
    final docSnapshot = await docRef.get();

    // Devolver el modelo creado (que ahora tendrá el ID)
    return ChallengeModel.fromFirestore(docSnapshot);
  }

  @override
  Future<void> updateChallenge(ChallengeModel challenge) async {
    // Determinar la colección según si es un template o un reto familiar
    final collectionRef = challenge.isTemplate && challenge.familyId == null
        ? _firestore.collection(_predefinedChallengesCollection)
        : _firestore.collection(_challengesCollection);

    await collectionRef.doc(challenge.id).update(challenge.toFirestore());
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
    bool isContinuous = false,
  }) async {
    // Obtener el reto original para conocer sus propiedades
    final challenge =
        await getChallengeById(challengeId); // <-- Usamos el método actualizado

    // Crear la primera ejecución del reto
    final firstExecution = ChallengeExecutionModel(
      startDate: startDate,
      endDate: endDate ??
          _calculateEndDate(startDate,
              challenge.duration), // Usar la duración del reto original
      status: AssignedChallengeStatus.active,
      evaluation: null, // Sin evaluación inicial
    );

    // Crear datos del reto asignado, incluyendo detalles del reto original
    final Map<String, dynamic> assignedChallengeData = {
      'challengeId': challengeId,
      'childId': childId,
      'familyId': familyId,
      'status': 'active', // Inicialmente activo
      'startDate': Timestamp.fromDate(startDate),
      'pointsEarned': 0,
      'createdAt': Timestamp.now(),
      'isContinuous': isContinuous,
      'executions': [firstExecution.toFirestore()],

      // --- Guardar detalles del reto original ---
      'originalChallengeTitle': challenge.title,
      'originalChallengeDescription': challenge.description,
      'originalChallengePoints': challenge.points,
      'originalChallengeDuration': _durationToString(challenge.duration),
      'originalChallengeCategory': _categoryToString(challenge.category),
      'originalChallengeIcon': challenge.icon,
      'originalChallengeAgeRange': challenge.ageRange,
      // -----------------------------------------
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

    // Devolver el modelo creado (que ahora tendrá el ID)
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

    // Crear evaluación
    final evaluation = ChallengeEvaluation(
      date: DateTime.now(),
      status: status,
      points: points,
      note: note,
    );

    // Actualizar estado de la ejecución y asignar evaluación
    final updatedExecution = execution.copyWith(
      status: status,
      evaluation: evaluation, // Asignar directamente
    );
    updatedExecutions[executionIndex] = updatedExecution;

    // Actualizar puntos totales ganados
    // Sumar los puntos de *esta* evaluación a los puntos totales existentes
    final totalPoints = assignedChallenge.pointsEarned + points;

    // Determinar el nuevo estado global del reto asignado
    AssignedChallengeStatus newStatus = assignedChallenge.status;

    // Verificar si necesitamos crear una nueva ejecución
    bool shouldCreateNextExecution = false;

    // Si es la última ejecución del reto asignado...
    if (executionIndex == assignedChallenge.executions.length - 1) {
      // Si la evaluación es completado o fallido...
      if (status == AssignedChallengeStatus.completed ||
          status == AssignedChallengeStatus.failed) {
        // Si es un reto continuo, mantener activo y crear nueva ejecución
        if (assignedChallenge.isContinuous) {
          newStatus = AssignedChallengeStatus
              .active; // El estado global vuelve a ser activo para la siguiente ejecución
          shouldCreateNextExecution = true;
        } else {
          // Para retos no continuos, tomar el estado final de la evaluación
          newStatus = status; // El estado global es completado o fallido
        }
      }
      // Si la evaluación es 'pending' o 'active' (aunque active no debería ser un estado de evaluación)
      // Mantener el estado global como 'active' si el reto es continuo, o el estado de la ejecución si no.
      // Sin embargo, según el plan, 'pending' es un estado temporal de la ejecución,
      // la evaluación por padre será completed/failed/pending.
      // Si el padre evalúa como pending, el estado global podría seguir como active si no es la última ejecución.
      // Si es la última ejecución y el padre evalúa como pending, el estado global podría quedarse en pending
      else if (status == AssignedChallengeStatus.pending) {
        // Si la última ejecución se evalúa como pending, el estado global se queda como pending.
        newStatus = AssignedChallengeStatus.pending;
        // No crear nueva ejecución hasta que se evalúe como completed/failed
      } else if (status == AssignedChallengeStatus.active) {
        // Estado 'active' no debería usarse en evaluación final, pero si ocurriera:
        // Mantener estado global como active
        newStatus = AssignedChallengeStatus.active;
        // No crear nueva ejecución
      }
    } else {
      // Si no es la última ejecución del reto asignado, el estado global sigue siendo active (si el reto es continuo)
      // o el estado que tuviera antes (si no es continuo)
      if (assignedChallenge.isContinuous) {
        newStatus = AssignedChallengeStatus.active;
      } else {
        // Mantener el estado global que tenía el AssignedChallenge antes de esta evaluación de ejecución
        // Esto podría requerir obtener el estado anterior del AssignedChallenge antes de modificarlo.
        // Por simplicidad, si no es la última ejecución de un reto NO continuo,
        // el estado global probablemente ya estaba completado/fallido, o debería haber sido evaluado antes.
        // Mantendremos el estado global que tenía antes de la llamada a este método.
      }
      // No crear nueva ejecución si no es la última
    }

    // Actualizar el reto asignado
    final updatedAssignedChallenge = assignedChallenge.copyWith(
      status: newStatus, // Usar el nuevo estado global calculado
      pointsEarned: totalPoints,
      executions: updatedExecutions,
    );

    // Guardar en Firestore
    await updateAssignedChallenge(
        AssignedChallengeModel.fromEntity(updatedAssignedChallenge));

    // Si es necesario, crear la siguiente ejecución para retos continuos
    if (shouldCreateNextExecution) {
      // Obtener el reto original para conocer la duración
      // Ya tenemos los detalles en originalChallengeDuration
      final challengeDuration = assignedChallenge.originalChallengeDuration;

      // Calcular fechas para la nueva ejecución
      final nextStartDate = DateTime.now(); // La nueva ejecución comienza hoy
      final nextEndDate = _calculateEndDate(nextStartDate, challengeDuration);

      await createNextExecution(
        assignedChallengeId: assignedChallengeId,
        startDate: nextStartDate,
        endDate: nextEndDate,
      );
    }
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
      evaluation: null, // Sin evaluación inicial
    );

    // Añadir la nueva ejecución a la lista
    final updatedExecutions = [...assignedChallenge.executions, newExecution];

    // Actualizar el reto asignado
    final updatedAssignedChallenge = assignedChallenge.copyWith(
      executions: updatedExecutions,
      status: AssignedChallengeStatus.active,
    );

    // Guardar en Firestore
    await updateAssignedChallenge(
        AssignedChallengeModel.fromEntity(updatedAssignedChallenge));
  }

  // @override
  // @Deprecated('Use evaluateExecution instead')
  // Future<void> evaluateAssignedChallenge({
  //   required String assignedChallengeId,
  //   required AssignedChallengeStatus status,
  //   required int points,
  //   String? note,
  // }) async {
  //   // Obtener reto asignado actual
  //   final assignedChallenge =
  //       await getAssignedChallengeById(assignedChallengeId);

  //   // Si tiene ejecuciones, evaluar la más reciente
  //   if (assignedChallenge.executions.isNotEmpty) {
  //     await evaluateExecution(
  //       assignedChallengeId: assignedChallengeId,
  //       executionIndex: assignedChallenge.executions.length - 1,
  //       status: status,
  //       points: points,
  //       note: note,
  //     );
  //     return;
  //   }

  //   // Si no tiene ejecuciones (compatibilidad con versiones antiguas)
  //   // Crear nueva evaluación
  //   final evaluation = ChallengeEvaluation(
  //     date: DateTime.now(),
  //     status: status,
  //     points: points,
  //     note: note,
  //   );

  //   // Actualizar puntos totales ganados
  //   final totalPoints = assignedChallenge.pointsEarned + points;

  //   // Actualizar estado del reto asignado (si es necesario)
  //   AssignedChallengeStatus newStatus = assignedChallenge.status;
  //   if (status == AssignedChallengeStatus.completed ||
  //       status == AssignedChallengeStatus.failed) {
  //     newStatus = assignedChallenge.isContinuous
  //         ? AssignedChallengeStatus.active
  //         : status;
  //   }

  //   // Añadir la evaluación a la lista
  //   final updatedEvaluations = [...assignedChallenge.evaluations, evaluation];

  //   // Crear modelo actualizado
  //   final updatedAssignedChallenge = assignedChallenge.copyWith(
  //     status: newStatus,
  //     pointsEarned: totalPoints,
  //     evaluations: updatedEvaluations,
  //   );

  //   // Guardar en Firestore
  //   await updateAssignedChallenge(
  //       AssignedChallengeModel.fromEntity(updatedAssignedChallenge));
  // }

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
        // Si es puntual, la fecha de fin es la misma que la de inicio
        return startDate;
    }
  }

  // Métodos auxiliares para mapear enumeraciones (duplicados para AssignedChallengeModel)
  // Idealmente, estos deberían estar en un lugar centralizado si se usan en varios modelos
  // Por ahora, los copiamos aquí para que el DataSource los use.

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
