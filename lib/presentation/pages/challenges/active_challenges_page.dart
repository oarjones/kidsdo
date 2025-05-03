import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/assigned_challenge.dart';
import 'package:kidsdo/domain/entities/challenge.dart';
import 'package:kidsdo/domain/entities/family_child.dart';
import 'package:kidsdo/presentation/controllers/challenge_controller.dart';
import 'package:kidsdo/presentation/controllers/child_profile_controller.dart';
import 'package:kidsdo/presentation/widgets/challenges/assigned_challenge_card.dart';
import 'package:kidsdo/presentation/widgets/common/cached_avatar.dart';

class ActiveChallengesPage extends StatefulWidget {
  const ActiveChallengesPage({Key? key}) : super(key: key);

  @override
  State<ActiveChallengesPage> createState() => _ActiveChallengesPageState();
}

class _ActiveChallengesPageState extends State<ActiveChallengesPage> {
  final ChallengeController challengeController =
      Get.find<ChallengeController>();
  final ChildProfileController childProfileController =
      Get.find<ChildProfileController>();

  // Filtros
  String? selectedChildId;
  AssignedChallengeStatus? selectedStatus;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Cargar perfiles infantiles si no están cargados
    if (childProfileController.childProfiles.isEmpty) {
      childProfileController.loadChildProfiles();
    }

    // Cargar retos familiares
    _loadAllAssignedChallenges();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TrKeys.activeChallenges.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllAssignedChallenges,
            tooltip: TrKeys.refresh.tr,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Sección de filtros
            _buildFilterSection(),

