import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidsdo/data/models/child_model.dart';
import 'package:kidsdo/data/models/parent_model.dart';
import 'package:kidsdo/data/models/user_model.dart';

abstract class IUserRemoteDataSource {
  /// Guarda un usuario padre en Firestore
  Future<void> saveParent(ParentModel parent);

  /// Guarda un usuario hijo en Firestore
  Future<void> saveChild(ChildModel child);

  /// Obtiene un usuario por su id
  Future<UserModel> getUserById(String userId);

  /// Obtiene un usuario padre por su id
  Future<ParentModel> getParentById(String parentId);

  /// Obtiene un usuario hijo por su id
  Future<ChildModel> getChildById(String childId);

  /// Obtiene todos los hijos de un padre
  Future<List<ChildModel>> getChildrenByParentId(String parentId);

  /// Actualiza los puntos de un niño
  Future<void> updateChildPoints(String childId, int points);

  /// Actualiza el nivel de un niño
  Future<void> updateChildLevel(String childId, int level);

  /// Actualiza la configuración de un usuario
  Future<void> updateUserSettings(
    String userId,
    Map<String, dynamic> settings,
  );
}

class UserRemoteDataSource implements IUserRemoteDataSource {
  final FirebaseFirestore _firestore;
  final String _usersCollection = 'users';

  UserRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<void> saveParent(ParentModel parent) async {
    await _firestore
        .collection(_usersCollection)
        .doc(parent.uid)
        .set(parent.toFirestore());
  }

  @override
  Future<void> saveChild(ChildModel child) async {
    await _firestore
        .collection(_usersCollection)
        .doc(child.uid)
        .set(child.toFirestore());
  }

  @override
  Future<UserModel> getUserById(String userId) async {
    final docSnapshot =
        await _firestore.collection(_usersCollection).doc(userId).get();

    if (!docSnapshot.exists) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'not-found',
        message: 'Usuario no encontrado',
      );
    }

    return UserModel.fromFirestore(docSnapshot);
  }

  @override
  Future<ParentModel> getParentById(String parentId) async {
    final docSnapshot =
        await _firestore.collection(_usersCollection).doc(parentId).get();

    if (!docSnapshot.exists) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'not-found',
        message: 'Padre no encontrado',
      );
    }

    final data = docSnapshot.data() as Map<String, dynamic>;
    if (data['type'] != 'parent') {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'invalid-type',
        message: 'El usuario no es un padre',
      );
    }

    return ParentModel.fromFirestore(docSnapshot);
  }

  @override
  Future<ChildModel> getChildById(String childId) async {
    final docSnapshot =
        await _firestore.collection(_usersCollection).doc(childId).get();

    if (!docSnapshot.exists) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'not-found',
        message: 'Hijo no encontrado',
      );
    }

    final data = docSnapshot.data() as Map<String, dynamic>;
    if (data['type'] != 'child') {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'invalid-type',
        message: 'El usuario no es un hijo',
      );
    }

    return ChildModel.fromFirestore(docSnapshot);
  }

  @override
  Future<List<ChildModel>> getChildrenByParentId(String parentId) async {
    final querySnapshot = await _firestore
        .collection(_usersCollection)
        .where('type', isEqualTo: 'child')
        .where('parentId', isEqualTo: parentId)
        .get();

    return querySnapshot.docs
        .map((doc) => ChildModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> updateChildPoints(String childId, int points) async {
    await _firestore
        .collection(_usersCollection)
        .doc(childId)
        .update({'points': points});
  }

  @override
  Future<void> updateChildLevel(String childId, int level) async {
    await _firestore
        .collection(_usersCollection)
        .doc(childId)
        .update({'level': level});
  }

  @override
  Future<void> updateUserSettings(
    String userId,
    Map<String, dynamic> settings,
  ) async {
    await _firestore
        .collection(_usersCollection)
        .doc(userId)
        .update({'settings': settings});
  }
}
