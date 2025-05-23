// lib/app.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/core/theme/app_theme.dart';
import 'package:kidsdo/routes.dart';
import 'package:kidsdo/presentation/controllers/settings_controller.dart';
import 'package:kidsdo/presentation/controllers/child_access_controller.dart'; // Import ChildAccessController
import 'package:kidsdo/presentation/pages/splash/splash_page.dart'; // Import SplashPage
import 'package:kidsdo/presentation/pages/child_access/child_profile_selection_page.dart'; // Import ChildProfileSelectionPage

class KidsDoApp extends StatelessWidget {
  const KidsDoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = Get.find<SettingsController>();
    // Access ChildAccessController
    final ChildAccessController childAccessController = Get.find<ChildAccessController>();

    return Obx(() {
      // SettingsController loading state
      if (settingsController.isLoading.value) {
        // Show a simple loading screen while settings (especially locale) are being loaded.
        // This prevents UI flicker or building with a temporary locale.
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.lightTheme.primaryColor),
              ),
            ),
          ),
        );
      }

      Locale currentLocale = settingsController.getCurrentLocale();
      
      // Determine the home widget based on child mode.
      // Another Obx is used here to specifically react to changes in isChildMode.
      return Obx(() {
        Widget homeWidget;
        if (childAccessController.isChildMode.value) {
          homeWidget = const ChildProfileSelectionPage();
        } else {
          homeWidget = const SplashPage(); // Default entry for parent mode
        }

        return GetMaterialApp(
          title: Tr.t(TrKeys.appName),
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system, 
          translations: AppTranslations(),
          locale: currentLocale,
          fallbackLocale: AppTranslations.fallbackLocale,
          home: homeWidget, // Dynamically set home page
          getPages: AppPages.routes, // Keep GetPage routes for navigation
          defaultTransition: Transition.cupertino,
          transitionDuration: const Duration(milliseconds: 300),
        );
      });
    });
  }
}
