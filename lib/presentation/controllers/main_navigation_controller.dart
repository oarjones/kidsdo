// lib/presentation/controllers/main_navigation_controller.dart
import 'package:get/get.dart';
import 'package:kidsdo/presentation/pages/challenges/challenges_page.dart';
import 'package:kidsdo/presentation/pages/home/home_page.dart';
import 'package:kidsdo/presentation/pages/profile/profile_page.dart';
import 'package:kidsdo/presentation/pages/rewards/rewards_management_page.dart';
import 'package:flutter/material.dart'; // Necesario para Widget

class MainNavigationController extends GetxController {
  // Índice de la pestaña actualmente seleccionada
  var selectedIndex = 0.obs;

  // Lista de las páginas principales que se mostrarán
  // Es importante que estas páginas NO tengan su propia BottomNavigationBar
  // y, preferiblemente, que su Scaffold sea mínimo o que sean solo el contenido del body.
  final List<Widget> pages = [
    const HomePage(),
    const ChallengesPage(),
    const RewardsManagementPage(), // La que creamos para la gestión de recompensas
    const ProfilePage(),
  ];

  // Getter para la página actual basada en el índice seleccionado
  Widget get currentPage => pages[selectedIndex.value];

  // Método para cambiar de página/pestaña
  void changePage(int index) {
    if (index >= 0 && index < pages.length) {
      selectedIndex.value = index;
    }
    // Podrías añadir lógica aquí si necesitas hacer algo más al cambiar de pestaña
    // por ejemplo, recargar datos específicos de la pestaña si no usan streams.
  }

  // Método para navegar a una pestaña específica por nombre o tipo (opcional)
  void goToHomePage() => changePage(0);
  void goToChallengesPage() => changePage(1);
  void goToRewardsPage() => changePage(2);
  void goToProfilePage() => changePage(3);
}
