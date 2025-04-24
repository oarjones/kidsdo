import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidsdo/data/models/family_child_model.dart';
import 'package:uuid/uuid.dart';

abstract class IFamilyChildRemoteDataSource {
  /// Crea un nuevo perfil infantil en Firestore
  Future<FamilyChildModel> createChild({
    required String familyId,
    required String name,
    required DateTime birthDate,
    String? avatarUrl,
    required String createdBy,
    required Map<String, dynamic> settings,
  });

  /// Obtiene un perfil infantil por su ID
  Future<FamilyChildModel> getChildById(String childId);

  /// Obtiene todos los perfiles infantiles de una familia
  Future<List<FamilyChildModel>> getChildrenByFamilyId(String familyId);

  /// Obtiene todos los perfiles infantiles creados por un padre/madre
  Future<List<FamilyChildModel>> getChildrenByCreator(String creatorId);

  /// Actualiza un perfil infantil
  Future<void> updateChild(FamilyChildModel child);

  /// Elimina un perfil infantil
  Future<void> deleteChild(String childId);

  /// Actualiza los puntos de un niño
  Future<void> updateChildPoints(String childId, int points);

  /// Actualiza el nivel de un niño
  Future<void> updateChildLevel(String childId, int level);

  /// Actualiza la configuración de un niño
  Future<void> updateChildSettings(
    String childId,
    Map<String, dynamic> settings,
  );
}

class FamilyChildRemoteDataSource implements IFamilyChildRemoteDataSource {
  final FirebaseFirestore _firestore;
  final String _familyChildrenCollection = 'familyChildren';
  final Uuid _uuid = const Uuid();

  FamilyChildRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<FamilyChildModel> createChild({
    required String familyId,
    required String name,
    required DateTime birthDate,
    String? avatarUrl,
    required String createdBy,
    required Map<String, dynamic> settings,
  }) async {
    final String childId = _uuid.v4(); // Generar un ID único para el niño
    final childData = FamilyChildModel(
      id: childId,
      familyId: familyId,
      name: name,
      birthDate: birthDate,
      avatarUrl: avatarUrl,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      settings: settings,
    );

    // Guardar en Firestore
    await _firestore
        .collection(_familyChildrenCollection)
        .doc(childId)
        .set(childData.toFirestore());

    return childData;
  }

  @override
  Future<FamilyChildModel> getChildById(String childId) async {
    final docSnapshot = await _firestore
        .collection(_familyChildrenCollection)
        .doc(childId)
        .get();

    if (!docSnapshot.exists) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'not-found',
        message: 'Perfil infantil no encontrado',
      );
    }

    return FamilyChildModel.fromFirestore(docSnapshot);
  }

  @override
  Future<List<FamilyChildModel>> getChildrenByFamilyId(String familyId) async {
    final querySnapshot = await _firestore
        .collection(_familyChildrenCollection)
        .where('familyId', isEqualTo: familyId)
        .get();

    return querySnapshot.docs
        .map((doc) => FamilyChildModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<List<FamilyChildModel>> getChildrenByCreator(String creatorId) async {
    final querySnapshot = await _firestore
        .collection(_familyChildrenCollection)
        .where('createdBy', isEqualTo: creatorId)
        .get();

    return querySnapshot.docs
        .map((doc) => FamilyChildModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> updateChild(FamilyChildModel child) async {
    await _firestore
        .collection(_familyChildrenCollection)
        .doc(child.id)
        .update(child.toFirestore());
  }

  @override
  Future<void> deleteChild(String childId) async {
    await _firestore
        .collection(_familyChildrenCollection)
        .doc(childId)
        .delete();
  }

  @override
  Future<void> updateChildPoints(String childId, int points) async {
    await _firestore
        .collection(_familyChildrenCollection)
        .doc(childId)
        .update({'points': points});
  }

  @override
  Future<void> updateChildLevel(String childId, int level) async {
    await _firestore
        .collection(_familyChildrenCollection)
        .doc(childId)
        .update({'level': level});
  }

  @override
  Future<void> updateChildSettings(
    String childId,
    Map<String, dynamic> settings,
  ) async {
    await _firestore
        .collection(_familyChildrenCollection)
        .doc(childId)
        .update({'settings': settings});
  }
}
