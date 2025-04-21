import 'package:kidsdo/domain/entities/base_user.dart';

/// Entidad que representa a un hijo/a en el sistema
class Child extends BaseUser {
  final String parentId;
  final String? familyId;
  final DateTime birthDate;
  final int points;
  final int level;

  const Child({
    required super.uid,
    required super.displayName,
    super.avatarUrl,
    required super.createdAt,
    required super.settings,
    required this.parentId,
    this.familyId,
    required this.birthDate,
    this.points = 0,
    this.level = 1,
  }) : super(type: 'child', email: null);

  @override
  List<Object?> get props => [
        ...super.props,
        parentId,
        familyId,
        birthDate,
        points,
        level,
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

  Child copyWith({
    String? uid,
    String? displayName,
    String? avatarUrl,
    DateTime? createdAt,
    Map<String, dynamic>? settings,
    String? parentId,
    String? familyId,
    DateTime? birthDate,
    int? points,
    int? level,
  }) {
    return Child(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      settings: settings ?? this.settings,
      parentId: parentId ?? this.parentId,
      familyId: familyId ?? this.familyId,
      birthDate: birthDate ?? this.birthDate,
      points: points ?? this.points,
      level: level ?? this.level,
    );
  }
}
