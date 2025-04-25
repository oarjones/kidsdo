import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';

/// Widget para mostrar una vista previa de cómo se verá la interfaz infantil
/// con la configuración seleccionada
class ThemePreview extends StatelessWidget {
  /// Nombre del niño
  final String childName;

  /// Edad del niño
  final int childAge;

  /// Configuración de tema actual
  final Map<String, dynamic> settings;

  /// URL del avatar (opcional)
  final String? avatarUrl;

  /// Avatar predefinido seleccionado (opcional)
  final String? predefinedAvatar;

  const ThemePreview({
    Key? key,
    required this.childName,
    required this.childAge,
    required this.settings,
    this.avatarUrl,
    this.predefinedAvatar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtener color del tema
    final Color themeColor = _getThemeColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TrKeys.themePreview.tr,
          style: const TextStyle(
            fontSize: AppDimensions.fontMd,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.md),

        // Contenedor principal de la vista previa
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              // Barra superior con el tema
              _buildTopBar(themeColor),

              // Contenido de ejemplo
              _buildPreviewContent(themeColor),
            ],
          ),
        ),
      ],
    );
  }

  /// Construye la barra superior de la vista previa
  Widget _buildTopBar(Color themeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.sm,
        horizontal: AppDimensions.md,
      ),
      decoration: BoxDecoration(
        color: themeColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.borderRadiusLg),
          topRight: Radius.circular(AppDimensions.borderRadiusLg),
        ),
      ),
      child: Row(
        children: [
          // Avatar en pequeño
          _buildAvatar(size: 24),

          const SizedBox(width: AppDimensions.sm),

          // Nombre
          Expanded(
            child: Text(
              childName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Iconos de ejemplo
          const Icon(Icons.notifications, color: Colors.white, size: 18),
          const SizedBox(width: AppDimensions.sm),
          const Icon(Icons.menu, color: Colors.white, size: 18),
        ],
      ),
    );
  }

  /// Construye el contenido de ejemplo
  Widget _buildPreviewContent(Color themeColor) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        children: [
          // Encabezado con saludo
          Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          TrKeys.previewGreeting.tr,
                          style: TextStyle(
                            fontSize: _getAdaptedFontSize(AppDimensions.fontLg),
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          childName,
                          style: TextStyle(
                            fontSize: _getAdaptedFontSize(AppDimensions.fontLg),
                            fontWeight: FontWeight.bold,
                            color: themeColor,
                          ),
                        ),
                        Text(
                          '!',
                          style: TextStyle(
                            fontSize: _getAdaptedFontSize(AppDimensions.fontLg),
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      TrKeys.previewSubtitle.tr,
                      style: TextStyle(
                        fontSize: _getAdaptedFontSize(AppDimensions.fontSm),
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.md),

          // Barra de progreso
          Row(
            children: [
              Icon(Icons.star, color: themeColor, size: 18),
              const SizedBox(width: AppDimensions.xs),
              Expanded(
                child: LinearProgressIndicator(
                  value: 0.7,
                  backgroundColor: themeColor.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: AppDimensions.xs),
              Text(
                '70/100',
                style: TextStyle(
                  fontSize: _getAdaptedFontSize(AppDimensions.fontSm),
                  color: themeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.md),

          // Tarjetas de retos de ejemplo
          Row(
            children: [
              _buildExampleChallengeCard(
                icon: Icons.check_circle_outline,
                title: TrKeys.previewChallenge1.tr,
                isDone: true,
                themeColor: themeColor,
              ),
              const SizedBox(width: AppDimensions.sm),
              _buildExampleChallengeCard(
                icon: Icons.book,
                title: TrKeys.previewChallenge2.tr,
                isDone: false,
                themeColor: themeColor,
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.sm),

          // Botón de ejemplo
          ElevatedButton.icon(
            onPressed: null,
            icon: Icon(Icons.add,
                color: Colors.white,
                size: _getAdaptedFontSize(AppDimensions.iconSm)),
            label: Text(
              TrKeys.previewButton.tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: _getAdaptedFontSize(AppDimensions.fontSm),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              minimumSize: const Size(double.infinity, 36),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusMd),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye un avatar para la vista previa
  Widget _buildAvatar({double size = 48}) {
    // Si hay una URL de avatar
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(avatarUrl!),
      );
    }

    // Si hay un avatar predefinido
    else if (predefinedAvatar != null) {
      final Color color = _getThemeColor();
      IconData icon;

      // Determinar el icono según el avatar predefinido
      switch (predefinedAvatar) {
        case 'astronaut':
          icon = Icons.rocket_launch;
          break;
        case 'superhero':
          icon = Icons.flash_on;
          break;
        case 'robot':
          icon = Icons.smart_toy;
          break;
        case 'animal':
          icon = Icons.pets;
          break;
        default:
          icon = Icons.face;
      }

      return CircleAvatar(
        radius: size / 2,
        backgroundColor: color.withValues(alpha: 0.2),
        child: Icon(
          icon,
          size: size / 2,
          color: color,
        ),
      );
    }

    // Avatar por defecto
    else {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: _getThemeColor().withValues(alpha: 0.2),
        child: Icon(
          Icons.person,
          size: size / 2,
          color: _getThemeColor(),
        ),
      );
    }
  }

  /// Construye una tarjeta de reto de ejemplo
  Widget _buildExampleChallengeCard({
    required IconData icon,
    required String title,
    required bool isDone,
    required Color themeColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.sm),
        decoration: BoxDecoration(
          color:
              isDone ? themeColor.withValues(alpha: 0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
          border: Border.all(
            color: isDone
                ? themeColor.withValues(alpha: 0.3)
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: _getAdaptedFontSize(AppDimensions.iconSm),
              color: isDone ? themeColor : Colors.grey,
            ),
            const SizedBox(width: AppDimensions.xs),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: _getAdaptedFontSize(AppDimensions.fontXs),
                  color: isDone ? themeColor : Colors.grey,
                  fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Obtiene el color del tema basado en las configuraciones
  Color _getThemeColor() {
    final String colorKey = settings['color'] as String? ?? 'blue';

    switch (colorKey) {
      case 'purple':
        return AppColors.childPurple;
      case 'green':
        return AppColors.childGreen;
      case 'orange':
        return AppColors.childOrange;
      case 'pink':
        return AppColors.childPink;
      case 'blue':
      default:
        return AppColors.childBlue;
    }
  }

  /// Obtiene un tamaño de fuente adaptado según el tamaño de interfaz configurado
  double _getAdaptedFontSize(double baseSize) {
    final String interfaceSize =
        settings['interfaceSize'] as String? ?? 'medium';

    switch (interfaceSize) {
      case 'small':
        return baseSize * 0.9;
      case 'large':
        return baseSize * 1.2;
      case 'medium':
      default:
        return baseSize;
    }
  }
}
