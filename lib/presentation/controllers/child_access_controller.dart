import 'package:get/get.dart';
import 'package:kidsdo/domain/entities/family_child.dart';
import 'package:kidsdo/domain/repositories/family_child_repository.dart';
import 'package:kidsdo/presentation/controllers/family_controller.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ChildAccessStatus {
  initial,
  loading,
  success,
  error,
}

/// Controlador para gestionar el acceso de los niños a sus perfiles
class ChildAccessController extends GetxController {
  final IFamilyChildRepository _familyChildRepository;
  final FamilyController _familyController;
  final SharedPreferences _sharedPreferences;
  final Logger _logger;

  // Estado observable
  final Rx<ChildAccessStatus> status =
      Rx<ChildAccessStatus>(ChildAccessStatus.initial);
  final RxString errorMessage = RxString('');

  // Lista de perfiles infantiles disponibles
  final RxList<FamilyChild> availableChildren = RxList<FamilyChild>([]);

  // Perfil infantil actualmente seleccionado
  final Rx<FamilyChild?> activeChildProfile = Rx<FamilyChild?>(null);

  // Clave para almacenar el ID del último perfil seleccionado
  static const String _lastActiveChildKey = 'last_active_child_id';

  // Determina si estamos en modo infantil
  final RxBool isChildMode = RxBool(false);

  // PIN de acceso para control parental
  final RxString parentalPin = RxString('');
  static const String _parentalPinKey = 'parental_control_pin';

  ChildAccessController({
    required IFamilyChildRepository familyChildRepository,
    required FamilyController familyController,
    required SharedPreferences sharedPreferences,
    required Logger logger,
  })  : _familyChildRepository = familyChildRepository,
        _familyController = familyController,
        _sharedPreferences = sharedPreferences,
        _logger = logger;

  @override
  void onInit() {
    super.onInit();

    // Cargar PIN de control parental
    parentalPin.value = _sharedPreferences.getString(_parentalPinKey) ?? '0000';

    // Escuchar cambios en la familia seleccionada
    ever(_familyController.currentFamily, (_) {
      if (_familyController.currentFamily.value != null) {
        loadAvailableChildProfiles();
      } else {
        availableChildren.clear();
        activeChildProfile.value = null;
        isChildMode.value = false;
      }
    });

    // Intentar cargar el último perfil activo
    loadLastActiveProfile();

    _logger.i("ChildAccessController initialized");
  }

  /// Carga todos los perfiles infantiles disponibles para la familia actual
  Future<void> loadAvailableChildProfiles() async {
    final currentFamily = _familyController.currentFamily.value;
    if (currentFamily == null) {
      _logger.w(
          "No hay familia seleccionada, no se pueden cargar perfiles infantiles");
      return;
    }

    status.value = ChildAccessStatus.loading;
    availableChildren.clear();
    errorMessage.value = '';

    _logger
        .i("Cargando perfiles infantiles para la familia: ${currentFamily.id}");
    final result =
        await _familyChildRepository.getChildrenByFamilyId(currentFamily.id);

    result.fold(
      (failure) {
        status.value = ChildAccessStatus.error;
        errorMessage.value = failure.message;
        _logger.e("Error cargando perfiles infantiles: ${failure.message}");
      },
      (children) {
        availableChildren.addAll(children);
        status.value = ChildAccessStatus.success;
        _logger.i(
            "Se cargaron ${children.length} perfiles infantiles disponibles");

        // Si hay un perfil activo, verificar que sigue estando disponible
        if (activeChildProfile.value != null) {
          final stillAvailable = availableChildren
              .any((child) => child.id == activeChildProfile.value!.id);

          if (!stillAvailable) {
            activeChildProfile.value = null;
            isChildMode.value = false;
            _sharedPreferences.remove(_lastActiveChildKey);
            _logger.w("El perfil activo ya no está disponible");
          }
        }
      },
    );
  }

  /// Activa un perfil infantil y entra en modo infantil
  Future<void> activateChildProfile(FamilyChild child) async {
    activeChildProfile.value = child;
    isChildMode.value = true;

    // Guardar el ID del perfil activo para futuros accesos
    await _sharedPreferences.setString(_lastActiveChildKey, child.id);

    _logger.i("Perfil infantil activado: ${child.name} (${child.id})");
  }

  /// Carga el último perfil activo si existe
  Future<void> loadLastActiveProfile() async {
    if (availableChildren.isEmpty) {
      await loadAvailableChildProfiles();
    }

    final lastActiveChildId = _sharedPreferences.getString(_lastActiveChildKey);
    if (lastActiveChildId != null && availableChildren.isNotEmpty) {
      final childProfile = availableChildren
          .firstWhereOrNull((child) => child.id == lastActiveChildId);

      if (childProfile != null) {
        activeChildProfile.value = childProfile;
        _logger.i("Último perfil activo cargado: ${childProfile.name}");
      }
    }
  }

  /// Sale del modo infantil y vuelve al modo padre
  void exitChildMode() {
    isChildMode.value = false;
    _logger.i("Salido del modo infantil");
  }

  /// Verifica si el PIN introducido es correcto
  bool verifyParentalPin(String pin) {
    return pin == parentalPin.value;
  }

  /// Establece un nuevo PIN de control parental
  Future<void> setParentalPin(String newPin) async {
    parentalPin.value = newPin;
    await _sharedPreferences.setString(_parentalPinKey, newPin);
    _logger.i("Nuevo PIN de control parental establecido");
  }
}
