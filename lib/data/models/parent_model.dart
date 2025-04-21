import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidsdo/data/models/user_model.dart';
import 'package:kidsdo/domain/entities/parent.dart';

/// Modelo para mapear los datos de un padre desde/hacia Firebase
class ParentModel extends Parent implements FirestoreModel {
  const ParentModel({
    required super.uid,
    required super.displayName,
    required super.email,
    super.avatarUrl,
    required super.createdAt,
    required super.settings,
    super.childrenIds = const [],
    super.familyId,
  });

  /// Crea un ParentModel desde un documento de Firestore
  factory ParentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ParentModel(
      uid: doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      avatarUrl: data['avatarUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      settings: data['settings'] as Map<String, dynamic>? ?? {},
      childrenIds: List<String>.from(data['childrenIds'] ?? []),
      familyId: data['familyId'],
    );
  }

  /// Convierte el modelo a un mapa para Firestore
  @override
  Map<String, dynamic> toFirestore() {
    final baseData = UserModel.fromEntity(this).toFirestore();

    return {
      ...baseData,
      'childrenIds': childrenIds,
      'familyId': familyId,
    };
  }

  /// Crea un ParentModel desde Parent
  factory ParentModel.fromEntity(Parent parent) {
    return ParentModel(
      uid: parent.uid,
      displayName: parent.displayName,
      email: parent.email!,
      avatarUrl: parent.avatarUrl,
      createdAt: parent.createdAt,
      settings: parent.settings,
      childrenIds: parent.childrenIds,
      familyId: parent.familyId,
    );
  }
}
