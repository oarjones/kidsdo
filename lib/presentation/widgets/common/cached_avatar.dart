import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kidsdo/core/constants/colors.dart';

class CachedAvatar extends StatelessWidget {
  final String? url;
  final double radius;
  final Widget? placeholder;
  final BorderSide? border;

  const CachedAvatar({
    Key? key,
    this.url,
    required this.radius,
    this.placeholder,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return placeholder ?? _buildDefaultAvatar();
    }

    return CachedNetworkImage(
      imageUrl: url!,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
        backgroundColor: Colors.transparent,
      ),
      placeholder: (context, url) => placeholder ?? _buildLoadingAvatar(),
      errorWidget: (context, url, error) => placeholder ?? _buildErrorAvatar(),
    );
  }

  CircleAvatar _buildDefaultAvatar() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      child: Icon(
        Icons.person,
        size: radius,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildLoadingAvatar() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      child: SizedBox(
        width: radius / 2,
        height: radius / 2,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildErrorAvatar() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.error.withValues(alpha: 0.1),
      child: Icon(
        Icons.error_outline,
        size: radius / 2,
        color: AppColors.error,
      ),
    );
  }
}
