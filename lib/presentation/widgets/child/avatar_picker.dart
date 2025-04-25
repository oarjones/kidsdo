import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';

class AvatarPicker extends StatefulWidget {
  /// Imagen actualmente seleccionada (si hay una)
  final File? selectedImage;

  /// URL del avatar actual (si existe)
  final String? currentAvatarUrl;

  /// Avatar predefinido seleccionado (si existe)
  final String? selectedPredefinedAvatar;

  /// Función para manejar la selección de un avatar predefinido
  final Function(String avatarKey) onPredefinedAvatarSelected;

  /// Función para manejar la selección de una imagen
  final VoidCallback onPickImage;

  /// Función para eliminar la imagen seleccionada
  final VoidCallback onClearImage;

  /// Indica si se está cargando una imagen
  final bool isUploading;

  /// Progreso de carga (0.0 - 1.0)
  final double uploadProgress;

  /// Tamaño del avatar
  final double avatarSize;

  /// Tamaño del ícono del botón
  final double iconSize;

  const AvatarPicker({
    Key? key,
    this.selectedImage,
    this.currentAvatarUrl,
    this.selectedPredefinedAvatar,
    required this.onPredefinedAvatarSelected,
    required this.onPickImage,
    required this.onClearImage,
    this.isUploading = false,
    this.uploadProgress = 0.0,
    this.avatarSize = 120.0,
    this.iconSize = 24.0,
  }) : super(key: key);

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  /// Determina si el selector de avatares predefinidos está visible
  bool _showPredefinedAvatars = false;

  /// Lista de avatares predefinidos disponibles
  final List<Map<String, dynamic>> _predefinedAvatars = [
    {'key': 'boy1', 'icon': Icons.face, 'color': AppColors.childBlue},
    {'key': 'girl1', 'icon': Icons.face, 'color': AppColors.childPink},
    {
      'key': 'boy2',
      'icon': Icons.sentiment_satisfied,
      'color': AppColors.childGreen
    },
    {
      'key': 'girl2',
      'icon': Icons.sentiment_very_satisfied,
      'color': AppColors.childPurple
    },
    {
      'key': 'boy3',
      'icon': Icons.emoji_emotions,
      'color': AppColors.childOrange
    },
    {'key': 'girl3', 'icon': Icons.emoji_emotions, 'color': AppColors.primary},
    {'key': 'astronaut', 'icon': Icons.rocket_launch, 'color': AppColors.info},
    {'key': 'superhero', 'icon': Icons.flash_on, 'color': AppColors.warning},
    {'key': 'robot', 'icon': Icons.smart_toy, 'color': AppColors.bronze},
    {'key': 'animal', 'icon': Icons.pets, 'color': AppColors.success},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar actual
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            // Avatar (imagen, URL o predefinido)
            _buildAvatarDisplay(),

            // Botón para cambiar avatar
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: _buildAvatarButton(),
            ),

            // Indicador de progreso si está subiendo
            if (widget.isUploading)
              Positioned.fill(
                child: CircularProgressIndicator(
                  value: widget.uploadProgress,
                  strokeWidth: 3,
                  backgroundColor: Colors.white.withValues(alpha: 0.5),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
          ],
        ),

        // Selector de avatares predefinidos
        if (_showPredefinedAvatars) ...[
          const SizedBox(height: AppDimensions.md),
          _buildPredefinedAvatarSelector(),
        ],
      ],
    );
  }

  Widget _buildAvatarDisplay() {
    // Primero mostrar la imagen seleccionada si hay una
    if (widget.selectedImage != null) {
      return CircleAvatar(
        radius: widget.avatarSize / 2,
        backgroundImage: FileImage(widget.selectedImage!),
      );
    }

    // Luego mostrar la URL si hay una
    else if (widget.currentAvatarUrl != null &&
        widget.currentAvatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: widget.avatarSize / 2,
        backgroundImage: NetworkImage(widget.currentAvatarUrl!),
      );
    }

    // Si hay un avatar predefinido seleccionado
    else if (widget.selectedPredefinedAvatar != null) {
      final selectedAvatar = _predefinedAvatars.firstWhere(
        (avatar) => avatar['key'] == widget.selectedPredefinedAvatar,
        orElse: () => _predefinedAvatars.first,
      );

      return CircleAvatar(
        radius: widget.avatarSize / 2,
        backgroundColor: selectedAvatar['color'].withOpacity(0.2),
        child: Icon(
          selectedAvatar['icon'],
          size: widget.avatarSize / 2,
          color: selectedAvatar['color'],
        ),
      );
    }

    // Avatar por defecto
    return CircleAvatar(
      radius: widget.avatarSize / 2,
      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
      child: Icon(
        Icons.person,
        size: widget.avatarSize / 2,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildAvatarButton() {
    // Si hay una imagen seleccionada o una URL, mostrar botón para eliminar
    if (widget.selectedImage != null ||
        (widget.currentAvatarUrl != null &&
            widget.currentAvatarUrl!.isNotEmpty) ||
        widget.selectedPredefinedAvatar != null) {
      return IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () {
          widget.onClearImage();
          setState(() {
            _showPredefinedAvatars = false;
          });
        },
      );
    }

    // Si no hay imagen, mostrar botón para seleccionar
    return IconButton(
      icon: const Icon(Icons.add_a_photo, color: Colors.white),
      onPressed: () {
        setState(() {
          _showPredefinedAvatars = !_showPredefinedAvatars;
        });
      },
    );
  }

  Widget _buildPredefinedAvatarSelector() {
    return Column(
      children: [
        Text(
          TrKeys.selectAvatarOption.tr,
          style: const TextStyle(
            fontSize: AppDimensions.fontSm,
            color: AppColors.textMedium,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),

        // Grid de avatares predefinidos
        Wrap(
          spacing: AppDimensions.sm,
          runSpacing: AppDimensions.sm,
          alignment: WrapAlignment.center,
          children: [
            // Opción para subir imagen personalizada
            _buildCustomImageOption(),

            // Avatares predefinidos
            ..._predefinedAvatars.map(_buildPredefinedAvatarOption).toList(),
          ],
        ),
      ],
    );
  }

  Widget _buildPredefinedAvatarOption(Map<String, dynamic> avatar) {
    final bool isSelected = widget.selectedPredefinedAvatar == avatar['key'];

    return InkWell(
      onTap: () {
        widget.onPredefinedAvatarSelected(avatar['key']);
        setState(() {
          _showPredefinedAvatars = false;
        });
      },
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCircular),
      child: Container(
        width: 60,
        height: 60,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border:
              isSelected ? Border.all(color: avatar['color'], width: 2) : null,
        ),
        child: CircleAvatar(
          backgroundColor: avatar['color'].withOpacity(0.2),
          child: Icon(
            avatar['icon'],
            color: avatar['color'],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomImageOption() {
    return InkWell(
      onTap: widget.onPickImage,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCircular),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.add_photo_alternate,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
