import 'package:equatable/equatable.dart';

/// Entidad base para todos los usuarios del sistema
class BaseUser extends Equatable {
  final String uid;
  final String displayName;
  final String? email;
  final String? avatarUrl;
  final DateTime createdAt;
  final Map<String, dynamic> settings;
  final String type; // 'parent' o 'child'

  const BaseUser({
    required this.uid,
    required this.displayName,
    this.email,
    this.avatarUrl,
    required this.createdAt,
    required this.settings,
    required this.type,
  });

  @override
  List<Object?> get props => [
        uid,
        displayName,
        email,
        avatarUrl,
        createdAt,
        settings,
        type,
      ];
}
