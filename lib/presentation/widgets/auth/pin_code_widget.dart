import 'package:flutter/material.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';

class PinCodeWidget extends StatefulWidget {
  final int pinLength;
  final Function(String) onPinEntered;
  final String title;
  final String subtitle;
  final bool isError;
  final String errorMessage;

  const PinCodeWidget({
    Key? key,
    this.pinLength = 4,
    required this.onPinEntered,
    required this.title,
    this.subtitle = '',
    this.isError = false,
    this.errorMessage = '',
  }) : super(key: key);

  @override
  State<PinCodeWidget> createState() => _PinCodeWidgetState();
}

class _PinCodeWidgetState extends State<PinCodeWidget>
    with SingleTickerProviderStateMixin {
  late List<String> _pin;
  late AnimationController _errorAnimationController;
  late Animation<Offset> _errorAnimation;

  @override
  void initState() {
    super.initState();
    _pin = List.filled(widget.pinLength, '');

    _errorAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _errorAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.05, 0),
    ).animate(CurvedAnimation(
      parent: _errorAnimationController,
      curve: Curves.elasticIn,
    ));

    _errorAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _errorAnimationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _errorAnimationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PinCodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isError && !oldWidget.isError) {
      _playErrorAnimation();
    }
  }

  void _playErrorAnimation() {
    _errorAnimationController.forward();
  }

  void _addDigit(String digit) {
    if (_pin.contains('')) {
      final index = _pin.indexOf('');
      setState(() {
        _pin[index] = digit;
      });

      // Si se completó el PIN
      if (!_pin.contains('')) {
        final completePin = _pin.join();
        widget.onPinEntered(completePin);
      }
    }
  }

  void _removeDigit() {
    if (!_pin.contains('')) {
      // Si está lleno, eliminar el último
      setState(() {
        _pin[_pin.length - 1] = '';
      });
    } else if (_pin.every((digit) => digit.isEmpty)) {
      // Si está vacío, no hacer nada
      return;
    } else {
      // Encontrar el índice del último dígito no vacío
      int lastFilledIndex = _pin.lastIndexWhere((digit) => digit.isNotEmpty);
      if (lastFilledIndex >= 0) {
        setState(() {
          _pin[lastFilledIndex] = '';
        });
      }
    }
  }

  void _clearPin() {
    setState(() {
      _pin = List.filled(widget.pinLength, '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Título y subtítulo
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: AppDimensions.fontXl,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        if (widget.subtitle.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.sm),
          Text(
            widget.subtitle,
            style: const TextStyle(
              fontSize: AppDimensions.fontMd,
              color: AppColors.textMedium,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AppDimensions.lg),

        // Campos de PIN
        SlideTransition(
          position: _errorAnimation,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.pinLength,
              (index) => _buildPinBox(index),
            ),
          ),
        ),

        // Mensaje de error
        if (widget.isError && widget.errorMessage.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.md),
          Text(
            widget.errorMessage,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: AppDimensions.fontSm,
            ),
            textAlign: TextAlign.center,
          ),
        ],

        const SizedBox(height: AppDimensions.xl),

        // Teclado numérico
        _buildNumericKeyboard(),
      ],
    );
  }

  Widget _buildPinBox(int index) {
    final hasValue = _pin[index].isNotEmpty;
    final isActive = !hasValue && _pin.take(index).every((d) => d.isNotEmpty);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.sm),
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: hasValue
            ? AppColors.primary.withValues(alpha: 30)
            : (isActive
                ? Colors.grey.withValues(alpha: 20)
                : Colors.grey.withValues(alpha: 10)),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        border: Border.all(
          color: hasValue
              ? AppColors.primary
              : (isActive ? Colors.grey.shade400 : Colors.grey.shade300),
          width: hasValue ? 2 : 1,
        ),
      ),
      child: Center(
        child: hasValue
            ? Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildNumericKeyboard() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildKeyboardButton('1'),
            _buildKeyboardButton('2'),
            _buildKeyboardButton('3'),
          ],
        ),
        const SizedBox(height: AppDimensions.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildKeyboardButton('4'),
            _buildKeyboardButton('5'),
            _buildKeyboardButton('6'),
          ],
        ),
        const SizedBox(height: AppDimensions.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildKeyboardButton('7'),
            _buildKeyboardButton('8'),
            _buildKeyboardButton('9'),
          ],
        ),
        const SizedBox(height: AppDimensions.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(
              icon: Icons.backspace,
              onTap: _removeDigit,
              backgroundColor: Colors.red.withValues(alpha: 20),
              iconColor: Colors.red,
            ),
            _buildKeyboardButton('0'),
            _buildActionButton(
              icon: Icons.refresh,
              onTap: _clearPin,
              backgroundColor: Colors.blue.withValues(alpha: 20),
              iconColor: Colors.blue,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyboardButton(String digit) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _addDigit(digit),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
        child: Container(
          width: 80,
          height: 70,
          margin: const EdgeInsets.symmetric(horizontal: AppDimensions.xs),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
          ),
          child: Center(
            child: Text(
              digit,
              style: const TextStyle(
                fontSize: AppDimensions.fontXxl,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
        child: Container(
          width: 80,
          height: 70,
          margin: const EdgeInsets.symmetric(horizontal: AppDimensions.xs),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
            color: backgroundColor,
          ),
          child: Center(
            child: Icon(
              icon,
              color: iconColor,
              size: AppDimensions.iconLg,
            ),
          ),
        ),
      ),
    );
  }
}
