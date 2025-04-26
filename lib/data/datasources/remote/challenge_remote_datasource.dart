import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidsdo/data/models/challenge_model.dart';
import 'package:kidsdo/data/models/assigned_challenge_model.dart';
import 'package:kidsdo/domain/entities/assigned_challenge.dart';

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
    required DateTime endDate,
    required String evaluationFrequency,
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

  /// Evalúa un reto asignado
  Future<void> evaluateAssignedChallenge({
    required String assignedChallengeId,
    required AssignedChallengeStatus status,
    required int points,
    String? note,
  });
}

class ChallengeRemoteDataSource implements IChallengeRemoteDataSource {
  final FirebaseFirestore _firestore;
  final String _challengesCollection = 'challenges';
  final String _assignedChallengesCollection = 'assignedChallenges';

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
    final querySnapshot = await _firestore
        .collection(_challengesCollection)
        .where('isTemplate', isEqualTo: true)
        .get();

    return querySnapshot.docs
        .map((doc) => ChallengeModel.fromFirestore(doc))
        .toList();
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
    required DateTime endDate,
    required String evaluationFrequency,
  }) async {
    // Crear datos del reto asignado
    final assignedChallengeData = {
      'challengeId': challengeId,
      'childId': childId,
      'familyId': familyId,
      'status': 'active',
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'evaluationFrequency': evaluationFrequency,
      'pointsEarned': 0,
      'evaluations': [],
      'createdAt': Timestamp.now(),
    };

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
  Future<void> evaluateAssignedChallenge({
    required String assignedChallengeId,
    required AssignedChallengeStatus status,
    required int points,
    String? note,
  }) async {
    // Obtener reto asignado actual
    final assignedChallenge =
        await getAssignedChallengeById(assignedChallengeId);

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
      newStatus = status;
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
}
