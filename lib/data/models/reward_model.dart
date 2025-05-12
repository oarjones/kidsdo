import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidsdo/domain/entities/reward.dart'; // Asegúrate que la ruta sea correcta

class RewardModel extends Reward {
  const RewardModel({
    required super.id,
    required super.familyId,
    required super.name,
    super.description,
    required super.pointsRequired,
    required super.type,
    super.icon,
    required super.createdAt,
    required super.updatedAt,
    required super.createdBy,
    super.status = RewardStatus.available,
    super.typeSpecificData,
    super.isUnique = false,
    super.isEnabled = true,
  });

  factory RewardModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return RewardModel(
      id: doc.id,
      familyId: data['familyId'] as String,
      name: data['name'] as String,
      description: data['description'] as String?,
      pointsRequired: data['pointsRequired'] as int,
      type: rewardTypeFromString(data['type'] as String?),
      icon: data['icon'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] as String,
      status: rewardStatusFromString(data['status'] as String?),
      typeSpecificData: data['typeSpecificData'] != null
          ? Map<String, dynamic>.from(data['typeSpecificData'] as Map)
          : null,
      isUnique: data['isUnique'] as bool? ?? false,
      isEnabled: data['isEnabled'] as bool? ?? true,
    );
  }

  factory RewardModel.fromEntity(Reward reward) {
    return RewardModel(
      id: reward.id,
      familyId: reward.familyId,
      name: reward.name,
      description: reward.description,
      pointsRequired: reward.pointsRequired,
      type: reward.type,
      icon: reward.icon,
      createdAt: reward.createdAt,
      updatedAt: reward.updatedAt,
      createdBy: reward.createdBy,
      status: reward.status,
      typeSpecificData: reward.typeSpecificData,
      isUnique: reward.isUnique,
      isEnabled: reward.isEnabled,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'familyId': familyId,
      'name': name,
      'description': description,
      'pointsRequired': pointsRequired,
      'type': rewardTypeToString(type),
      'icon': icon,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'status': rewardStatusToString(status),
      'typeSpecificData': typeSpecificData,
      'isUnique': isUnique,
      'isEnabled': isEnabled,
    };
  }
}
