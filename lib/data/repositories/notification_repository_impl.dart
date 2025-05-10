import 'package:dartz/dartz.dart';
import 'package:kidsdo/core/errors/failures.dart';
import 'package:kidsdo/data/models/notification_model.dart'; // Asegúrate que la ruta sea correcta
import 'package:kidsdo/domain/entities/notification.dart'; // Asegúrate que la ruta sea correcta
import 'package:kidsdo/data/datasources/remote/notification_remote_datasource.dart'; // Asegúrate que la ruta sea correcta
import 'package:kidsdo/domain/repositories/notification_repository.dart';
import 'package:meta/meta.dart';

// Implementación del Repositorio
class NotificationRepositoryImpl implements INotificationRepository {
  final INotificationRemoteDataSource remoteDataSource;
  // Podrías añadir un INotificationLocalDataSource si cacheas notificaciones localmente.

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Unit>> saveUserFCMToken({
    required String userId,
    required String token,
  }) async {
    try {
      return await remoteDataSource.saveUserFCMToken(
          userId: userId, token: token);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeUserFCMToken({
    required String userId,
    required String token,
  }) async {
    try {
      return await remoteDataSource.removeUserFCMToken(
          userId: userId, token: token);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<NotificationEntity>>> getNotificationsForUser(
      String userId) {
    return remoteDataSource.getNotificationsForUser(userId).map((eitherResult) {
      return eitherResult.fold(
        (failure) => Left(failure),
        (models) =>
            Right(models.map((model) => model as NotificationEntity).toList()),
      );
    });
  }

  @override
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
  }) async {
    try {
      final notificationModel = NotificationModel(
        // El ID se generará en el datasource o Firestore al crear el documento.
        // Aquí pasamos un placeholder o lo dejamos que el datasource lo maneje.
        // Para este ejemplo, asumimos que el datasource genera/asigna el ID.
        id: '', // Será reemplazado por el ID real de Firestore
        recipientId: recipientId,
        senderId: senderId,
        senderName: senderName,
        type: type,
        title: title,
        body: body,
        timestamp: DateTime.now(),
        isRead: false,
        relatedEntityType: relatedEntityType,
        relatedEntityId: relatedEntityId,
        data: data,
      );
      // El método createNotification en el datasource ahora devuelve el ID de la notificación creada.
      return await remoteDataSource.createNotification(notificationModel);
    } catch (e) {
      // Atrapar cualquier excepción inesperada durante la creación del modelo o llamada.
      return Left(ServerFailure(
          message: "Error preparando notificación: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, Unit>> markNotificationAsRead(
      String userId, String notificationId) async {
    try {
      return await remoteDataSource.markNotificationAsRead(
          userId, notificationId);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAllNotificationsAsRead(
      String userId) async {
    try {
      return await remoteDataSource.markAllNotificationsAsRead(userId);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
