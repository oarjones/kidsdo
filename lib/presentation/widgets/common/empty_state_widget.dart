// lib/presentation/widgets/common/empty_state_widget.dart
import 'package:flutter/material.dart';
import 'package:kidsdo/core/constants/colors.dart'; // Asegúrate que la ruta sea correcta
import 'package:kidsdo/core/constants/dimensions.dart'; // Asegúrate que la ruta sea correcta

class EmptyStateWidget extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? message;
  final String? retryButtonText;
  final VoidCallback? onRetry;
  final Widget? customAction; // Para acciones más complejas que un simple botón

  const EmptyStateWidget({
    super.key,
    this.icon,
    required this.title,
    this.message,
    this.retryButtonText,
    this.onRetry,
    this.customAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (icon != null)
              Icon(
                icon,
                size: AppDimensions.iconXl *
                    1.5, // Un poco más grande para el estado vacío
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.4),
              ),
            if (icon != null) const SizedBox(height: AppDimensions.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: .8),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (message != null && message!.isNotEmpty)
              const SizedBox(height: AppDimensions.sm),
            if (message != null && message!.isNotEmpty)
              Text(
                message!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
            if (customAction != null)
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.lg),
                child: customAction,
              ),
            if (customAction == null &&
                onRetry != null &&
                retryButtonText != null &&
                retryButtonText!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.lg),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons
                      .add_circle_outline), // Icono genérico para "crear" o "reintentar"
                  label: Text(retryButtonText!),
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    // Puedes usar el color primario o uno específico para acciones de estado vacío
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.lg,
                      vertical: AppDimensions.sm,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
