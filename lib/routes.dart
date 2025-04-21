import 'package:get/get.dart';
import 'package:kidsdo/presentation/pages/splash/splash_page.dart';
import 'package:kidsdo/presentation/pages/auth/login_page.dart';
import 'package:kidsdo/presentation/pages/auth/register_page.dart';
import 'package:kidsdo/presentation/pages/home/home_page.dart';

abstract class Routes {
  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const HOME = '/home';
  static const PROFILE = '/profile';
  static const FAMILY = '/family';
  static const CREATE_CHILD = '/create-child';
}

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashPage(),
      transition: Transition.fade,
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterPage(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomePage(),
    ),
    // Otras rutas se añadirán según avance el desarrollo
  ];
}
