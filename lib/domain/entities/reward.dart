import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart'; // Para Get.find<Logger>() si es necesario
import 'package:logger/logger.dart'; // Para logging

// --- Enums ---
enum RewardType {
  simple,
  product,
  experience,
  digitalAccess,
  longTermGoal,
  surprise,
  privilege
}

String rewardTypeToString(RewardType type) => type.name;

RewardType rewardTypeFromString(String? typeString) {
  return RewardType.values.firstWhere(
    (e) => e.name == typeString,
    orElse: () {
      try {
        Get.find<Logger>()
            .w('Unknown RewardType string: $typeString, defaulting to simple.');
      } catch (_) {
        // Logger not found or error during logging
        if (kDebugMode) {
          print(
              'Warning: Unknown RewardType string: $typeString, defaulting to simple. (Logger not available)');
        }
      }
      return RewardType.simple;
    },
  );
}

enum RewardStatus {
  available,
  redeemed, // Niño ha reclamado, pendiente de "entrega" por padre
  pendingAcquisition, // Padre necesita comprar/preparar
  acquired, // Producto/Experiencia lista
  delivered, // Entregada/Disfrutada/Concedida
  archived, // Ya no activa (e.g. única ya obtenida)
  cancelled, // Cancelada por padre
}

String rewardStatusToString(RewardStatus status) => status.name;

RewardStatus rewardStatusFromString(String? statusString) {
  return RewardStatus.values.firstWhere(
    (e) => e.name == statusString,
    orElse: () {
      try {
        Get.find<Logger>().w(
            'Unknown RewardStatus string: $statusString, defaulting to available.');
      } catch (_) {
        if (kDebugMode) {
          print(
              'Warning: Unknown RewardStatus string: $statusString, defaulting to available. (Logger not available)');
        }
      }
      return RewardStatus.available;
    },
  );
}

// --- Entidad Principal ---
class Reward extends Equatable {
  final String id;
  final String familyId;
  final String name;
  final String? description;
  final int pointsRequired;
  final RewardType type;
  final String? icon;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy; // User ID del padre
  final RewardStatus status;
  final Map<String, dynamic>? typeSpecificData;
  final bool isUnique;
  final bool isEnabled;

  const Reward({
    required this.id,
    required this.familyId,
    required this.name,
    this.description,
    required this.pointsRequired,
    required this.type,
    this.icon,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.status = RewardStatus.available,
    this.typeSpecificData,
    this.isUnique = false,
    this.isEnabled = true,
  });

  @override
  List<Object?> get props => [
        id,
        familyId,
        name,
        description,
        pointsRequired,
        type,
        icon,
        createdAt,
        updatedAt,
        createdBy,
        status,
        typeSpecificData,
        isUnique,
        isEnabled,
      ];

  Reward copyWith({
    String? id,
    String? familyId,
    String? name,
    String? description,
    int? pointsRequired,
    RewardType? type,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    RewardStatus? status,
    Map<String, dynamic>? typeSpecificData,
    bool? isUnique,
    bool? isEnabled,
  }) {
    return Reward(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      name: name ?? this.name,
      description: description ?? this.description,
      pointsRequired: pointsRequired ?? this.pointsRequired,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      typeSpecificData: typeSpecificData ?? this.typeSpecificData,
      isUnique: isUnique ?? this.isUnique,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
