// lib/presentation/pages/splash_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import for SvgPicture
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart'; // For consistent spacing
// TrKeys.appName no se usará directamente aquí si el logo ya lo incluye.
// import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/presentation/controllers/session_controller.dart';
import 'package:kidsdo/routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final SessionController _sessionController = Get.find<SessionController>();

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Simulate a delay to show the splash screen
    await Future.delayed(
        const Duration(seconds: 3)); // Slightly longer for logo visibility

    // Check if there is an active session
    await _sessionController.checkUserLoggedIn();

    if (mounted) {
      // Check if the widget is still in the tree
      if (_sessionController.isUserLoggedIn) {
        Get.offAllNamed(Routes.mainParent);
      } else {
        Get.offAllNamed(Routes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define a size for the logo on the splash screen
    const double logoSize =
        180.0; // Puedes ajustar este valor, un poco más grande
    // ya que no hay texto separado debajo.

    return Scaffold(
      backgroundColor:
          AppColors.primary, // O un color de fondo personalizado para el splash
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SVG Logo (que ya incluye el nombre "KidsDo")
            SvgPicture.asset(
              'assets/images/kidsdo_logo.svg', // Ruta a tu logo SVG
              width: logoSize,
              height: logoSize,
              semanticsLabel: 'KidsDo Logo', // Etiqueta de accesibilidad
              // Si tu SVG no es blanco y necesitas que lo sea (y es monocromático):
              // colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            // El Text widget para TrKeys.appName se elimina de aquí
            // ya que el nombre está integrado en el SVG.

            const SizedBox(
                height:
                    AppDimensions.xxl), // Espacio aumentado antes del indicador
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
