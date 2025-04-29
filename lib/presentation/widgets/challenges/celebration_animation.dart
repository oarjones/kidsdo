import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'dart:math' as math;

class CelebrationAnimation extends StatefulWidget {
  final int points;
  final String message;
  final VoidCallback onClose;

  const CelebrationAnimation({
    Key? key,
    required this.points,
    required this.message,
    required this.onClose,
  }) : super(key: key);

  @override
  State<CelebrationAnimation> createState() => _CelebrationAnimationState();
}

class _CelebrationAnimationState extends State<CelebrationAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _opacityAnimation;

  final List<Color> _confettiColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
  ];

  final List<Confetti> _confettiItems = [];

  @override
  void initState() {
    super.initState();

    // Configurar animaciones
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Generar confeti
    _generateConfetti();

    // Iniciar animación
    _controller.forward();

    // Auto-cerrar después de un tiempo
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onClose();
      }
    });
  }

  void _generateConfetti() {
    final random = math.Random();
    for (int i = 0; i < 50; i++) {
      _confettiItems.add(
        Confetti(
          color: _confettiColors[random.nextInt(_confettiColors.length)],
          position: Offset(
            random.nextDouble() * Get.width,
            -random.nextDouble() * Get.height * 0.5,
          ),
          size: random.nextDouble() * 10 + 5,
          velocity: Offset(
            (random.nextDouble() - 0.5) * 6,
            random.nextDouble() * 6 + 4,
          ),
          rotationSpeed: (random.nextDouble() - 0.5) * 0.1,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: Stack(
        children: [
          // Fondo semitransparente
          Container(
            color: Colors.black.withValues(alpha: 150),
          ),

          // Confetti animado
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Actualizar posiciones del confeti
              for (final confetti in _confettiItems) {
                confetti.position += confetti.velocity;
                confetti.rotation += confetti.rotationSpeed;
              }

              return CustomPaint(
                painter: ConfettiPainter(confetti: _confettiItems),
                size: Size(Get.width, Get.height),
              );
            },
          ),

          // Contenido central
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: math.sin(_controller.value * math.pi * 4) *
                        _rotateAnimation.value,
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: child,
                    ),
                  ),
                );
              },
              child: Container(
                width: Get.width * 0.8,
                padding: const EdgeInsets.all(AppDimensions.xl),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 50),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icono de celebración
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.lg),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.celebration,
                        color: AppColors.success,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.lg),

                    // Mensaje
                    Text(
                      widget.message,
                      style: const TextStyle(
                        fontSize: AppDimensions.fontLg,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.md),

                    // Puntos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 32,
                        ),
                        const SizedBox(width: AppDimensions.sm),
                        Text(
                          '${widget.points} ${TrKeys.points.tr}',
                          style: const TextStyle(
                            fontSize: AppDimensions.fontXl,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.lg),

                    // Botón para cerrar
                    ElevatedButton.icon(
                      onPressed: widget.onClose,
                      icon: const Icon(Icons.check),
                      label: Text(TrKeys.awesome.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.lg,
                          vertical: AppDimensions.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusMd),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Confetti {
  Color color;
  Offset position;
  double size;
  Offset velocity;
  double rotation;
  double rotationSpeed;

  Confetti({
    required this.color,
    required this.position,
    required this.size,
    required this.velocity,
    this.rotation = 0.0,
    required this.rotationSpeed,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<Confetti> confetti;

  ConfettiPainter({required this.confetti});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final item in confetti) {
      paint.color = item.color;

      canvas.save();
      canvas.translate(item.position.dx, item.position.dy);
      canvas.rotate(item.rotation);

      // Dibujar diferentes formas para el confeti
      final random = math.Random(item.hashCode);
      final shapeType = random.nextInt(3);

      switch (shapeType) {
        case 0:
          // Rectángulo
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: item.size,
              height: item.size * 3,
            ),
            paint,
          );
          break;

        case 1:
          // Círculo
          canvas.drawCircle(
            Offset.zero,
            item.size / 2,
            paint,
          );
          break;

        case 2:
          // Triángulo
          final path = Path();
          path.moveTo(0, -item.size / 2);
          path.lineTo(-item.size / 2, item.size / 2);
          path.lineTo(item.size / 2, item.size / 2);
          path.close();
          canvas.drawPath(path, paint);
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
