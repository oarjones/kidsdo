import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/assigned_challenge.dart';
import 'package:kidsdo/domain/entities/challenge.dart';
import 'package:kidsdo/domain/entities/family_child.dart';
import 'package:kidsdo/presentation/controllers/child_access_controller.dart';
import 'package:kidsdo/presentation/controllers/child_challenges_controller.dart';
import 'package:kidsdo/presentation/widgets/challenges/celebration_animation.dart';
import 'package:kidsdo/presentation/widgets/challenges/child_challenge_card.dart';
import 'package:kidsdo/presentation/widgets/challenges/child_progress_indicator.dart';
import 'package:kidsdo/presentation/widgets/common/cached_avatar.dart';
import 'package:kidsdo/routes.dart';

class ChildChallengesPage extends StatefulWidget {
  const ChildChallengesPage({Key? key}) : super(key: key);

  @override
  State<ChildChallengesPage> createState() => _ChildChallengesPageState();
}

class _ChildChallengesPageState extends State<ChildChallengesPage>
    with SingleTickerProviderStateMixin {
  // Controladores
  late ChildChallengesController controller;
  late ChildAccessController accessController;

  // Animaciones
  late TabController _tabController;
  final List<String> _tabs = ['all', 'pending', 'completed', 'daily', 'weekly'];

  @override
  void initState() {
    super.initState();

    // Inicializar controladores
    controller = Get.find<ChildChallengesController>();
    accessController = Get.find<ChildAccessController>();

    // Configurar tabs
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        controller.changeFilter(_tabs[_tabController.index]);
      }
    });

    // Cargar retos si aún no se han cargado
    if (controller.assignedChallenges.isEmpty) {
      controller.loadChildChallenges();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Verificar que hay un perfil activo
      final FamilyChild? activeChild =
          accessController.activeChildProfile.value;
      if (activeChild == null) {
        // Si no hay perfil activo, redirigir a la selección de perfil
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offNamed(Routes.childProfileSelection);
        });
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Obtener color del tema del niño
      final Color themeColor = _getThemeColor(activeChild.settings);

      return Scaffold(
        appBar: _buildAppBar(activeChild, themeColor),
        // Usar SafeArea para evitar obstrucciones del sistema
        body: SafeArea(
          child: Stack(
            children: [
              // Contenido principal
              Column(
                children: [
                  // Barra de tabs
                  Container(
                    color: themeColor.withValues(alpha: 20),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: themeColor,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: themeColor,
                      tabs: [
                        Tab(text: TrKeys.all.tr),
                        Tab(text: TrKeys.pending.tr),
                        Tab(text: TrKeys.completed.tr),
                        Tab(text: TrKeys.dailyChallenge.tr),
                        Tab(text: TrKeys.weeklyChallenge.tr),
                      ],
                      isScrollable: true,
                    ),
                  ),

                  // Resumen y progreso
                  _buildProgressSection(activeChild, themeColor),

                  // Lista de retos
                  Expanded(
                    child: _buildChallengesList(activeChild),
                  ),
                ],
              ),

              // Indicador de carga
              if (controller.isLoading.value)
                Container(
                  color: Colors.black.withValues(alpha: 50),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),

              // Animación de celebración
              if (controller.showCelebration.value &&
                  controller.completedChallenge.value != null)
                CelebrationAnimation(
                  points: controller.pointsEarned.value,
                  message: TrKeys.challengeCompleted.tr,
                  onClose: () => controller.showCelebration.value = false,
                ),
            ],
          ),
        ),
        // Usar BottomNavigationBar para navegación coherente con la interfaz infantil
        bottomNavigationBar: _buildBottomNav(themeColor, activeChild.age),
      );
    });
  }

  PreferredSizeWidget _buildAppBar(FamilyChild child, Color themeColor) {
    return AppBar(
      backgroundColor: themeColor,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Avatar con Hero
          Hero(
            tag: 'child_avatar_${child.id}',
            child: child.avatarUrl != null
                ? CachedAvatar(
                    url: child.avatarUrl,
                    radius: 18,
                  )
                : CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    child: const Icon(
                      Icons.child_care,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
          ),
          const SizedBox(width: AppDimensions.sm),

          // Nombre
          Text(
            child.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        // Botón para volver al dashboard
        IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () => Get.offNamed(Routes.childDashboard),
          tooltip: TrKeys.menuHome.tr,
        ),
      ],
    );
  }

  Widget _buildProgressSection(FamilyChild child, Color themeColor) {
    final double progress = controller.getProgressPercentage();

    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      color: themeColor.withValues(alpha: 5),
      child: Column(
        children: [
          // Estadísticas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Total de retos
              _buildStatCard(
                icon: Icons.assignment,
                count: controller.assignedChallenges.length,
                label: TrKeys.totalChallenges.tr,
                color: themeColor,
              ),

              // Retos completados
              _buildStatCard(
                icon: Icons.check_circle,
                count: controller.getCompletedChallengesCount(),
                label: TrKeys.completed.tr,
                color: Colors.green,
              ),

              // Puntos ganados
              _buildStatCard(
                icon: Icons.star,
                count: controller.getTotalPointsEarned(),
                label: TrKeys.points.tr,
                color: Colors.amber,
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.lg),

          // Indicador de progreso
          ChildProgressIndicator(
            progress: progress,
            childAge: child.age,
            settings: child.settings,
            color: themeColor,
            label: TrKeys.yourProgress.tr,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.sm,
        horizontal: AppDimensions.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppDimensions.fontMd,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: AppDimensions.fontXs,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesList(FamilyChild child) {
    // Determina qué lista de retos mostrar según el filtro seleccionado
    RxList<AssignedChallenge> currentList;
    switch (_tabs[_tabController.index]) {
      case 'pending':
        currentList = controller.pendingChallenges;
        break;
      case 'completed':
        currentList = controller.completedChallenges;
        break;
      case 'daily':
        currentList = controller.dailyChallenges;
        break;
      case 'weekly':
        currentList = controller.weeklyChallenges;
        break;
      case 'all':
      default:
        currentList = controller.assignedChallenges;
        break;
    }

    return Obx(() {
      if (controller.status.value == ChildChallengeStatus.loading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: AppDimensions.md),
              Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: AppDimensions.md),
              ElevatedButton(
                onPressed: controller.loadChildChallenges,
                child: Text(TrKeys.retry.tr),
              ),
            ],
          ),
        );
      }

      if (currentList.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: controller.loadChildChallenges,
        child: ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.md),
          itemCount: currentList.length,
          itemBuilder: (context, index) {
            final assignedChallenge = currentList[index];

            // Buscar el reto correspondiente
            final challenge = controller.challenges
                .firstWhereOrNull((c) => c.id == assignedChallenge.challengeId);

            if (challenge == null) {
              return const SizedBox.shrink();
            }

            return ChildChallengeCard(
              assignedChallenge: assignedChallenge,
              challenge: challenge,
              childAge: child.age,
              settings: child.settings,
              isCompleted:
                  assignedChallenge.status == AssignedChallengeStatus.completed,
              isPending:
                  assignedChallenge.status == AssignedChallengeStatus.pending,
              onTap: () =>
                  _showChallengeDetails(assignedChallenge, challenge, child),
              onComplete: assignedChallenge.status ==
                      AssignedChallengeStatus.active
                  ? () =>
                      controller.markChallengeAsCompleted(assignedChallenge.id)
                  : null,
            );
          },
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    final FamilyChild? child = accessController.activeChildProfile.value;
    if (child == null) return const SizedBox.shrink();

    final Color themeColor = _getThemeColor(child.settings);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey.withValues(alpha: 150),
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            TrKeys.noChallengesFound.tr,
            style: TextStyle(
              fontSize: AppDimensions.fontLg,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xl),
            child: Text(
              _tabs[_tabController.index] == 'completed'
                  ? TrKeys.noCompletedChallengesYet.tr
                  : TrKeys.noChallengesMatchFilter.tr,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          if (_tabs[_tabController.index] != 'all')
            ElevatedButton.icon(
              onPressed: () {
                _tabController.animateTo(0); // Ir a la pestaña "Todos"
              },
              icon: const Icon(Icons.filter_list_off),
              label: Text(TrKeys.showAllChallenges.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  void _showChallengeDetails(AssignedChallenge assignedChallenge,
      Challenge challenge, FamilyChild child) {
    final Color themeColor = _getThemeColor(child.settings);

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

            // Icono y categoría
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono
                Container(
                  padding: const EdgeInsets.all(AppDimensions.lg),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 50),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusMd),
                  ),
                  child: Icon(
                    _getChallengeIcon(challenge.category),
                    color: themeColor,
                    size: 40,
                  ),
                ),

                const SizedBox(width: AppDimensions.md),

                // Título y categoría
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 50),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusSm),
                        ),
                        child: Text(
                          _getCategoryName(challenge.category),
                          style: TextStyle(
                            fontSize: 12,
                            color: themeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Estado (icono)
                _buildStatusIcon(assignedChallenge.status, size: 32),
              ],
            ),

            const SizedBox(height: AppDimensions.lg),

            // Descripción
            Text(
              challenge.description,
              style: const TextStyle(
                fontSize: AppDimensions.fontMd,
              ),
            ),

            const SizedBox(height: AppDimensions.lg),

            // Información adicional
            Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 20),
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusMd),
              ),
              child: Column(
                children: [
                  // Puntos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        TrKeys.points.tr,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            challenge.points.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Divider(),

                  // Frecuencia
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        TrKeys.frequency.tr,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        _getFrequencyName(challenge.frequency),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const Divider(),

                  // Fechas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        TrKeys.startDate.tr,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        _formatDate(assignedChallenge.startDate),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const Divider(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        TrKeys.endDate.tr,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        // _formatDate(assignedChallenge.endDate),
                        assignedChallenge.endDate != null
                            ? _formatDate(assignedChallenge.endDate!)
                            : '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.xl),

            // Botones de acción
            if (assignedChallenge.status == AssignedChallengeStatus.active)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    controller.markChallengeAsCompleted(assignedChallenge.id);
                  },
                  icon: const Icon(Icons.check_circle),
                  label: Text(TrKeys.markAsCompleted.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: AppDimensions.md),
                  ),
                ),
              )
            else if (assignedChallenge.status ==
                AssignedChallengeStatus.pending)
              Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 50),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.orange),
                    const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: Text(
                        TrKeys.waitingForParentApproval.tr,
                        style: const TextStyle(
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (assignedChallenge.status ==
                AssignedChallengeStatus.completed)
              Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 50),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: AppDimensions.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TrKeys.challengeCompleted.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        if (assignedChallenge.evaluations.isNotEmpty)
                          Text(
                            '${TrKeys.pointsEarned.tr}: ${assignedChallenge.evaluations.last.points}',
                            style: const TextStyle(
                              color: Colors.green,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(Color themeColor, int childAge) {
    // Determinar tamaños según la edad para mejorar la usabilidad
    double normalIconSize = childAge <= 5 ? 32.0 : 28.0;
    double activeIconSize = childAge <= 5 ? 36.0 : 30.0;
    double labelSize =
        childAge <= 5 ? AppDimensions.fontSm : AppDimensions.fontXs;

    return BottomNavigationBar(
      currentIndex: 1, // En retos (challenges)
      onTap: (index) {
        if (index == 0) {
          // Ir a inicio
          Get.offNamed(Routes.childDashboard);
        } else if (index == 1) {
          // Ya estamos en retos
        } else {
          // Para otras opciones, mostrar mensaje
          Get.snackbar(
            TrKeys.comingSoon.tr,
            TrKeys.comingSoonMessage.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      },
      selectedItemColor: themeColor,
      unselectedItemColor: AppColors.navigationUnselected,
      backgroundColor: Colors.white,
      elevation: 16,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(
        fontSize: labelSize,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: labelSize,
      ),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: normalIconSize),
          activeIcon: Icon(Icons.home, size: activeIconSize),
          label: TrKeys.menuHome.tr,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment, size: normalIconSize),
          activeIcon: Icon(Icons.assignment, size: activeIconSize),
          label: TrKeys.menuChallenges.tr,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.card_giftcard, size: normalIconSize),
          activeIcon: Icon(Icons.card_giftcard, size: activeIconSize),
          label: TrKeys.menuAwards.tr,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_events, size: normalIconSize),
          activeIcon: Icon(Icons.emoji_events, size: activeIconSize),
          label: TrKeys.menuAchievements.tr,
        ),
      ],
    );
  }

  Widget _buildStatusIcon(AssignedChallengeStatus status, {double size = 24}) {
    switch (status) {
      case AssignedChallengeStatus.completed:
        return Container(
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 50),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.check_circle,
            color: Colors.green,
            size: size,
          ),
        );
      case AssignedChallengeStatus.failed:
        return Container(
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 50),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.cancel,
            color: Colors.red,
            size: size,
          ),
        );
      case AssignedChallengeStatus.pending:
        return Container(
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 50),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.pending,
            color: Colors.orange,
            size: size,
          ),
        );
      case AssignedChallengeStatus.active:
        return Container(
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 50),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.pending,
            color: Colors.green,
            size: size,
          ),
        );
      case AssignedChallengeStatus.inactive:
        return Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 98, 102, 98).withValues(alpha: 50),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.pending,
            color: const Color.fromARGB(255, 98, 102, 98).withValues(alpha: 50),
            size: size,
          ),
        );
      // default:
      //   return Container(
      //     decoration: BoxDecoration(
      //       color: Colors.blue.withValues(alpha: 50),
      //       shape: BoxShape.circle,
      //     ),
      //     padding: const EdgeInsets.all(4),
      //     child: Icon(
      //       Icons.access_time,
      //       color: Colors.blue,
      //       size: size,
      //     ),
      //   );
    }
  }

  Color _getThemeColor(Map<String, dynamic> settings) {
    final String colorKey = settings['color'] as String? ?? 'blue';

    switch (colorKey) {
      case 'purple':
        return AppColors.childPurple;
      case 'green':
        return AppColors.childGreen;
      case 'orange':
        return AppColors.childOrange;
      case 'pink':
        return AppColors.childPink;
      case 'blue':
      default:
        return AppColors.childBlue;
    }
  }

  IconData _getChallengeIcon(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.hygiene:
        return Icons.wash;
      case ChallengeCategory.school:
        return Icons.school;
      case ChallengeCategory.order:
        return Icons.cleaning_services;
      case ChallengeCategory.responsibility:
        return Icons.volunteer_activism;
      case ChallengeCategory.help:
        return Icons.emoji_people;
      case ChallengeCategory.special:
        return Icons.emoji_events;
      case ChallengeCategory.sibling:
        return Icons.people;
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

  String _getFrequencyName(ChallengeFrequency frequency) {
    switch (frequency) {
      case ChallengeFrequency.daily:
        return TrKeys.frequencyDaily.tr;
      case ChallengeFrequency.weekly:
        return TrKeys.frequencyWeekly.tr;
      case ChallengeFrequency.monthly:
        return TrKeys.frequencyMonthly.tr;
      case ChallengeFrequency.quarterly:
        return TrKeys.frequencyQuarterly.tr;
      case ChallengeFrequency.once:
        return TrKeys.frequencyOnce.tr;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return TrKeys.today.tr;
    } else if (dateToCheck == today.add(const Duration(days: 1))) {
      return TrKeys.tomorrow.tr;
    } else if (dateToCheck == today.subtract(const Duration(days: 1))) {
      return TrKeys.yesterday.tr;
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
