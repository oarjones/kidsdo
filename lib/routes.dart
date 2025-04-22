import 'package:get/get.dart';
import 'package:kidsdo/core/middleware/auth_middleware.dart';
import 'package:kidsdo/presentation/pages/splash/splash_page.dart';
import 'package:kidsdo/presentation/pages/auth/login_page.dart';
import 'package:kidsdo/presentation/pages/auth/register_page.dart';
import 'package:kidsdo/presentation/pages/home/home_page.dart';

abstract class Routes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const profile = '/profile';
  static const family = '/family';
  static const createChild = '/create-child';
}

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashPage(),
      transition: Transition.fade,
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginPage(),
      middlewares: [NoAuthMiddleware()],
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterPage(),
      middlewares: [NoAuthMiddleware()],
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomePage(),
      middlewares: [AuthMiddleware()],
    ),
    // Otras rutas protegidas
    GetPage(
      name: Routes.profile,
      page: () => const HomePage(), // Temporalmente usando HomePage
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.family,
      page: () => const HomePage(), // Temporalmente usando HomePage
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.createChild,
      page: () => const HomePage(), // Temporalmente usando HomePage
      middlewares: [AuthMiddleware()],
    ),
  ];
}
