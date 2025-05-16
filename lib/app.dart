// lib/app.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/core/theme/app_theme.dart';
import 'package:kidsdo/routes.dart'; // Asegúrate de que tus rutas estén definidas aquí
import 'package:kidsdo/presentation/controllers/settings_controller.dart'; // Importa SettingsController
// import 'package:kidsdo/presentation/pages/splash/splash_page.dart'; // No es necesario si usas initialRoute

class KidsDoApp extends StatelessWidget {
  const KidsDoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Acceder al SettingsController.
    // Para cuando se construye KidsDoApp, SettingsController ya debería estar
    // registrado y sus configuraciones cargadas por la lógica en main.dart.
    final SettingsController settingsController =
        Get.find<SettingsController>();

    // Envolver GetMaterialApp con Obx para que reaccione a los cambios de idioma
    // y a la carga inicial de SettingsController.
    return Obx(() {
      // Mientras SettingsController está cargando, podrías mostrar un Loader global
      // o simplemente dejar que la SplashPage maneje su propia lógica de carga.
      // Aquí, asumimos que la SplashPage se mostrará y el locale se actualizará
      // una vez que settingsController.isLoading.value sea false.
      Locale currentLocale = settingsController.isLoading.value
          ? (Get.deviceLocale ??
              AppTranslations.fallbackLocale) // Locale temporal mientras carga
          : settingsController
              .getCurrentLocale(); // Locale desde SettingsController

      return GetMaterialApp(
        title: Tr.t(TrKeys.appName), // Usar Tr.t para el título
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode
            .system, // O gestionado por SettingsController en el futuro

        // Configuración de internacionalización
        translations: AppTranslations(), // Tu clase de traducciones
        locale:
            currentLocale, // Establecer el locale basado en SettingsController
        fallbackLocale: AppTranslations.fallbackLocale, // Idioma por defecto

        initialRoute: Routes.splash, // Ruta inicial de tu aplicación
        getPages:
            AppPages.routes, // Tus GetPage si usas navegación nombrada de GetX

        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        // home: const SplashPage(), // No es necesario si usas initialRoute
      );
    });
  }
}
