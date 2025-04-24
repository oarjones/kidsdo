import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidsdo/domain/entities/family_child.dart';

/// Modelo para mapear los datos de un perfil infantil desde/hacia Firebase
class FamilyChildModel extends FamilyChild {
  const FamilyChildModel({
    required super.id,
    required super.familyId,
    required super.name,
    required super.birthDate,
    super.avatarUrl,
    required super.createdBy,
    required super.createdAt,
    super.points = 0,
    super.level = 1,
    required super.settings,
  });

  /// Crea un FamilyChildModel desde un documento de Firestore
  factory FamilyChildModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FamilyChildModel(
      id: doc.id,
      familyId: data['familyId'] ?? '',
      name: data['name'] ?? '',
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      avatarUrl: data['avatarUrl'],
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      points: data['points'] ?? 0,
      level: data['level'] ?? 1,
      settings: data['settings'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Convierte el modelo a un mapa para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'familyId': familyId,
      'name': name,
      'birthDate': Timestamp.fromDate(birthDate),
      'avatarUrl': avatarUrl,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'points': points,
      'level': level,
      'settings': settings,
    };
  }

  /// Crea un FamilyChildModel desde FamilyChild
  factory FamilyChildModel.fromEntity(FamilyChild child) {
    return FamilyChildModel(
      id: child.id,
      familyId: child.familyId,
      name: child.name,
      birthDate: child.birthDate,
      avatarUrl: child.avatarUrl,
      createdBy: child.createdBy,
      createdAt: child.createdAt,
      points: child.points,
      level: child.level,
      settings: child.settings,
    );
  }
}
