import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/challenge.dart';

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final int adaptedPoints;
  final int childAge;
  final Rx<bool> isSelected;
  final VoidCallback onSelect;
  final VoidCallback onConvert;
  final VoidCallback onTap;

  const ChallengeCard({
    Key? key,
    required this.challenge,
    required this.adaptedPoints,
    required this.childAge,
    required this.isSelected,
    required this.onSelect,
    required this.onConvert,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determinar si el reto es apropiado para la edad
    final bool isAgeAppropriate =
        childAge >= (challenge.ageRange['min'] as int) &&
            childAge <= (challenge.ageRange['max'] as int);

    // Determinar si los puntos fueron adaptados
    final bool pointsWereAdapted = adaptedPoints != challenge.points;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected.value
            ? const BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado con título y selección
              Row(
                children: [
                  // Icono de categoría
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(challenge.category)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(challenge.category),
                      color: _getCategoryColor(challenge.category),
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Título y categoría
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildCategoryChip(challenge.category),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Checkbox para selección
                  Obx(() => Checkbox(
                        value: isSelected.value,
                        onChanged: (_) => onSelect(),
                        activeColor: AppColors.primary,
                      )),
                ],
              ),

              const SizedBox(height: 12),

              // Descripción
              Text(
                challenge.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Detalles y acciones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Rango de edad
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TrKeys.ageRange.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "${challenge.ageRange['min']} - ${challenge.ageRange['max']} ${TrKeys.years.tr}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  isAgeAppropriate ? Colors.black : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 4),
                          if (isAgeAppropriate)
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 16)
                          else
                            Icon(Icons.warning,
                                color: Colors.amber.shade700, size: 16),
                        ],
                      ),
                    ],
                  ),

                  // Puntos
                  _buildPointsDisplay(
                      challenge.points, adaptedPoints, pointsWereAdapted),
                ],
              ),

              const SizedBox(height: 12),

              // Botones de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Botón para convertir a reto familiar
                  TextButton.icon(
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: Text(TrKeys.addToFamily.tr),
                    onPressed: onConvert,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),

                  // Botón para ver detalles
                  TextButton.icon(
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: Text(TrKeys.details.tr),
                    onPressed: onTap,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Construir chip de categoría
  Widget _buildCategoryChip(ChallengeCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getCategoryColor(category).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _getCategoryName(category),
        style: TextStyle(
          fontSize: 10,
          color: _getCategoryColor(category),
        ),
      ),
    );
  }

  // Construir visualización de puntos
  Widget _buildPointsDisplay(
      int originalPoints, int adaptedPoints, bool pointsWereAdapted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          TrKeys.points.tr,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        Row(
          children: [
            if (pointsWereAdapted)
              Text(
                "$originalPoints",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
            if (pointsWereAdapted) const SizedBox(width: 8),
            Text(
              "$adaptedPoints",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: pointsWereAdapted
                    ? (adaptedPoints > originalPoints
                        ? Colors.green
                        : Colors.orange)
                    : Colors.black,
              ),
            ),
            if (pointsWereAdapted)
              Icon(
                adaptedPoints > originalPoints
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                size: 16,
                color: adaptedPoints > originalPoints
                    ? Colors.green
                    : Colors.orange,
              ),
          ],
        ),
      ],
    );
  }

  // Obtener nombre de categoría
  String _getCategoryName(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.hygiene:
        return TrKeys.categoryHygiene.tr;
      case ChallengeCategory.school:
        return TrKeys.categorySchool.tr;
      case ChallengeCategory.order:
        return TrKeys.categoryOrder.tr;
      case ChallengeCategory.responsibility:
        return TrKeys.categoryResponsibility.tr;
      case ChallengeCategory.help:
        return TrKeys.categoryHelp.tr;
      case ChallengeCategory.special:
        return TrKeys.categorySpecial.tr;
      case ChallengeCategory.sibling:
        return TrKeys.categorySibling.tr;
    }
  }

  // Obtener color de categoría
  Color _getCategoryColor(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.hygiene:
        return Colors.blue;
      case ChallengeCategory.school:
        return Colors.purple;
      case ChallengeCategory.order:
        return Colors.teal;
      case ChallengeCategory.responsibility:
        return Colors.orange;
      case ChallengeCategory.help:
        return Colors.green;
      case ChallengeCategory.special:
        return Colors.pink;
      case ChallengeCategory.sibling:
        return Colors.indigo;
    }
  }

  // Obtener icono de categoría
  IconData _getCategoryIcon(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.hygiene:
        return Icons.clean_hands;
      case ChallengeCategory.school:
        return Icons.school;
      case ChallengeCategory.order:
        return Icons.cleaning_services;
      case ChallengeCategory.responsibility:
        return Icons.assignment_turned_in;
      case ChallengeCategory.help:
        return Icons.emoji_people;
      case ChallengeCategory.special:
        return Icons.celebration;
      case ChallengeCategory.sibling:
        return Icons.family_restroom;
    }
  }
}
