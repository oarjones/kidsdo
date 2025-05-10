// Interfaz del Repositorio
import 'package:dartz/dartz.dart';
import 'package:kidsdo/core/errors/failures.dart';
import 'package:kidsdo/domain/entities/notification.dart';

abstract class INotificationRepository {
  Future<Either<Failure, Unit>> saveUserFCMToken(
      {required String userId, required String token});
  Future<Either<Failure, Unit>> removeUserFCMToken(
      {required String userId, required String token});
  Stream<Either<Failure, List<NotificationEntity>>> getNotificationsForUser(
      String userId);
  Future<Either<Failure, String>> sendNotification({
    required String recipientId,
    String? senderId,
    String? senderName,
    required NotificationType type,
    required String title,
    required String body,
    String? relatedEntityType,
    String? relatedEntityId,
    Map<String, dynamic>? data,
  });
  Future<Either<Failure, Unit>> markNotificationAsRead(
      String userId, String notificationId);
  Future<Either<Failure, Unit>> markAllNotificationsAsRead(String userId);
}
