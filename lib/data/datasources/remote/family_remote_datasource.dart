import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidsdo/core/utils/random_generator.dart';
import 'package:kidsdo/data/models/family_model.dart';

abstract class IFamilyRemoteDataSource {
  /// Crea una nueva familia en Firestore
  Future<FamilyModel> createFamily({
    required String name,
    required String createdBy,
  });

  /// Obtiene una familia por su id
  Future<FamilyModel> getFamilyById(String familyId);

  /// Obtiene una familia por su código de invitación
  Future<FamilyModel> getFamilyByInviteCode(String inviteCode);

  /// Actualiza una familia
  Future<void> updateFamily(FamilyModel family);

  /// Agrega un miembro a una familia
  Future<void> addMemberToFamily({
    required String familyId,
    required String userId,
  });

  /// Elimina un miembro de una familia
  Future<void> removeMemberFromFamily({
    required String familyId,
    required String userId,
  });

  /// Genera un nuevo código de invitación para una familia
  Future<String> generateFamilyInviteCode(String familyId);
}

class FamilyRemoteDataSource implements IFamilyRemoteDataSource {
  final FirebaseFirestore _firestore;
  final String _familiesCollection = 'families';

  FamilyRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<FamilyModel> createFamily({
    required String name,
    required String createdBy,
  }) async {
    // Generar un código de invitación único
    final inviteCode = RandomGenerator.generateInviteCode();

    // Verificar que no exista ya una familia con este código
    final existingFamily = await _checkInviteCodeExists(inviteCode);

    final String finalInviteCode =
        existingFamily ? await _generateUniqueInviteCode() : inviteCode;

    // Crear datos de la familia
    final familyData = {
      'name': name,
      'createdBy': createdBy,
      'members': [createdBy],
      'createdAt': Timestamp.now(),
      'inviteCode': finalInviteCode,
    };

    // Crear documento en Firestore
    final docRef =
        await _firestore.collection(_familiesCollection).add(familyData);

    // Obtener el documento recién creado
    final docSnapshot = await docRef.get();

    return FamilyModel.fromFirestore(docSnapshot);
  }

  @override
  Future<FamilyModel> getFamilyById(String familyId) async {
    final docSnapshot =
        await _firestore.collection(_familiesCollection).doc(familyId).get();

    if (!docSnapshot.exists) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'not-found',
        message: 'Familia no encontrada',
      );
    }

    return FamilyModel.fromFirestore(docSnapshot);
  }

  @override
  Future<FamilyModel> getFamilyByInviteCode(String inviteCode) async {
    final querySnapshot = await _firestore
        .collection(_familiesCollection)
        .where('inviteCode', isEqualTo: inviteCode)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'not-found',
        message: 'Familia no encontrada con este código de invitación',
      );
    }

    return FamilyModel.fromFirestore(querySnapshot.docs.first);
  }

  @override
  Future<void> updateFamily(FamilyModel family) async {
    await _firestore
        .collection(_familiesCollection)
        .doc(family.id)
        .update(family.toFirestore());
  }

  @override
  Future<void> addMemberToFamily({
    required String familyId,
    required String userId,
  }) async {
    await _firestore.collection(_familiesCollection).doc(familyId).update({
      'members': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<void> removeMemberFromFamily({
    required String familyId,
    required String userId,
  }) async {
    await _firestore.collection(_familiesCollection).doc(familyId).update({
      'members': FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Future<String> generateFamilyInviteCode(String familyId) async {
    // Generar un nuevo código de invitación único
    final newInviteCode = await _generateUniqueInviteCode();

    // Actualizar la familia con el nuevo código
    await _firestore
        .collection(_familiesCollection)
        .doc(familyId)
        .update({'inviteCode': newInviteCode});

    return newInviteCode;
  }

  // Métodos privados
  Future<bool> _checkInviteCodeExists(String inviteCode) async {
    final querySnapshot = await _firestore
        .collection(_familiesCollection)
        .where('inviteCode', isEqualTo: inviteCode)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<String> _generateUniqueInviteCode() async {
    String inviteCode;
    bool exists;

    do {
      inviteCode = RandomGenerator.generateInviteCode();
      exists = await _checkInviteCodeExists(inviteCode);
    } while (exists);

    return inviteCode;
  }
}
