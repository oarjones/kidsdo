import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidsdo/domain/entities/notification.dart'; // Asegúrate que la ruta sea correcta

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.recipientId,
    super.senderId,
    super.senderName,
    required super.type,
    required super.title,
    required super.body,
    required super.timestamp,
    super.isRead = false,
    super.relatedEntityType,
    super.relatedEntityId,
    super.data,
  });

  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      recipientId: entity.recipientId,
      senderId: entity.senderId,
      senderName: entity.senderName,
      type: entity.type,
      title: entity.title,
      body: entity.body,
      timestamp: entity.timestamp,
      isRead: entity.isRead,
      relatedEntityType: entity.relatedEntityType,
      relatedEntityId: entity.relatedEntityId,
      data: entity.data,
    );
  }

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      recipientId: data['recipientId'] as String,
      senderId: data['senderId'] as String?,
      senderName: data['senderName'] as String?,
      type: _notificationTypeFromString(data['type'] as String?),
      title: data['title'] as String,
      body: data['body'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] as bool? ?? false,
      relatedEntityType: data['relatedEntityType'] as String?,
      relatedEntityId: data['relatedEntityId'] as String?,
      data:
          data['data'] != null ? Map<String, dynamic>.from(data['data']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'recipientId': recipientId,
      'senderId': senderId,
      'senderName': senderName,
      'type': _stringFromNotificationType(type),
      'title': title,
      'body': body,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'relatedEntityType': relatedEntityType,
      'relatedEntityId': relatedEntityId,
      'data': data,
    };
  }

  static NotificationType _notificationTypeFromString(String? typeString) {
    if (typeString == null) return NotificationType.unknown;
    try {
      return NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == typeString,
      );
    } catch (e) {
      return NotificationType.unknown;
    }
  }

  static String _stringFromNotificationType(NotificationType type) {
    return type.toString().split('.').last;
  }
}
