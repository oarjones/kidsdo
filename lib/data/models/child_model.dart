import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidsdo/data/models/user_model.dart';
import 'package:kidsdo/domain/entities/child.dart';

/// Modelo para mapear los datos de un hijo desde/hacia Firebase
class ChildModel extends Child {
  const ChildModel({
    required super.uid,
    required super.displayName,
    super.avatarUrl,
    required super.createdAt,
    required super.settings,
    required super.parentId,
    super.familyId,
    required super.birthDate,
    super.points = 0,
    super.level = 1,
  });

  /// Crea un ChildModel desde un documento de Firestore
  factory ChildModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChildModel(
      uid: doc.id,
      displayName: data['displayName'] ?? '',
      avatarUrl: data['avatarUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      settings: data['settings'] as Map<String, dynamic>? ?? {},
      parentId: data['parentId'] ?? '',
      familyId: data['familyId'],
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      points: data['points'] ?? 0,
      level: data['level'] ?? 1,
    );
  }

  /// Convierte el modelo a un mapa para Firestore
  Map<String, dynamic> toFirestore() {
    final baseData = UserModel.fromEntity(this).toFirestore();

    return {
      ...baseData,
      'parentId': parentId,
      'familyId': familyId,
      'birthDate': Timestamp.fromDate(birthDate),
      'points': points,
      'level': level,
    };
  }

  /// Crea un ChildModel desde Child
  factory ChildModel.fromEntity(Child child) {
    return ChildModel(
      uid: child.uid,
      displayName: child.displayName,
      avatarUrl: child.avatarUrl,
      createdAt: child.createdAt,
      settings: child.settings,
      parentId: child.parentId,
      familyId: child.familyId,
      birthDate: child.birthDate,
      points: child.points,
      level: child.level,
    );
  }
}
