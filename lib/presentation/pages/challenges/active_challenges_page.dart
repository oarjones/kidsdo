// lib/presentation/pages/challenges/active_challenges_page.dart
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
import 'package:kidsdo/presentation/widgets/challenges/challenge_evaluation_dialog.dart';
import 'package:kidsdo/presentation/widgets/challenges/challenge_execution_indicator.dart';
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
  bool?
      filterContinuous; // true: solo continuos, false: solo no continuos, null: todos

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
                  return _buildEmptyState();
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

          // Primera fila: Filtros de niño y estado
          Row(
            children: [
              // Filtro por niño
              Expanded(
                child: _buildChildFilter(),
              ),

              const SizedBox(width: AppDimensions.md),

              // Filtro por estado
              Expanded(
                child: _buildStatusFilter(),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.md),

          // Segunda fila: Filtro de tipo de reto
          Row(
            children: [
              // Filtro por tipo de reto (continuo/no continuo)
              Expanded(
                child: _buildContinuousFilter(),
              ),
            ],
          ),

          // Chips de filtros activos y botón de limpiar
          if (selectedChildId != null ||
              selectedStatus != null ||
              filterContinuous != null)
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
                  if (filterContinuous != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: Text(filterContinuous!
                            ? TrKeys.continuousChallenge.tr
                            : 'Fixed Challenge'),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() {
                            filterContinuous = null;
                          });
                        },
                        backgroundColor: filterContinuous!
                            ? Colors.indigo.withValues(alpha: 50)
                            : Colors.teal.withValues(alpha: 50),
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

  Widget _buildChildFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 150)),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
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
                );
              }).toList(),
            ],
            isExpanded: true,
            underline: const SizedBox.shrink(),
            icon: const Icon(Icons.filter_list),
          )),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 150)),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
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
                const Icon(Icons.hourglass_top, color: Colors.blue, size: 16),
                const SizedBox(width: 8),
                Text(TrKeys.active.tr),
              ],
            ),
          ),
          DropdownMenuItem<AssignedChallengeStatus?>(
            value: AssignedChallengeStatus.completed,
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Text(TrKeys.completed.tr),
              ],
            ),
          ),
          DropdownMenuItem<AssignedChallengeStatus?>(
            value: AssignedChallengeStatus.failed,
            child: Row(
              children: [
                const Icon(Icons.cancel, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Text(TrKeys.failed.tr),
              ],
            ),
          ),
          DropdownMenuItem<AssignedChallengeStatus?>(
            value: AssignedChallengeStatus.pending,
            child: Row(
              children: [
                const Icon(Icons.pending, color: Colors.orange, size: 16),
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
    );
  }

  Widget _buildContinuousFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 150)),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
      ),
      child: DropdownButton<bool?>(
        value: filterContinuous,
        hint: const Text('Challenge Type'),
        onChanged: (value) {
          setState(() {
            filterContinuous = value;
          });
        },
        items: [
          DropdownMenuItem<bool?>(
            value: null,
            child: Text(TrKeys.allCategories.tr),
          ),
          DropdownMenuItem<bool?>(
            value: true,
            child: Row(
              children: [
                const Icon(Icons.repeat, color: Colors.indigo, size: 16),
                const SizedBox(width: 8),
                Text(TrKeys.continuousChallenge.tr),
              ],
            ),
          ),
          const DropdownMenuItem<bool?>(
            value: false,
            child: Row(
              children: [
                Icon(Icons.done, color: Colors.teal, size: 16),
                SizedBox(width: 8),
                Text('Fixed Challenge'),
              ],
            ),
          ),
        ],
        isExpanded: true,
        underline: const SizedBox.shrink(),
        icon: const Icon(Icons.filter_list),
      ),
    );
  }

  Widget _buildEmptyState() {
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
              selectedChildId != null ||
                      selectedStatus != null ||
                      filterContinuous != null
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
              selectedChildId != null ||
                      selectedStatus != null ||
                      filterContinuous != null
                  ? TrKeys.noAssignedChallengesMessage.tr
                  : TrKeys.activeChallengesEmptyMessage.tr,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.lg),
            if (selectedChildId != null ||
                selectedStatus != null ||
                filterContinuous != null)
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

  // Limpiar todos los filtros
  void _clearFilters() {
    setState(() {
      selectedChildId = null;
      selectedStatus = null;
      filterContinuous = null;
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

    // Filtrar por tipo de reto (continuo/no continuo)
    if (filterContinuous != null) {
      filtered = filtered
          .where((challenge) => challenge.isContinuous == filterContinuous)
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
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
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
            _buildDetailHeader(assignedChallenge, challenge),

            const SizedBox(height: AppDimensions.lg),

            // Descripción
            Text(
              challenge.description,
              style: const TextStyle(fontSize: AppDimensions.fontMd),
            ),
            const SizedBox(height: AppDimensions.lg),

            // Información de asignación
            _buildAssignmentInfo(assignedChallenge, child),

            const SizedBox(height: AppDimensions.lg),

            // Indicador de ejecución si es reto continuo
            if (assignedChallenge.isContinuous)
              ..._buildExecutionSection(assignedChallenge),

            // Historial de evaluaciones
            _buildEvaluationHistory(assignedChallenge),

            const SizedBox(height: AppDimensions.xl),

            // Botones de acción
            _buildActionButtons(assignedChallenge, challenge, child),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailHeader(
      AssignedChallenge assignedChallenge, Challenge challenge) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.md),
          decoration: BoxDecoration(
            color:
                _getStatusColor(assignedChallenge.status).withValues(alpha: 50),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
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
                      borderRadius:
                          BorderRadius.circular(AppDimensions.borderRadiusSm),
                    ),
                    child: Text(
                      _getStatusName(assignedChallenge.status),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(assignedChallenge.status),
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
                  if (assignedChallenge.isContinuous) ...[
                    const SizedBox(width: AppDimensions.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withValues(alpha: 50),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.borderRadiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.repeat,
                            color: Colors.indigo,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            TrKeys.continuousChallenge.tr,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.indigo,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssignmentInfo(
      AssignedChallenge assignedChallenge, FamilyChild? child) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 20),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            TrKeys.assignedTo.tr,
            child != null
                ? Row(
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
                  )
                : const Text("Unknown"),
          ),
          const Divider(),
          _buildInfoRow(
            TrKeys.startDate.tr,
            Text(_formatDate(assignedChallenge.startDate)),
          ),
          if (!assignedChallenge.isContinuous &&
              assignedChallenge.endDate != null) ...[
            const Divider(),
            _buildInfoRow(
              TrKeys.dueDate.tr,
              Text(_formatDate(assignedChallenge.endDate!)),
            ),
          ],
          const Divider(),
          _buildInfoRow(
            TrKeys.points.tr,
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  "${assignedChallenge.pointsEarned}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildExecutionSection(AssignedChallenge assignedChallenge) {
    final currentExecution = assignedChallenge.currentExecution;

    return [
      // Indicador de ejecución actual
      ChallengeExecutionIndicator(assignedChallenge: assignedChallenge),

      const SizedBox(height: AppDimensions.md),

      // Historial de ejecuciones
      if (assignedChallenge.executions.length > 1) ...[
        ExpansionTile(
          title: Text(
              'Execution History (${assignedChallenge.executions.length})'),
          children: [
            for (int i = 0; i < assignedChallenge.executions.length; i++)
              _buildExecutionHistoryItem(
                assignedChallenge.executions[i],
                i,
                i == assignedChallenge.executions.length - 1,
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.md),
      ],
    ];
  }

  Widget _buildExecutionHistoryItem(
    dynamic execution,
    int index,
    bool isCurrent,
  ) {
    return ListTile(
      leading: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isCurrent
              ? AppColors.primary.withValues(alpha: 50)
              : execution.status == AssignedChallengeStatus.completed
                  ? Colors.green.withValues(alpha: 50)
                  : execution.status == AssignedChallengeStatus.failed
                      ? Colors.red.withValues(alpha: 50)
                      : Colors.grey.withValues(alpha: 50),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '${index + 1}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isCurrent
                  ? AppColors.primary
                  : execution.status == AssignedChallengeStatus.completed
                      ? Colors.green
                      : execution.status == AssignedChallengeStatus.failed
                          ? Colors.red
                          : Colors.grey,
            ),
          ),
        ),
      ),
      title: Text(
        isCurrent ? 'Current Execution' : 'Execution ${index + 1}',
        style: TextStyle(
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${DateFormat('MMM d').format(execution.startDate)} - ${DateFormat('MMM d').format(execution.endDate)}',
          ),
          Text(
            _getStatusName(execution.status),
            style: TextStyle(
              color: _getStatusColor(execution.status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      trailing: execution.evaluations.isNotEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(Icons.assessment, size: 16),
                Text(
                  '${execution.evaluations.length} evaluations',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            )
          : const SizedBox(),
    );
  }

  Widget _buildEvaluationHistory(AssignedChallenge assignedChallenge) {
    // Combinar evaluaciones de todas las ejecuciones
    List<dynamic> allEvaluations = [];

    for (int i = 0; i < assignedChallenge.executions.length; i++) {
      final execution = assignedChallenge.executions[i];

      allEvaluations.add({
        'evaluation': execution.evaluation,
        'executionIndex': i,
      });
    }

    // Ordenar por fecha (más reciente primero)
    allEvaluations
        .sort((a, b) => b['evaluation'].date.compareTo(a['evaluation'].date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TrKeys.lastEvaluation.tr,
          style: const TextStyle(
            fontSize: AppDimensions.fontMd,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        if (allEvaluations.isNotEmpty) ...[
          // Mostrar la evaluación más reciente
          _buildEvaluationItem(
            allEvaluations.first['evaluation'],
            allEvaluations.first['executionIndex'],
            true,
          ),

          // Mostrar las demás evaluaciones en un ExpansionTile si hay más de una
          if (allEvaluations.length > 1)
            ExpansionTile(
              title: Text('All Evaluations (${allEvaluations.length})'),
              children: allEvaluations
                  .skip(1)
                  .map((evalData) => _buildEvaluationItem(
                        evalData['evaluation'],
                        evalData['executionIndex'],
                        false,
                      ))
                  .toList(),
            ),
        ] else
          Container(
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 20),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
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
      ],
    );
  }

  Widget _buildEvaluationItem(
      dynamic evaluation, int? executionIndex, bool isLatest) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: _getStatusColor(evaluation.status).withValues(alpha: 20),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        border: Border.all(
          color: _getStatusColor(evaluation.status).withValues(alpha: 100),
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
                    _getStatusIcon(evaluation.status),
                    color: _getStatusColor(evaluation.status),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusName(evaluation.status),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(evaluation.status),
                    ),
                  ),
                  if (executionIndex != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 50),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.borderRadiusSm),
                      ),
                      child: Text(
                        'Execution ${executionIndex + 1}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                DateFormat('MMM d, yyyy').format(evaluation.date),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          if (evaluation.note != null && evaluation.note!.isNotEmpty) ...[
            const Divider(),
            Text(
              evaluation.note!,
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
                "${evaluation.points} ${TrKeys.points.tr}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AssignedChallenge assignedChallenge,
      Challenge challenge, FamilyChild? child) {
    return Row(
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
              _showEvaluationDialog(assignedChallenge, challenge, child);
            },
            icon: const Icon(Icons.rate_review),
            label: Text(TrKeys.evaluateChallenge.tr),
          ),
        ),
      ],
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
    ChallengeEvaluationDialog.show(
      context: context,
      assignedChallenge: assignedChallenge,
      challenge: challenge,
      child: child,
      challengeController: challengeController,
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
