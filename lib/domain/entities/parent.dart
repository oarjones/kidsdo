import 'package:kidsdo/domain/entities/base_user.dart';

/// Entidad que representa a un padre/madre en el sistema
class Parent extends BaseUser {
  final List<String> childrenIds;
  final String? familyId;

  const Parent({
    required super.uid,
    required super.displayName,
    required super.email,
    super.avatarUrl,
    required super.createdAt,
    required super.settings,
    this.childrenIds = const [],
    this.familyId,
  }) : super(type: 'parent');

  @override
  List<Object?> get props => [
        ...super.props,
        childrenIds,
        familyId,
      ];

  Parent copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,
    Map<String, dynamic>? settings,
    List<String>? childrenIds,
    String? familyId,
  }) {
    return Parent(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      settings: settings ?? this.settings,
      childrenIds: childrenIds ?? this.childrenIds,
      familyId: familyId ?? this.familyId,
    );
  }
}