            // Lista de retos asignados
            Expanded(
              child: Obx(() {
                if (challengeController.isLoadingAssignedChallenges.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredChallenges = _getFilteredChallenges();

                if (filteredChallenges.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.lg),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: AppDimensions.md),
                          Text(
                            selectedChildId != null || selectedStatus != null
                                ? TrKeys.noAssignedChallenges.tr
                                : TrKeys.activeChallengesEmpty.tr,
                            style: const TextStyle(
                              fontSize: AppDimensions.fontLg,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimensions.sm),
                          Text(
                            selectedChildId != null || selectedStatus != null
                                ? TrKeys.noAssignedChallengesMessage.tr
                                : TrKeys.activeChallengesEmptyMessage.tr,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimensions.lg),
                          if (selectedChildId != null || selectedStatus != null)
                            ElevatedButton.icon(
                              onPressed: _clearFilters,
                              icon: const Icon(Icons.filter_list_off),
                              label: Text(TrKeys.clearAllFilters.tr),
                            )
                          else
                            ElevatedButton.icon(
                              onPressed: () {
                                // Navegar a la biblioteca de retos
                                Get.toNamed('/challenge-library');
                              },
                              icon: const Icon(Icons.add),
                              label: Text(TrKeys.createChallenge.tr),
                            ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  itemCount: filteredChallenges.length,
                  itemBuilder: (context, index) {
                    final assignedChallenge = filteredChallenges[index];

                    // Encontrar el reto correspondiente
                    final challenge =
                        _findChallengeById(assignedChallenge.challengeId);
                    if (challenge == null) {
                      return const SizedBox.shrink();
                    }

                    // Encontrar el niño correspondiente
                    final child = _findChildById(assignedChallenge.childId);

                    return AssignedChallengeCard(
                      assignedChallenge: assignedChallenge,
                      challenge: challenge,
                      child: child,
                      onTap: () => _showChallengeDetails(
                          assignedChallenge, challenge, child),
                      onEvaluate: () => _showEvaluationDialog(
                          assignedChallenge, challenge, child),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a la biblioteca de retos
          Get.toNamed('/challenge-library');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barra de búsqueda
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: TrKeys.searchChallenges.tr,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusMd),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),

          const SizedBox(height: AppDimensions.md),

          // Filtros de niño y estado
          Row(
            children: [
              // Filtro por niño
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppDimensions.sm),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: Colors.grey.withValues(alpha: 150)),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusMd),
                  ),
                  child: Obx(() => DropdownButton<String?>(
                        value: selectedChildId,
                        hint: Text(TrKeys.filterByChild.tr),
                        onChanged: (value) {
                          setState(() {
                            selectedChildId = value;
                          });
                        },
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(TrKeys.allCategories.tr),
                          ),
                          ...childProfileController.childProfiles.map((child) {
                            return DropdownMenuItem<String?>(
                              value: child.id,
                              child: Row(
                                children: [
                                  child.avatarUrl != null
                                      ? CachedAvatar(
                                          url: child.avatarUrl, radius: 12)
                                      : CircleAvatar(
                                          radius: 12,
                                          backgroundColor:
                                              Colors.grey.withValues(alpha: 50),
                                          child: const Icon(Icons.person,
                                              size: 16, color: Colors.grey),
                                        ),
                                  const SizedBox(width: 8),
                                  Text(child.name),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        icon: const Icon(Icons.filter_list),
                      )),
                ),
              ),

              const SizedBox(width: AppDimensions.md),

              // Filtro por estado
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppDimensions.sm),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: Colors.grey.withValues(alpha: 150)),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusMd),
                  ),
                  child: DropdownButton<AssignedChallengeStatus?>(
                    value: selectedStatus,
                    hint: Text(TrKeys.filterByStatus.tr),
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value;
                      });
                    },
                    items: [
                      DropdownMenuItem<AssignedChallengeStatus?>(
                        value: null,
                        child: Text(TrKeys.allCategories.tr),
                      ),
                      DropdownMenuItem<AssignedChallengeStatus?>(
                        value: AssignedChallengeStatus.active,
                        child: Row(
                          children: [
                            const Icon(Icons.hourglass_top,
                                color: Colors.blue, size: 16),
                            const SizedBox(width: 8),
                            Text(TrKeys.active.tr),
                          ],
                        ),
                      ),
                      DropdownMenuItem<AssignedChallengeStatus?>(
                        value: AssignedChallengeStatus.completed,
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 16),
                            const SizedBox(width: 8),
                            Text(TrKeys.completed.tr),
                          ],
                        ),
                      ),
                      DropdownMenuItem<AssignedChallengeStatus?>(
                        value: AssignedChallengeStatus.failed,
                        child: Row(
                          children: [
                            const Icon(Icons.cancel,
                                color: Colors.red, size: 16),
                            const SizedBox(width: 8),
                            Text(TrKeys.failed.tr),
                          ],
                        ),
                      ),
                      DropdownMenuItem<AssignedChallengeStatus?>(
                        value: AssignedChallengeStatus.pending,
                        child: Row(
                          children: [
                            const Icon(Icons.pending,
                                color: Colors.orange, size: 16),
                            const SizedBox(width: 8),
                            Text(TrKeys.pending.tr),
                          ],
                        ),
                      ),
                    ],
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    icon: const Icon(Icons.filter_list),
                  ),
                ),
              ),
            ],
          ),

          // Chips de filtros activos y botón de limpiar
          if (selectedChildId != null || selectedStatus != null)
            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.sm),
              child: Row(
                children: [
                  if (selectedChildId != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label:
                            Text(_findChildById(selectedChildId!)?.name ?? ''),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() {
                            selectedChildId = null;
                          });
                        },
                        backgroundColor: AppColors.primaryLight,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  if (selectedStatus != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: Text(_getStatusName(selectedStatus!)),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() {
                            selectedStatus = null;
                          });
                        },
                        backgroundColor: _getStatusColor(selectedStatus!)
                            .withValues(alpha: 50),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.filter_list_off, size: 18),
                    label: Text(TrKeys.clearAllFilters.tr),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Limpiar todos los filtros
  void _clearFilters() {
    setState(() {
      selectedChildId = null;
      selectedStatus = null;
      searchController.clear();
    });
  }

  // Cargar todos los retos asignados
  Future<void> _loadAllAssignedChallenges() async {
    // Primero cargar los retos de cada niño
    for (final child in childProfileController.childProfiles) {
      await challengeController.loadAssignedChallengesByChild(child.id);
    }
  }

  // Filtrar retos asignados según los filtros activos
  List<AssignedChallenge> _getFilteredChallenges() {
    List<AssignedChallenge> filtered =
        List.from(challengeController.assignedChallenges);

    // Filtrar por niño
    if (selectedChildId != null) {
      filtered = filtered
          .where((challenge) => challenge.childId == selectedChildId)
          .toList();
    }

    // Filtrar por estado
    if (selectedStatus != null) {
      filtered = filtered
          .where((challenge) => challenge.status == selectedStatus)
          .toList();
    }

    // Filtrar por búsqueda
    if (searchController.text.isNotEmpty) {
      final search = searchController.text.toLowerCase();
      filtered = filtered.where((assignedChallenge) {
        final challenge = _findChallengeById(assignedChallenge.challengeId);
        if (challenge == null) return false;

        return challenge.title.toLowerCase().contains(search) ||
            challenge.description.toLowerCase().contains(search);
      }).toList();
    }

    return filtered;
  }

  // Encontrar un reto por su ID
  Challenge? _findChallengeById(String challengeId) {
    // Buscar en retos de familia primero
    final familyChallenge = challengeController.familyChallenges
        .firstWhereOrNull((challenge) => challenge.id == challengeId);

    if (familyChallenge != null) {
      return familyChallenge;
    }

    // Luego buscar en retos predefinidos
    return challengeController.predefinedChallenges
        .firstWhereOrNull((challenge) => challenge.id == challengeId);
  }

  // Encontrar un niño por su ID
  FamilyChild? _findChildById(String childId) {
    return childProfileController.childProfiles
        .firstWhereOrNull((child) => child.id == childId);
  }

  // Mostrar detalles de un reto asignado
  void _showChallengeDetails(AssignedChallenge assignedChallenge,
      Challenge challenge, FamilyChild? child) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.borderRadiusLg)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppDimensions.lg),
          children: [
            // Barra de arrastre
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusSm),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            // Encabezado con título e icono
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  decoration: BoxDecoration(
                    color: _getStatusColor(assignedChallenge.status)
                        .withValues(alpha: 50),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusMd),
                  ),
                  child: Icon(
                    _getCategoryIcon(challenge.category),
                    color: _getStatusColor(assignedChallenge.status),
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: const TextStyle(
                          fontSize: AppDimensions.fontLg,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xs),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.xs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(assignedChallenge.status)
                                  .withValues(alpha: 50),
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.borderRadiusSm),
                            ),
                            child: Text(
                              _getStatusName(assignedChallenge.status),
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    _getStatusColor(assignedChallenge.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.sm),
                          Text(
                            _getCategoryName(challenge.category),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.lg),

            // Descripción
            Text(
              challenge.description,
              style: const TextStyle(fontSize: AppDimensions.fontMd),
            ),
            const SizedBox(height: AppDimensions.lg),

            // Información de asignación
            Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 20),
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusMd),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    TrKeys.assignedTo.tr,
                    child != null
                        ? Row(
                            children: [
                              child.avatarUrl != null
                                  ? CachedAvatar(
                                      url: child.avatarUrl, radius: 12)
                                  : CircleAvatar(
                                      radius: 12,
                                      backgroundColor:
                                          Colors.grey.withValues(alpha: 50),
                                      child: const Icon(Icons.person,
                                          size: 16, color: Colors.grey),
                                    ),
                              const SizedBox(width: 8),
                              Text(child.name),
                            ],
                          )
                        : const Text("Unknown"),
                  ),
                  const Divider(),
                  _buildInfoRow(
                    TrKeys.startDate.tr,
                    Text(_formatDate(assignedChallenge.startDate)),
                  ),
                  const Divider(),
                  _buildInfoRow(
                    TrKeys.dueDate.tr,
                    Text(assignedChallenge.endDate != null
                        ? _formatDate(assignedChallenge.endDate!)
                        : ''),
                  ),
                  const Divider(),
                  _buildInfoRow(
                    TrKeys.points.tr,
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "${assignedChallenge.pointsEarned}/${challenge.points}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            // Historial de evaluaciones
            Text(
              TrKeys.lastEvaluation.tr,
              style: const TextStyle(
                fontSize: AppDimensions.fontMd,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),

            if (assignedChallenge.evaluations.isNotEmpty) ...[
              // Mostrar la última evaluación
              Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color:
                      _getStatusColor(assignedChallenge.evaluations.last.status)
                          .withValues(alpha: 20),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusMd),
                  border: Border.all(
                    color: _getStatusColor(
                            assignedChallenge.evaluations.last.status)
                        .withValues(alpha: 100),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getStatusIcon(
                                  assignedChallenge.evaluations.last.status),
                              color: _getStatusColor(
                                  assignedChallenge.evaluations.last.status),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getStatusName(
                                  assignedChallenge.evaluations.last.status),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(
                                    assignedChallenge.evaluations.last.status),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          DateFormat('MMM d, yyyy')
                              .format(assignedChallenge.evaluations.last.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    if (assignedChallenge.evaluations.last.note != null &&
                        assignedChallenge
                            .evaluations.last.note!.isNotEmpty) ...[
                      const Divider(),
                      Text(
                        assignedChallenge.evaluations.last.note!,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const Divider(),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "${assignedChallenge.evaluations.last.points} ${TrKeys.points.tr}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else
              Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 20),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusMd),
                ),
                child: Center(
                  child: Text(
                    TrKeys.noEvaluationsYet.tr,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: AppDimensions.xl),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showDeleteConfirmationDialog(assignedChallenge);
                    },
                    icon: const Icon(Icons.delete),
                    label: Text(TrKeys.delete.tr),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showEvaluationDialog(
                          assignedChallenge, challenge, child);
                    },
                    icon: const Icon(Icons.rate_review),
                    label: Text(TrKeys.evaluateChallenge.tr),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Construcción de fila de información
  Widget _buildInfoRow(String label, Widget value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
        value,
      ],
    );
  }

  // Diálogo de evaluación de reto
  void _showEvaluationDialog(AssignedChallenge assignedChallenge,
      Challenge challenge, FamilyChild? child) {
    AssignedChallengeStatus selectedEvaluationStatus =
        AssignedChallengeStatus.completed;
    final TextEditingController noteController = TextEditingController();
    int assignedPoints =
        challenge.points; // Valor predeterminado: puntos originales del reto

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(TrKeys.evaluateChallengeTitle.tr),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre del reto
                Text(
                  challenge.title,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontLg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (child != null) ...[
                  const SizedBox(height: AppDimensions.xs),
                  Row(
                    children: [
                      child.avatarUrl != null
                          ? CachedAvatar(url: child.avatarUrl, radius: 12)
                          : CircleAvatar(
                              radius: 12,
                              backgroundColor:
                                  Colors.grey.withValues(alpha: 50),
                              child: const Icon(Icons.person,
                                  size: 16, color: Colors.grey),
                            ),
                      const SizedBox(width: 8),
                      Text(child.name),
                    ],
                  ),
                ],
                const SizedBox(height: AppDimensions.md),

                // Opciones de evaluación
                Text(
                  TrKeys.status.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),

                Wrap(
                  spacing: AppDimensions.sm,
                  children: [
                    // Opción Completado
                    ChoiceChip(
                      label: Text(TrKeys.completed.tr),
                      selected: selectedEvaluationStatus ==
                          AssignedChallengeStatus.completed,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            selectedEvaluationStatus =
                                AssignedChallengeStatus.completed;
                            assignedPoints =
                                challenge.points; // Restaurar puntos originales
                          });
                        }
                      },
                      backgroundColor: Colors.grey.withValues(alpha: 50),
                      selectedColor: Colors.green.withValues(alpha: 100),
                      avatar: const Icon(Icons.check_circle,
                          color: Colors.green, size: 18),
                    ),

                    // Opción Fallido
                    ChoiceChip(
                      label: Text(TrKeys.failed.tr),
                      selected: selectedEvaluationStatus ==
                          AssignedChallengeStatus.failed,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            selectedEvaluationStatus =
                                AssignedChallengeStatus.failed;
                            assignedPoints = 0; // Cero puntos si falla
                          });
                        }
                      },
                      backgroundColor: Colors.grey.withValues(alpha: 50),
                      selectedColor: Colors.red.withValues(alpha: 100),
                      avatar:
                          const Icon(Icons.cancel, color: Colors.red, size: 18),
                    ),

                    // Opción Pendiente
                    ChoiceChip(
                      label: Text(TrKeys.pending.tr),
                      selected: selectedEvaluationStatus ==
                          AssignedChallengeStatus.pending,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            selectedEvaluationStatus =
                                AssignedChallengeStatus.pending;
                            assignedPoints = 0; // Cero puntos si está pendiente
                          });
                        }
                      },
                      backgroundColor: Colors.grey.withValues(alpha: 50),
                      selectedColor: Colors.orange.withValues(alpha: 100),
                      avatar: const Icon(Icons.pending,
                          color: Colors.orange, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.md),

                // Selector de puntos
                if (selectedEvaluationStatus ==
                    AssignedChallengeStatus.completed) ...[
                  Text(
                    TrKeys.points.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      Expanded(
                        child: Slider(
                          value: assignedPoints.toDouble(),
                          min: 0,
                          max: challenge.points *
                              1.5, // Permitir hasta un 50% más de puntos
                          divisions: challenge.points *
                              3, // Divisiones para mayor precisión
                          label: assignedPoints.toString(),
                          onChanged: (value) {
                            setState(() {
                              assignedPoints = value.round();
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                      ),
                      Container(
                        width: 40,
                        alignment: Alignment.center,
                        child: Text(
                          assignedPoints.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  Text(
                    'Original: ${challenge.points} ${TrKeys.points.tr}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: AppDimensions.md),

                // Campo para nota
                Text(
                  TrKeys.addNote.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    hintText: TrKeys.evaluationNote.tr,
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey.withValues(alpha: 20),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(TrKeys.cancel.tr),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Evaluar el reto
                challengeController.evaluateAssignedChallenge(
                  assignedChallengeId: assignedChallenge.id,
                  newStatus: selectedEvaluationStatus,
                  points: assignedPoints,
                  note: noteController.text.isNotEmpty
                      ? noteController.text
                      : null,
                );
              },
              child: Text(TrKeys.evaluateChallenge.tr),
            ),
          ],
        ),
      ),
    );
  }

  // Diálogo de confirmación de eliminación
  void _showDeleteConfirmationDialog(AssignedChallenge assignedChallenge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(TrKeys.deleteAssignedChallengeTitle.tr),
        content: Text(TrKeys.deleteAssignedChallengeMessage.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(TrKeys.cancel.tr),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              challengeController.deleteAssignedChallenge(assignedChallenge.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(TrKeys.delete.tr),
          ),
        ],
      ),
    );
  }

  // Funciones auxiliares para nombres, colores e íconos
  String _getStatusName(AssignedChallengeStatus status) {
    switch (status) {
      case AssignedChallengeStatus.active:
        return TrKeys.active.tr;
      case AssignedChallengeStatus.completed:
        return TrKeys.completed.tr;
      case AssignedChallengeStatus.failed:
        return TrKeys.failed.tr;
      case AssignedChallengeStatus.pending:
        return TrKeys.pending.tr;
      case AssignedChallengeStatus.inactive:
        return TrKeys.inactive.tr;
    }
  }

  Color _getStatusColor(AssignedChallengeStatus status) {
    switch (status) {
      case AssignedChallengeStatus.active:
        return Colors.blue;
      case AssignedChallengeStatus.completed:
        return Colors.green;
      case AssignedChallengeStatus.failed:
        return Colors.red;
      case AssignedChallengeStatus.pending:
        return Colors.orange;
      case AssignedChallengeStatus.inactive:
        return const Color.fromARGB(255, 121, 119, 117);
    }
  }

  IconData _getStatusIcon(AssignedChallengeStatus status) {
    switch (status) {
      case AssignedChallengeStatus.active:
        return Icons.hourglass_top;
      case AssignedChallengeStatus.completed:
        return Icons.check_circle;
      case AssignedChallengeStatus.failed:
        return Icons.cancel;
      case AssignedChallengeStatus.pending:
        return Icons.pending;
      case AssignedChallengeStatus.inactive:
        return Icons.cancel_outlined;
    }
  }

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

  // Formatear fecha para mostrar
  String _formatDate(DateTime? date) {
    date = date ?? DateTime.now();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return '${TrKeys.today.tr} (${DateFormat('MMM d').format(date)})';
    } else if (dateOnly == yesterday) {
      return '${TrKeys.yesterday.tr} (${DateFormat('MMM d').format(date)})';
    } else if (dateOnly == tomorrow) {
      return '${TrKeys.tomorrow.tr} (${DateFormat('MMM d').format(date)})';
    } else if (dateOnly.isAfter(today)) {
      final difference = dateOnly.difference(today).inDays;
      return '$difference ${difference == 1 ? TrKeys.days.tr : TrKeys.daysLeft.tr}';
    } else {
      final difference = today.difference(dateOnly).inDays;
      return '$difference ${difference == 1 ? TrKeys.days.tr : TrKeys.daysAgo.tr}';
    }
  }
}
