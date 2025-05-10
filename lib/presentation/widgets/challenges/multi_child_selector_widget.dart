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
  bool _isInitialBuild = true;

  @override
  void initState() {
    super.initState();
    // Inicializar con todos los niños seleccionados por defecto
    // A menos que haya una selección inicial específica
    selectedIds = widget.initialSelection?.map((child) => child.id).toSet() ??
        widget.children.map((child) => child.id).toSet();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Usamos didChangeDependencies para notificar después de la primera construcción
    if (_isInitialBuild) {
      // Programamos la notificación para después del ciclo de construcción actual
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _notifySelectionChange();
        _isInitialBuild = false;
      });
    }
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
          // Encabezado con acciones - VERSIÓN MEJORADA RESPONSIVA
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.md,
              vertical: AppDimensions.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      TrKeys.assignToChildren.tr,
                      style: const TextStyle(
                        fontSize: AppDimensions.fontMd,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Fila de botones responsiva
                    // Row(
                    //   mainAxisSize: MainAxisSize.min,
                    //   children: [
                    //     InkWell(
                    //       onTap: _selectAll,
                    //       child: Padding(
                    //         padding: const EdgeInsets.symmetric(
                    //             horizontal: AppDimensions.sm,
                    //             vertical: AppDimensions.xs),
                    //         child: Text(
                    //           TrKeys.selectAll.tr,
                    //           style: const TextStyle(
                    //             color: AppColors.primary,
                    //             fontSize: AppDimensions.fontSm,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //     const SizedBox(width: 4),
                    //     Container(
                    //       height: 16,
                    //       width: 1,
                    //       color: Colors.grey.withValues(alpha: 150),
                    //     ),
                    //     const SizedBox(width: 4),
                    //     InkWell(
                    //       onTap: _clearSelection,
                    //       child: Padding(
                    //         padding: const EdgeInsets.symmetric(
                    //             horizontal: AppDimensions.sm,
                    //             vertical: AppDimensions.xs),
                    //         child: Text(
                    //           TrKeys.clearSelection.tr,
                    //           style: TextStyle(
                    //             color: Colors.grey.shade700,
                    //             fontSize: AppDimensions.fontSm,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
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

                return ListTile(
                  onTap: () => _toggleChild(child.id),
                  leading: Stack(
                    children: [
                      CachedAvatar(
                        url: child.avatarUrl,
                        radius: 20,
                      ),
                      // Indicador visual de selección
                      if (isSelected)
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.primary, width: 1),
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    child.name,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: AppDimensions.fontMd,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        '${child.age} ${TrKeys.yearsOld.tr}',
                        style: const TextStyle(fontSize: AppDimensions.fontSm),
                      ),
                      if (!isAgeAppropriate) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.warning_amber,
                            size: 12, color: Colors.amber.shade700),
                      ],
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      isSelected
                          ? Icons.remove_circle_outline
                          : Icons.add_circle_outline,
                      color: isSelected ? Colors.red : AppColors.primary,
                      size: 20,
                    ),
                    onPressed: () => _toggleChild(child.id),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md,
                    vertical: AppDimensions.xs,
                  ),
                );
              },
            ),

          // Resumen de selección
          if (widget.children.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md, vertical: AppDimensions.sm),
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
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: AppDimensions.xs),
                  Expanded(
                    child: Text(
                      _getSelectionSummary(),
                      style: TextStyle(
                        fontSize: AppDimensions.fontSm,
                        color: Colors.grey.shade600,
                      ),
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

    _notifySelectionChange();
  }

  // void _selectAll() {
  //   setState(() {
  //     selectedIds = widget.children.map((child) => child.id).toSet();
  //   });

  //   _notifySelectionChange();
  // }

  // void _clearSelection() {
  //   setState(() {
  //     selectedIds.clear();
  //   });

  //   _notifySelectionChange();
  // }

  // Método para notificar cambios al widget padre
  void _notifySelectionChange() {
    final selectedChildren = widget.children
        .where((child) => selectedIds.contains(child.id))
        .toList();
    widget.onSelectionChanged(selectedChildren);
  }

  String _getSelectionSummary() {
    if (selectedIds.isEmpty) {
      return TrKeys.noChildSelected.tr;
    }

    final count = selectedIds.length;
    if (count == 1) {
      return '1 ${TrKeys.childName.tr.toLowerCase()} ${TrKeys.selected.tr.toLowerCase()}';
    } else {
      return '$count ${TrKeys.children.tr.toLowerCase()} ${TrKeys.selected.tr.toLowerCase()}';
    }
  }
}
