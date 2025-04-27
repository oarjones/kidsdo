import 'package:flutter/material.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';

class ChallengeIconSelector extends StatelessWidget {
  final String selectedIcon;
  final Function(String) onSelectIcon;

  const ChallengeIconSelector({
    Key? key,
    required this.selectedIcon,
    required this.onSelectIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 50)),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
      ),
      child: Column(
        children: [
          // Mostrar ícono seleccionado
          if (selectedIcon.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.md),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusMd),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 10),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getIconData(selectedIcon),
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    selectedIcon,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

          // Grid de íconos disponibles
          Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: _availableIcons.length,
              itemBuilder: (context, index) {
                final iconName = _availableIcons[index];
                final isSelected = selectedIcon == iconName;
                return InkWell(
                  onTap: () => onSelectIcon(iconName),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusMd),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryLight
                          : Colors.grey.withValues(alpha: 20),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.borderRadiusMd),
                      border: isSelected
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                    ),
                    child: Icon(
                      _getIconData(iconName),
                      color:
                          isSelected ? AppColors.primary : Colors.grey.shade700,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Lista de nombres de íconos disponibles
  static const List<String> _availableIcons = [
    'tooth_brush',
    'shower',
    'soap',
    'hair_brush',
    'book',
    'book_open',
    'backpack',
    'star',
    'bed',
    'toys',
    'room',
    'tshirt',
    'clock',
    'alarm',
    'pet',
    'plant',
    'cutlery',
    'dishes',
    'trash',
    'grocery',
    'garden',
    'recycle',
    'party',
    'share',
    'play',
    'help',
    'handshake',
  ];

  // Función para convertir nombre de ícono a IconData
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'tooth_brush':
        return Icons.clear;
      case 'shower':
        return Icons.shower;
      case 'soap':
        return Icons.soap;
      case 'hair_brush':
        return Icons.brush;
      case 'book':
        return Icons.book;
      case 'book_open':
        return Icons.menu_book;
      case 'backpack':
        return Icons.backpack;
      case 'star':
        return Icons.star;
      case 'bed':
        return Icons.bed;
      case 'toys':
        return Icons.toys;
      case 'room':
        return Icons.bedroom_child;
      case 'tshirt':
        return Icons.dry_cleaning;
      case 'clock':
        return Icons.access_time;
      case 'alarm':
        return Icons.alarm;
      case 'pet':
        return Icons.pets;
      case 'plant':
        return Icons.yard;
      case 'cutlery':
        return Icons.fastfood;
      case 'dishes':
        return Icons.kitchen;
      case 'trash':
        return Icons.delete;
      case 'grocery':
        return Icons.shopping_basket;
      case 'garden':
        return Icons.nature;
      case 'recycle':
        return Icons.recycling;
      case 'party':
        return Icons.celebration;
      case 'share':
        return Icons.share;
      case 'play':
        return Icons.sports_esports;
      case 'help':
        return Icons.help_center;
      case 'handshake':
        return Icons.handshake;
      default:
        return Icons.star;
    }
  }
}
