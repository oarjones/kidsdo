import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/theme/app_theme.dart';
import 'package:kidsdo/routes.dart';
import 'package:kidsdo/presentation/pages/splash/splash_page.dart';

class KidsDoApp extends StatelessWidget {
  const KidsDoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'KidsDo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: Routes.splash,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
      home: const SplashPage(),
    );
  }
}
