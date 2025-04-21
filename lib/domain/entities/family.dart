import 'package:equatable/equatable.dart';

/// Entidad que representa una familia en el sistema
class Family extends Equatable {
  final String id;
  final String name;
  final String createdBy;
  final List<String> members;
  final DateTime createdAt;
  final String? inviteCode;

  const Family({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.members,
    required this.createdAt,
    this.inviteCode,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        createdBy,
        members,
        createdAt,
        inviteCode,
      ];

  Family copyWith({
    String? id,
    String? name,
    String? createdBy,
    List<String>? members,
    DateTime? createdAt,
    String? inviteCode,
  }) {
    return Family(
      id: id ?? this.id,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      inviteCode: inviteCode ?? this.inviteCode,
    );
  }
}
