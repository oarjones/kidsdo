import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidsdo/domain/entities/base_user.dart';

abstract class FirestoreModel {
  Map<String, dynamic> toFirestore();
}

/// Modelo para mapear los datos de usuario desde/hacia Firebase
class UserModel extends BaseUser implements FirestoreModel {
  const UserModel({
    required super.uid,
    required super.displayName,
    super.email,
    super.avatarUrl,
    required super.createdAt,
    required super.settings,
    required super.type,
  });

  /// Crea un UserModel desde un documento de Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'],
      avatarUrl: data['avatarUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      settings: data['settings'] as Map<String, dynamic>? ?? {},
      type: data['type'] ?? 'unknown',
    );
  }

  /// Convierte el modelo a un mapa para Firestore
  @override
  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'avatarUrl': avatarUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'settings': settings,
      'type': type,
    };
  }

  /// Crea un UserModel desde BaseUser
  factory UserModel.fromEntity(BaseUser user) {
    return UserModel(
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
      avatarUrl: user.avatarUrl,
      createdAt: user.createdAt,
      settings: user.settings,
      type: user.type,
    );
  }
}
