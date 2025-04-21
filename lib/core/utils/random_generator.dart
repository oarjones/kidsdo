import 'dart:math';

/// Utilidad para generar cadenas aleatorias para diversos usos en la aplicación
class RandomGenerator {
  /// Genera un código de invitación aleatorio de 6 caracteres alfanuméricos
  static String generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (_) => chars[Random().nextInt(chars.length)])
        .join();
  }

  /// Genera un identificador único para documentos
  static String generateUid() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(10000).toString();
  }

  /// Genera una cadena aleatoria del tamaño especificado
  static String generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(length, (_) => chars[Random().nextInt(chars.length)])
        .join();
  }
}
