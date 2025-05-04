import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/challenge.dart';
import 'package:kidsdo/domain/entities/family_child.dart';
import 'package:kidsdo/presentation/widgets/common/cached_avatar.dart';

class MultiChildSelectorWidget extends StatefulWidget {
  final List<FamilyChild> children;
  final Challenge? challenge;
  final Function(List<FamilyChild>) onSelectionChanged;
  final List<FamilyChild>? initialSelection;

  const MultiChildSelectorWidget({
    Key? key,
    required this.children,
    required this.onSelectionChanged,
    this.challenge,
    this.initialSelection,
  }) : super(key: key);

  @override
  State<MultiChildSelectorWidget> createState() =>
      _MultiChildSelectorWidgetState();
}

class _MultiChildSelectorWidgetState extends State<MultiChildSelectorWidget> {
  late Set<String> selectedIds;

  @override
  void initState() {
    super.initState();
    // Inicializar con la selección inicial si existe
    selectedIds =
        widget.initialSelection?.map((child) => child.id).toSet() ?? <String>{};
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 50)),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
      ),
      child: Column(
        children: [
          // Encabezado con acciones
          Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  TrKeys.assignToChildren.tr,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontLg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: _selectAll,
                      child: Text(TrKeys.selectAll.tr),
                    ),
                    const Text(' / '),
                    TextButton(
                      onPressed: _clearSelection,
                      child: Text(TrKeys.clearSelection.tr),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Lista de niños
          if (widget.children.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Column(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber,
                    size: 48,
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    TrKeys.noChildrenProfiles.tr,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontLg,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    TrKeys.noChildProfilesAccessMessage.tr,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.children.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final child = widget.children[index];
                final isSelected = selectedIds.contains(child.id);
                final isAgeAppropriate = _isAgeAppropriate(child);

                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (_) => _toggleChild(child.id),
                  secondary: CachedAvatar(
                    url: child.avatarUrl,
                    radius: 24,
                  ),
                  title: Text(
                    child.name,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${child.age} ${TrKeys.yearsOld.tr}'),
                      if (!isAgeAppropriate) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.warning_amber,
                                size: 16, color: Colors.amber.shade700),
                            const SizedBox(width: 4),
                            Text(
                              TrKeys.ageAppropriate.tr,
                              style: TextStyle(
                                color: Colors.amber.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  activeColor: AppColors.primary,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md,
                    vertical: AppDimensions.sm,
                  ),
                );
              },
            ),

          // Resumen de selección
          if (widget.children.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 10),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppDimensions.borderRadiusLg),
                  bottomRight: Radius.circular(AppDimensions.borderRadiusLg),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Text(
                    _getSelectionSummary(),
                    style: TextStyle(
                      fontSize: AppDimensions.fontSm,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool _isAgeAppropriate(FamilyChild child) {
    if (widget.challenge == null) return true;

    final challengeMinAge = widget.challenge!.ageRange['min'] as int;
    final challengeMaxAge = widget.challenge!.ageRange['max'] as int;

    return child.age >= challengeMinAge && child.age <= challengeMaxAge;
  }

  void _toggleChild(String childId) {
    setState(() {
      if (selectedIds.contains(childId)) {
        selectedIds.remove(childId);
      } else {
        selectedIds.add(childId);
      }
    });

    // Notificar cambios al padre
    final selectedChildren = widget.children
        .where((child) => selectedIds.contains(child.id))
        .toList();
    widget.onSelectionChanged(selectedChildren);
  }

  void _selectAll() {
    setState(() {
      selectedIds = widget.children.map((child) => child.id).toSet();
    });

    // Notificar cambios al padre
    widget.onSelectionChanged(widget.children);
  }

  void _clearSelection() {
    setState(() {
      selectedIds.clear();
    });

    // Notificar cambios al padre
    widget.onSelectionChanged([]);
  }

  String _getSelectionSummary() {
    if (selectedIds.isEmpty) {
      return TrKeys.noChildrenAvailable.tr;
    }

    final count = selectedIds.length;
    if (count == 1) {
      return '1 ${TrKeys.childName.tr.toLowerCase()} ${TrKeys.selected.tr.toLowerCase()}';
    } else {
      return '$count ${TrKeys.children.tr.toLowerCase()} ${TrKeys.selected.tr.toLowerCase()}';
    }
  }
}
