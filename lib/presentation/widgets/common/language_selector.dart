import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/presentation/controllers/settings_controller.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.find<SettingsController>();

    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      onSelected: (String value) {
        switch (value) {
          case 'es':
            controller.changeToSpanish();
            break;
          case 'en':
            controller.changeToEnglish();
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'es',
          child: Row(
            children: [
              Image.asset(
                'assets/images/es_flag.png',
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
              const Text('Español'),
              const SizedBox(width: 8),
              if (Get.locale?.languageCode == 'es')
                const Icon(Icons.check, color: Colors.green),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'en',
          child: Row(
            children: [
              Image.asset(
                'assets/images/en_flag.png',
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
              const Text('English'),
              const SizedBox(width: 8),
              if (Get.locale?.languageCode == 'en')
                const Icon(Icons.check, color: Colors.green),
            ],
          ),
        ),
      ],
    );
  }
}
