import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidsdo/domain/entities/challenge.dart';

/// Modelo para mapear los datos de un reto desde/hacia Firebase
class ChallengeModel extends Challenge {
  const ChallengeModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.points,
    required super.frequency,
    required super.ageRange,
    required super.isTemplate,
    required super.createdBy,
    required super.createdAt,
    super.familyId,
    super.icon,
  });

  /// Crea un ChallengeModel desde un documento de Firestore
  factory ChallengeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChallengeModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: _mapStringToCategory(data['category'] ?? 'hygiene'),
      points: data['points'] ?? 0,
      frequency: _mapStringToFrequency(data['frequency'] ?? 'daily'),
      ageRange:
          data['ageRange'] as Map<String, dynamic>? ?? {'min': 0, 'max': 18},
      isTemplate: data['isTemplate'] ?? false,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      familyId: data['familyId'],
      icon: data['icon'],
    );
  }

  /// Convierte el modelo a un mapa para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': _categoryToString(category),
      'points': points,
      'frequency': _frequencyToString(frequency),
      'ageRange': ageRange,
      'isTemplate': isTemplate,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'familyId': familyId,
      'icon': icon,
    };
  }

  /// Crea un ChallengeModel desde Challenge
  factory ChallengeModel.fromEntity(Challenge challenge) {
    return ChallengeModel(
      id: challenge.id,
      title: challenge.title,
      description: challenge.description,
      category: challenge.category,
      points: challenge.points,
      frequency: challenge.frequency,
      ageRange: challenge.ageRange,
      isTemplate: challenge.isTemplate,
      createdBy: challenge.createdBy,
      createdAt: challenge.createdAt,
      familyId: challenge.familyId,
      icon: challenge.icon,
    );
  }

  // Métodos de ayuda para mapear enumeraciones
  static ChallengeCategory _mapStringToCategory(String category) {
    switch (category) {
      case 'hygiene':
        return ChallengeCategory.hygiene;
      case 'school':
        return ChallengeCategory.school;
      case 'order':
        return ChallengeCategory.order;
      case 'responsibility':
        return ChallengeCategory.responsibility;
      case 'help':
        return ChallengeCategory.help;
      case 'special':
        return ChallengeCategory.special;
      case 'sibling':
        return ChallengeCategory.sibling;
      default:
        return ChallengeCategory.hygiene;
    }
  }

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

  static ChallengeFrequency _mapStringToFrequency(String frequency) {
    switch (frequency) {
      case 'daily':
        return ChallengeFrequency.daily;
      case 'weekly':
        return ChallengeFrequency.weekly;
      case 'monthly':
        return ChallengeFrequency.monthly;
      case 'quarterly':
        return ChallengeFrequency.quarterly;
      case 'once':
        return ChallengeFrequency.once;
      default:
        return ChallengeFrequency.daily;
    }
  }

  static String _frequencyToString(ChallengeFrequency frequency) {
    switch (frequency) {
      case ChallengeFrequency.daily:
        return 'daily';
      case ChallengeFrequency.weekly:
        return 'weekly';
      case ChallengeFrequency.monthly:
        return 'monthly';
      case ChallengeFrequency.quarterly:
        return 'quarterly';
      case ChallengeFrequency.once:
        return 'once';
    }
  }
}
