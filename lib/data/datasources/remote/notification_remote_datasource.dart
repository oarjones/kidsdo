import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/errors/failures.dart';
import 'package:kidsdo/data/models/notification_model.dart'; // Asegúrate que la ruta sea correcta
import 'package:logger/logger.dart';

// Interfaz del DataSource
abstract class INotificationRemoteDataSource {
  /// Guarda un token FCM para un usuario.
  Future<Either<Failure, Unit>> saveUserFCMToken({
    required String userId,
    required String token,
  });

  /// Elimina un token FCM para un usuario.
  Future<Either<Failure, Unit>> removeUserFCMToken({
    required String userId,
    required String token,
  });

  /// Obtiene las notificaciones para un usuario.
  Stream<Either<Failure, List<NotificationModel>>> getNotificationsForUser(
      String userId);

  /// Crea una notificación en Firestore (para ser leída por el usuario y potencialmente procesada por una Cloud Function).
  Future<Either<Failure, String>> createNotification(
      NotificationModel notification);

  /// Marca una notificación como leída.
  Future<Either<Failure, Unit>> markNotificationAsRead(
      String userId, String notificationId);

  /// Marca todas las notificaciones de un usuario como leídas.
  Future<Either<Failure, Unit>> markAllNotificationsAsRead(String userId);
}

// Implementación del DataSource
class NotificationRemoteDataSourceImpl
    implements INotificationRemoteDataSource {
  final FirebaseFirestore firestore;
  final Logger logger = Get.find<Logger>();

  NotificationRemoteDataSourceImpl({required this.firestore});

  @override
  Future<Either<Failure, Unit>> saveUserFCMToken({
    required String userId,
    required String token,
  }) async {
    try {
      // Guardar el token en el documento del usuario.
      // Considera si un usuario puede tener múltiples tokens (uno por dispositivo).
      // Aquí se asume un campo 'fcmTokens' que es un array.
      await firestore.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
      // Si el documento o el campo no existen, arrayUnion los crea.
      // Si prefieres un solo token, usa: 'fcmToken': token,
      return const Right(unit);
    } catch (e) {
      return Left(
          ServerFailure(message: "Error guardando token FCM: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeUserFCMToken({
    required String userId,
    required String token,
  }) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(
          message: "Error eliminando token FCM: ${e.toString()}"));
    }
  }

  @override
  Stream<Either<Failure, List<NotificationModel>>> getNotificationsForUser(
      String userId) {
    try {
      return firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(50) // Limitar la cantidad de notificaciones cargadas
          .snapshots()
          .map((snapshot) {
        final notifications = snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList();
        return Right<Failure, List<NotificationModel>>(notifications);
      }).handleError((error) {
        // Este handleError es para errores dentro del stream después de que ha comenzado.
        // Firestore security rules pueden causar errores aquí también.
        logger.e("Error en stream de notificaciones: $error");
        return Left<Failure, List<NotificationModel>>(ServerFailure(
            message:
                "Error obteniendo notificaciones en tiempo real: ${error.toString()}"));
      });
    } catch (e) {
      // Este catch es para errores al configurar el stream inicialmente.
      logger.e("Error configurando stream de notificaciones: $e");
      return Stream.value(Left(ServerFailure(
          message:
              "Error al iniciar escucha de notificaciones: ${e.toString()}")));
    }
  }

  @override
  Future<Either<Failure, String>> createNotification(
      NotificationModel notification) async {
    try {
      // 1. Guardar la notificación en la subcolección del usuario para que la vea en la app.
      final userNotifDocRef = firestore
          .collection('users')
          .doc(notification.recipientId)
          .collection('notifications')
          .doc(); // Firestore genera el ID

      // Usar el ID generado por Firestore para el modelo antes de guardarlo.
      final notificationWithId = NotificationModel.fromEntity(
          notification.copyWith(id: userNotifDocRef.id));

      await userNotifDocRef.set(notificationWithId.toFirestore());

      // 2. (Opcional pero recomendado para FCM vía Cloud Functions)
      // Guardar una copia o una referencia en una colección global que active una Cloud Function.
      // Esto desacopla la lógica de envío de FCM de la app cliente.
      // La Cloud Function se encargaría de buscar el token FCM del recipientId y enviar el mensaje.

      // Ejemplo: Crear un documento en 'pending_fcm_notifications'
      // La Cloud Function escucharía las creaciones en esta colección.
      final pendingNotifDocRef =
          firestore.collection('pending_fcm_notifications').doc();
      await pendingNotifDocRef.set({
        ...notificationWithId
            .toFirestore(), // Guardar todos los datos de la notificación
        'fcmProcessingStatus': 'pending', // Estado para la Cloud Function
        'originalNotificationId':
            userNotifDocRef.id, // Referencia a la notificación del usuario
      });

      return Right(userNotifDocRef.id);
    } catch (e) {
      return Left(ServerFailure(
          message: "Error creando notificación: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, Unit>> markNotificationAsRead(
      String userId, String notificationId) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(
          message: "Error marcando notificación como leída: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAllNotificationsAsRead(
      String userId) async {
    try {
      final batch = firestore.batch();
      final notificationsSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in notificationsSnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(
          message:
              "Error marcando todas las notificaciones como leídas: ${e.toString()}"));
    }
  }
}
