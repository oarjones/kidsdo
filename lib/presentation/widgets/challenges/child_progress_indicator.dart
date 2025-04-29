import 'package:flutter/material.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/presentation/widgets/child/age_adapted_container.dart';

class ChildProgressIndicator extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final int childAge;
  final Map<String, dynamic> settings;
  final Color color;
  final String label;
  final double height;

  const ChildProgressIndicator({
    Key? key,
    required this.progress,
    required this.childAge,
    required this.settings,
    required this.color,
    required this.label,
    this.height = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AgeAdaptedContainer(
      childAge: childAge,
      settings: settings,
      padding: EdgeInsets.zero,
      defaultWidget: _buildDefaultProgressBar(),
      youngChildWidget: _buildYoungChildProgressBar(),
    );
  }

  Widget _buildDefaultProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta del progreso
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppDimensions.fontSm,
            color: color,
          ),
        ),
        const SizedBox(height: AppDimensions.xs),

        // Barra de progreso
        Stack(
          children: [
            // Fondo
            Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 100),
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),

            // Progreso
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: height,
              width: double.infinity * progress,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(height / 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 100),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),

            // Porcentaje
            Center(
              child: SizedBox(
                height: height,
                child: Center(
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      color: progress > 0.5 ? Colors.white : Colors.black,
                      fontSize: AppDimensions.fontXs,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildYoungChildProgressBar() {
    // Versión más visual y llamativa para niños pequeños
    final int progressPercent = (progress * 100).toInt();
    const int starsTotal = 5;
    final int starsFilled = (progress * starsTotal).round();

    return Column(
      children: [
        // Etiqueta grande
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppDimensions.fontMd,
            color: color,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),

        // Estrellas de progreso
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(starsTotal, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Icon(
                index < starsFilled ? Icons.star : Icons.star_border,
                color: color,
                size: 32,
              ),
            );
          }),
        ),

        const SizedBox(height: AppDimensions.sm),

        // Barra decorativa con animación
        Stack(
          children: [
            // Fondo
            Container(
              height: height * 1.5, // Más grande
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 100),
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusLg),
                border: Border.all(color: Colors.grey.withValues(alpha: 150)),
              ),
            ),

            // Progreso
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              height: height * 1.5,
              width: double.infinity * progress,
              decoration: BoxDecoration(
                color: color,
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusLg),
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 150), color],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 100),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),

            // Iconos decorativos a lo largo de la barra
            if (progress > 0)
              Positioned(
                right: 10,
                top: 0,
                bottom: 0,
                child: Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: height,
                ),
              ),

            // Porcentaje grande
            Center(
              child: SizedBox(
                height: height * 1.5,
                child: Center(
                  child: Text(
                    '$progressPercent%',
                    style: TextStyle(
                      color: progress > 0.4 ? Colors.white : Colors.black,
                      fontSize: AppDimensions.fontMd,
                      fontWeight: FontWeight.bold,
                      shadows: progress > 0.4
                          ? [
                              const Shadow(
                                color: Colors.black45,
                                blurRadius: 2,
                                offset: Offset(1, 1),
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
