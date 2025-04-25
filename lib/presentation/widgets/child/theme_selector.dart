import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';

class ThemeSelector extends StatelessWidget {
  /// Configuración actual del tema
  final Map<String, dynamic> currentSettings;

  /// Función llamada cuando se actualiza un ajuste
  final Function(String key, dynamic value) onSettingUpdated;

  const ThemeSelector({
    Key? key,
    required this.currentSettings,
    required this.onSettingUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TrKeys.childProfileTheme.tr,
          style: const TextStyle(
            fontSize: AppDimensions.fontMd,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.md),

        // Color del tema
        _buildColorSelector(),
        const SizedBox(height: AppDimensions.md),

        // Estilo visual
        _buildThemeStyleSelector(),
        const SizedBox(height: AppDimensions.md),

        // Tamaño de elementos de interfaz
        _buildInterfaceSizeSelector(),
      ],
    );
  }

  /// Selector de color del tema
  Widget _buildColorSelector() {
    // Definir colores disponibles con nombre y color correspondiente
    final colors = {
      'blue': AppColors.childBlue,
      'purple': AppColors.childPurple,
      'green': AppColors.childGreen,
      'orange': AppColors.childOrange,
      'pink': AppColors.childPink,
    };

    // Obtener color seleccionado actual
    final selectedColor = currentSettings['color'] as String? ?? 'blue';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TrKeys.themeColor.tr,
          style: const TextStyle(
            fontSize: AppDimensions.fontSm,
            color: AppColors.textMedium,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: colors.entries.map((entry) {
            final isSelected = selectedColor == entry.key;
            return InkWell(
              onTap: () => onSettingUpdated('color', entry.key),
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadiusCircular),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: entry.value, width: 2)
                      : null,
                ),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: entry.value,
                    shape: BoxShape.circle,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: AppDimensions.iconSm,
                        )
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Selector de estilo visual
  Widget _buildThemeStyleSelector() {
    // Definir estilos disponibles
    final styles = [
      {
        'key': 'default',
        'name': TrKeys.themeStyleDefault.tr,
        'icon': Icons.style
      },
      {
        'key': 'space',
        'name': TrKeys.themeStyleSpace.tr,
        'icon': Icons.rocket_launch
      },
      {'key': 'sea', 'name': TrKeys.themeStyleSea.tr, 'icon': Icons.water},
      {
        'key': 'jungle',
        'name': TrKeys.themeStyleJungle.tr,
        'icon': Icons.forest
      },
      {
        'key': 'princess',
        'name': TrKeys.themeStylePrincess.tr,
        'icon': Icons.diamond
      },
    ];

    // Obtener estilo seleccionado actual
    final selectedStyle = currentSettings['theme'] as String? ?? 'default';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TrKeys.themeStyle.tr,
          style: const TextStyle(
            fontSize: AppDimensions.fontSm,
            color: AppColors.textMedium,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Wrap(
          spacing: AppDimensions.sm,
          runSpacing: AppDimensions.sm,
          children: styles.map((style) {
            final isSelected = selectedStyle == style['key'];
            final color = _getColorFromStyle(style['key'] as String);

            return InkWell(
              onTap: () => onSettingUpdated('theme', style['key']),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                  vertical: AppDimensions.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusMd),
                  border: Border.all(
                    color: isSelected ? color : AppColors.textLight,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      style['icon'] as IconData,
                      size: AppDimensions.iconSm,
                      color: isSelected ? color : AppColors.textMedium,
                    ),
                    const SizedBox(width: AppDimensions.xs),
                    Text(
                      style['name'] as String,
                      style: TextStyle(
                        fontSize: AppDimensions.fontSm,
                        color: isSelected ? color : AppColors.textMedium,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Selector de tamaño de interfaz
  Widget _buildInterfaceSizeSelector() {
    // Definir tamaños disponibles
    final sizes = [
      {'key': 'small', 'name': TrKeys.interfaceSizeSmall.tr},
      {'key': 'medium', 'name': TrKeys.interfaceSizeMedium.tr},
      {'key': 'large', 'name': TrKeys.interfaceSizeLarge.tr},
    ];

    // Obtener tamaño seleccionado actual
    final selectedSize =
        currentSettings['interfaceSize'] as String? ?? 'medium';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TrKeys.interfaceSize.tr,
          style: const TextStyle(
            fontSize: AppDimensions.fontSm,
            color: AppColors.textMedium,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        SegmentedButton<String>(
          segments: sizes.map((size) {
            return ButtonSegment<String>(
              value: size['key'] as String,
              label: Text(size['name'] as String),
            );
          }).toList(),
          selected: {selectedSize},
          onSelectionChanged: (Set<String> selection) {
            if (selection.isNotEmpty) {
              onSettingUpdated('interfaceSize', selection.first);
            }
          },
        ),
      ],
    );
  }

  /// Obtiene el color correspondiente al estilo seleccionado
  Color _getColorFromStyle(String style) {
    switch (style) {
      case 'space':
        return AppColors.childBlue;
      case 'sea':
        return AppColors.info;
      case 'jungle':
        return AppColors.childGreen;
      case 'princess':
        return AppColors.childPink;
      default:
        return AppColors.primary;
    }
  }
}
