import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:kidsdo/domain/entities/challenge.dart';

/// Modelo para mapear los datos de un reto desde/hacia Firebase
class ChallengeModel extends Challenge {
  final String? titleKey; // Clave de traducción para el título
  final String? descriptionKey; // Clave de traducción para la descripción

  const ChallengeModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.points,
    required super.duration, // Nuevo campo obligatorio
    required super.ageRange,
    required super.isTemplate,
    required super.createdBy,
    required super.createdAt,
    super.familyId,
    super.icon,
    this.titleKey,
    this.descriptionKey,
  });

  /// Crea un ChallengeModel desde un documento de Firestore
  factory ChallengeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Determinar si el reto tiene claves de traducción
    final hasTitleKey = data.containsKey('titleKey');
    final hasDescKey = data.containsKey('descriptionKey');

    // Si tiene claves de traducción, usarlas para obtener textos traducidos
    // Si no, usar los campos de título y descripción directamente
    String title = data['title'] ?? '';
    String description = data['description'] ?? '';

    if (hasTitleKey && data['titleKey'] != null) {
      title = data['titleKey'].toString().tr;
    }

    if (hasDescKey && data['descriptionKey'] != null) {
      description = data['descriptionKey'].toString().tr;
    }

    return ChallengeModel(
      id: doc.id,
      title: title,
      description: description,
      category: _mapStringToCategory(data['category'] ?? 'hygiene'),
      points: data['points'] ?? 0,
      duration:
          _mapStringToDuration(data['duration'] ?? 'weekly'), // Nuevo campo
      ageRange:
          data['ageRange'] as Map<String, dynamic>? ?? {'min': 0, 'max': 18},
      isTemplate: data['isTemplate'] ?? false,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      familyId: data['familyId'],
      icon: data['icon'],
      titleKey: hasTitleKey ? data['titleKey'] : null,
      descriptionKey: hasDescKey ? data['descriptionKey'] : null,
    );
  }

  /// Convierte el modelo a un mapa para Firestore
  Map<String, dynamic> toFirestore() {
    final Map<String, dynamic> data = {
      'title': title,
      'description': description,
      'category': _categoryToString(category),
      'points': points,
      'duration': _durationToString(duration), // Nuevo campo
      'ageRange': ageRange,
      'isTemplate': isTemplate,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'familyId': familyId,
      'icon': icon,
    };

    // Agregar claves de traducción si existen
    if (titleKey != null) {
      data['titleKey'] = titleKey;
    }

    if (descriptionKey != null) {
      data['descriptionKey'] = descriptionKey;
    }

    return data;
  }

  /// Crea un ChallengeModel desde Challenge
  factory ChallengeModel.fromEntity(Challenge challenge) {
    // Si el challenge ya es un ChallengeModel con claves de traducción, preservarlas
    if (challenge is ChallengeModel) {
      return ChallengeModel(
        id: challenge.id,
        title: challenge.title,
        description: challenge.description,
        category: challenge.category,
        points: challenge.points,
        duration: challenge.duration,
        ageRange: challenge.ageRange,
        isTemplate: challenge.isTemplate,
        createdBy: challenge.createdBy,
        createdAt: challenge.createdAt,
        familyId: challenge.familyId,
        icon: challenge.icon,
        titleKey: challenge.titleKey,
        descriptionKey: challenge.descriptionKey,
      );
    }

    // Si no, crear un nuevo ChallengeModel sin claves de traducción
    return ChallengeModel(
      id: challenge.id,
      title: challenge.title,
      description: challenge.description,
      category: challenge.category,
      points: challenge.points,
      duration: challenge.duration,
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

  // Nuevos métodos para mapear duración
  static ChallengeDuration _mapStringToDuration(String duration) {
    switch (duration) {
      case 'weekly':
        return ChallengeDuration.weekly;
      case 'monthly':
        return ChallengeDuration.monthly;
      case 'quarterly':
        return ChallengeDuration.quarterly;
      case 'yearly':
        return ChallengeDuration.yearly;
      case 'punctual':
        return ChallengeDuration.punctual;
      default:
        return ChallengeDuration.weekly;
    }
  }

  static String _durationToString(ChallengeDuration duration) {
    switch (duration) {
      case ChallengeDuration.weekly:
        return 'weekly';
      case ChallengeDuration.monthly:
        return 'monthly';
      case ChallengeDuration.quarterly:
        return 'quarterly';
      case ChallengeDuration.yearly:
        return 'yearly';
      case ChallengeDuration.punctual:
        return 'punctual';
    }
  }
}
