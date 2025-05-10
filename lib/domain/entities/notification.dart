import 'package:equatable/equatable.dart';

// Enum para los tipos de notificación, puedes expandirlo según necesites.
enum NotificationType {
  unknown,
  challengeCompletedByChild, // Cuando el niño marca un reto como completado
  challengeEvaluatedByParent, // Cuando el padre evalúa (completa/falla) un reto del niño
  // Podrías añadir más tipos como: newChallengeAssigned, reminder, etc.
}

class NotificationEntity extends Equatable {
  final String id; // ID único de la notificación
  final String recipientId; // ID del usuario que recibe la notificación
  final String? senderId; // ID del usuario que originó la acción (opcional)
  final String? senderName; // Nombre del remitente (para mostrar en la UI)
  final NotificationType type; // Tipo de notificación
  final String title; // Título de la notificación
  final String body; // Cuerpo/mensaje de la notificación
  final DateTime timestamp; // Fecha y hora de creación
  final bool isRead; // Estado de lectura
  final String? relatedEntityType; // Ej: "challenge", "assignedChallenge"
  final String?
      relatedEntityId; // ID de la entidad relacionada (ej: ID del reto asignado)
  final Map<String, dynamic>?
      data; // Datos adicionales para la notificación (ej: para deep linking)

  const NotificationEntity({
    required this.id,
    required this.recipientId,
    this.senderId,
    this.senderName,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.relatedEntityType,
    this.relatedEntityId,
    this.data,
  });

  @override
  List<Object?> get props => [
        id,
        recipientId,
        senderId,
        senderName,
        type,
        title,
        body,
        timestamp,
        isRead,
        relatedEntityType,
        relatedEntityId,
        data,
      ];

  NotificationEntity copyWith({
    String? id,
    String? recipientId,
    String? senderId,
    String? senderName,
    NotificationType? type,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? isRead,
    String? relatedEntityType,
    String? relatedEntityId,
    Map<String, dynamic>? data,
    bool clearSenderId = false, // Para explícitamente hacer null el senderId
    bool clearSenderName = false,
    bool clearRelatedEntity = false,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      senderId: clearSenderId ? null : senderId ?? this.senderId,
      senderName: clearSenderName ? null : senderName ?? this.senderName,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      relatedEntityType: clearRelatedEntity
          ? null
          : relatedEntityType ?? this.relatedEntityType,
      relatedEntityId:
          clearRelatedEntity ? null : relatedEntityId ?? this.relatedEntityId,
      data: data ?? this.data,
    );
  }
}
