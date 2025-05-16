import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/presentation/controllers/session_controller.dart';
import 'package:kidsdo/routes.dart';

/// Middleware para proteger rutas que requieren autenticación
class AuthMiddleware extends GetMiddleware {
  final SessionController _sessionController = Get.find<SessionController>();

  @override
  RouteSettings? redirect(String? route) {
    // Si el usuario no está logueado y la ruta no es login o register, redirigir a login
    if (!_sessionController.isUserLoggedIn &&
        route != Routes.login &&
        route != Routes.register &&
        route != Routes.splash) {
      return const RouteSettings(name: Routes.login);
    }

    // Si el usuario está logueado y la ruta es login o register, redirigir a home
    if (_sessionController.isUserLoggedIn &&
        (route == Routes.login || route == Routes.register)) {
      return const RouteSettings(name: Routes.mainParent);
    }

    return null;
  }
}

/// Middleware para rutas que no requieren autenticación
class NoAuthMiddleware extends GetMiddleware {
  final SessionController _sessionController = Get.find<SessionController>();

  @override
  RouteSettings? redirect(String? route) {
    // Si el usuario está logueado y la ruta es login o register, redirigir a home
    if (_sessionController.isUserLoggedIn &&
        (route == Routes.login || route == Routes.register)) {
      return const RouteSettings(name: Routes.mainParent);
    }

    return null;
  }
}
