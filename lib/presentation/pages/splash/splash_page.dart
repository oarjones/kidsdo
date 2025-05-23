// lib/presentation/pages/splash_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import for SvgPicture
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart'; // For consistent spacing
// TrKeys.appName no se usará directamente aquí si el logo ya lo incluye.
// import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/presentation/controllers/session_controller.dart';
import 'package:kidsdo/presentation/controllers/settings_controller.dart'; // Added
import 'package:kidsdo/presentation/controllers/child_access_controller.dart'; // Added
import 'package:kidsdo/routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final SessionController _sessionController = Get.find<SessionController>();
  final SettingsController _settingsController = Get.find<SettingsController>(); // Added
  final ChildAccessController _childAccessController = Get.find<ChildAccessController>(); // Added

  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Keep splash visible for a minimum duration
    await Future.delayed(const Duration(seconds: 2));

    // Wait for SettingsController to load initial settings
    // This loop is a pragmatic way to wait if isLoading is true.
    // In a more complex setup, a listenable or future from SettingsController might be used.
    while (_settingsController.isLoading.value) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (!mounted) return; // Ensure widget is still in the tree

    // Check if child mode was active on the device
    if (_settingsController.isChildModeActiveOnDevice.value) {
      if (!_childAccessController.isChildMode.value) {
        _childAccessController.enterGlobalChildMode();
        // App.dart's Obx will handle navigation to ChildProfileSelectionPage
        // So, SplashPage doesn't need to navigate further in this case.
        // The SplashPage will be replaced by ChildProfileSelectionPage.
        Get.log(
            "SplashPage: Child mode was active. Triggered global child mode. App.dart will navigate.");
      }
      // If _childAccessController.isChildMode is already true, App.dart has handled it.
      // No explicit navigation from SplashPage is needed here.
    } else {
      // Proceed with normal parent mode authentication check and navigation
      Get.log("SplashPage: Child mode NOT active. Proceeding with parent mode auth flow.");
      await _sessionController.checkUserLoggedIn();

      if (mounted) {
        if (_sessionController.isUserLoggedIn) {
          Get.offAllNamed(Routes.mainParent);
        } else {
          Get.offAllNamed(Routes.login);
        }
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
