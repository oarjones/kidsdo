import 'package:flutter/material.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';

enum MessageType { error, success, info, warning }

class AuthMessage extends StatelessWidget {
  final String message;
  final MessageType type;
  final IconData? icon;
  final VoidCallback? onDismiss;

  const AuthMessage({
    Key? key,
    required this.message,
    this.type = MessageType.error,
    this.icon,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        border: Border.all(
          color: _getBorderColor(),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? _getDefaultIcon(),
            color: _getIconColor(),
            size: 18,
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: AppDimensions.fontSm,
                color: _getTextColor(),
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              color: _getIconColor(),
            ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case MessageType.error:
        return AppColors.error.withValues(alpha: 0.1);
      case MessageType.success:
        return AppColors.success.withValues(alpha: 0.1);
      case MessageType.warning:
        return AppColors.warning.withValues(alpha: 0.1);
      case MessageType.info:
        return AppColors.info.withValues(alpha: 0.1);
    }
  }

  Color _getBorderColor() {
    switch (type) {
      case MessageType.error:
        return AppColors.error.withValues(alpha: 0.3);
      case MessageType.success:
        return AppColors.success.withValues(alpha: 0.3);
      case MessageType.warning:
        return AppColors.warning.withValues(alpha: 0.3);
      case MessageType.info:
        return AppColors.info.withValues(alpha: 0.3);
    }
  }

  Color _getTextColor() {
    switch (type) {
      case MessageType.error:
        return AppColors.error;
      case MessageType.success:
        return AppColors.success;
      case MessageType.warning:
        return AppColors.warning;
      case MessageType.info:
        return AppColors.info;
    }
  }

  Color _getIconColor() {
    return _getTextColor();
  }

  IconData _getDefaultIcon() {
    switch (type) {
      case MessageType.error:
        return Icons.error_outline;
      case MessageType.success:
        return Icons.check_circle_outline;
      case MessageType.warning:
        return Icons.warning_amber_outlined;
      case MessageType.info:
        return Icons.info_outline;
    }
  }
}
