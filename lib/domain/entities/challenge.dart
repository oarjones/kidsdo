import 'package:equatable/equatable.dart';

/// Enumeración de categorías de retos
enum ChallengeCategory {
  hygiene, // Higiene personal
  school, // Retos escolares
  order, // Orden y organización
  responsibility, // Responsabilidad
  help, // Ayuda en casa
  special, // Eventos especiales
  sibling, // Retos para hermanos
}

/// Enumeración de duraciones de retos
enum ChallengeDuration {
  weekly, // Semanal
  monthly, // Mensual
  quarterly, // Trimestral
  yearly, // Anual
  punctual, // Puntual (fecha específica)
}

/// Entidad que representa un reto en el sistema
class Challenge extends Equatable {
  final String id;
  final String title;
  final String description;
  final ChallengeCategory category;
  final int points;
  final ChallengeDuration duration; // Nueva propiedad: duración del reto
  final Map<String, dynamic> ageRange; // {'min': 3, 'max': 12}
  final bool isTemplate;
  final String createdBy;
  final DateTime createdAt;
  final String? familyId;
  final String? icon;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.points,
    required this.duration, // Nuevo campo obligatorio
    required this.ageRange,
    required this.isTemplate,
    required this.createdBy,
    required this.createdAt,
    this.familyId,
    this.icon,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        points,
        duration,
        ageRange,
        isTemplate,
        createdBy,
        createdAt,
        familyId,
        icon,
      ];

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    ChallengeCategory? category,
    int? points,
    ChallengeDuration? duration,
    Map<String, dynamic>? ageRange,
    bool? isTemplate,
    String? createdBy,
    DateTime? createdAt,
    String? familyId,
    String? icon,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      points: points ?? this.points,
      duration: duration ?? this.duration,
      ageRange: ageRange ?? this.ageRange,
      isTemplate: isTemplate ?? this.isTemplate,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      familyId: familyId ?? this.familyId,
      icon: icon ?? this.icon,
    );
  }
}
