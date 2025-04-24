import 'package:equatable/equatable.dart';

/// Entidad que representa a un perfil infantil gestionado en una familia
class FamilyChild extends Equatable {
  final String id;
  final String familyId;
  final String name;
  final DateTime birthDate;
  final String? avatarUrl;
  final String createdBy; // ID del padre/madre que creó el perfil
  final DateTime createdAt;
  final int points;
  final int level;
  final Map<String, dynamic> settings;

  const FamilyChild({
    required this.id,
    required this.familyId,
    required this.name,
    required this.birthDate,
    this.avatarUrl,
    required this.createdBy,
    required this.createdAt,
    this.points = 0,
    this.level = 1,
    required this.settings,
  });

  @override
  List<Object?> get props => [
        id,
        familyId,
        name,
        birthDate,
        avatarUrl,
        createdBy,
        createdAt,
        points,
        level,
        settings,
      ];

  /// Retorna la edad del niño en años
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age < 0 ? 0 : age;
  }

  FamilyChild copyWith({
    String? id,
    String? familyId,
    String? name,
    DateTime? birthDate,
    String? avatarUrl,
    String? createdBy,
    DateTime? createdAt,
    int? points,
    int? level,
    Map<String, dynamic>? settings,
  }) {
    return FamilyChild(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      points: points ?? this.points,
      level: level ?? this.level,
      settings: settings ?? this.settings,
    );
  }
}
