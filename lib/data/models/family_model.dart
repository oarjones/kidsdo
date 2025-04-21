import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidsdo/domain/entities/family.dart';

/// Modelo para mapear los datos de una familia desde/hacia Firebase
class FamilyModel extends Family {
  const FamilyModel({
    required super.id,
    required super.name,
    required super.createdBy,
    required super.members,
    required super.createdAt,
    super.inviteCode,
  });

  /// Crea un FamilyModel desde un documento de Firestore
  factory FamilyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FamilyModel(
      id: doc.id,
      name: data['name'] ?? '',
      createdBy: data['createdBy'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      inviteCode: data['inviteCode'],
    );
  }

  /// Convierte el modelo a un mapa para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'createdBy': createdBy,
      'members': members,
      'createdAt': Timestamp.fromDate(createdAt),
      'inviteCode': inviteCode,
    };
  }

  /// Crea un FamilyModel desde Family
  factory FamilyModel.fromEntity(Family family) {
    return FamilyModel(
      id: family.id,
      name: family.name,
      createdBy: family.createdBy,
      members: family.members,
      createdAt: family.createdAt,
      inviteCode: family.inviteCode,
    );
  }
}
