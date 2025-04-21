import 'package:equatable/equatable.dart';

/// Clase base para todos los fallos en la aplicación
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

/// Fallo de autenticación
class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

/// Fallo de red
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

/// Fallo de servidor
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

/// Fallo de caché
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Fallo de validación
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

/// Fallo de permisos
class PermissionFailure extends Failure {
  const PermissionFailure({required super.message});
}

/// Fallo no encontrado
class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}
