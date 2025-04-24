import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/errors/failures.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/base_user.dart';
import 'package:kidsdo/domain/entities/family.dart';
import 'package:kidsdo/domain/repositories/family_repository.dart';
import 'package:kidsdo/domain/repositories/user_repository.dart';
import 'package:kidsdo/presentation/controllers/session_controller.dart';
import 'package:logger/logger.dart';

enum FamilyStatus {
  initial,
  loading,
  success,
  error,
}

class FamilyController extends GetxController {
  final IFamilyRepository _familyRepository;
  final SessionController _sessionController;
  final IUserRepository _userRepository;
  final Logger _logger;

  // Observable state
  final Rx<FamilyStatus> status = Rx<FamilyStatus>(FamilyStatus.initial);
  final RxString errorMessage = RxString('');
  final Rx<Family?> currentFamily = Rx<Family?>(null);
  final RxBool isJoiningFamily = RxBool(false);
  final RxBool isCreatingFamily = RxBool(false);
  final RxBool isGeneratingCode = RxBool(false);
  final RxString inviteCode = RxString('');

  // Text field controllers
  late TextEditingController familyNameController;
  late TextEditingController inviteCodeController;

  // Focus nodes
  late FocusNode familyNameFocusNode;
  late FocusNode inviteCodeFocusNode;

  // Propiedades para miembros de familia
  final RxList<BaseUser> familyMembers = RxList<BaseUser>([]);
  final RxBool isLoadingMembers = RxBool(false);
  final RxString membersErrorMessage = RxString('');

  FamilyController({
    required IFamilyRepository familyRepository,
    required IUserRepository userRepository,
    required SessionController sessionController,
    Logger? logger,
  })  : _familyRepository = familyRepository,
        _userRepository = userRepository,
        _sessionController = sessionController,
        _logger = logger ?? Get.find<Logger>();

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();

    // Listen for changes in the session user
    ever(_sessionController.currentUser, (user) {
      if (user != null) {
        loadCurrentFamily();
      } else {
        // Clear the current family when user logs out
        currentFamily.value = null;
      }
    });

    // Initial load if user is already logged in
    if (_sessionController.isUserLoggedIn) {
      loadCurrentFamily();
    }

    _logger.i("FamilyController initialized");
  }

  void _initializeControllers() {
    familyNameController = TextEditingController();
    inviteCodeController = TextEditingController();

    familyNameFocusNode = FocusNode();
    inviteCodeFocusNode = FocusNode();

    familyNameController.addListener(_clearErrorOnChange);
    inviteCodeController.addListener(_clearErrorOnChange);

    _logger.d("Text controllers initialized");
  }

  @override
  void onClose() {
    _disposeControllers();
    _logger.i("FamilyController closed");
    super.onClose();
  }

  void _disposeControllers() {
    familyNameController.removeListener(_clearErrorOnChange);
    inviteCodeController.removeListener(_clearErrorOnChange);

    familyNameController.dispose();
    inviteCodeController.dispose();

    familyNameFocusNode.dispose();
    inviteCodeFocusNode.dispose();

    _logger.d("Text controllers disposed");
  }

  void _clearErrorOnChange() {
    if (errorMessage.isNotEmpty) {
      errorMessage.value = '';
    }
  }

  /// Validates family name
  String? validateFamilyName(String? value) {
    if (value == null || value.isEmpty) {
      return TrKeys.requiredField.tr;
    }
    if (value.length < 3) {
      return 'family_name_too_short'.tr;
    }
    return null;
  }

  /// Validates invite code
  String? validateInviteCode(String? value) {
    if (value == null || value.isEmpty) {
      return TrKeys.requiredField.tr;
    }
    if (value.length != 6) {
      return 'invalid_invite_code'.tr;
    }
    return null;
  }

  /// Loads the current family for the logged-in user
  Future<void> loadCurrentFamily() async {
    final currentUser = _sessionController.currentUser.value;
    if (currentUser == null) {
      _logger.i("No user logged in, can't load family");
      currentFamily.value = null;
      return;
    }

    if (currentUser.familyId == null) {
      _logger.i("User doesn't belong to any family");
      currentFamily.value = null;
      return;
    }

    status.value = FamilyStatus.loading;
    errorMessage.value = '';

    _logger.i("Loading family: ${currentUser.familyId}");
    final result = await _familyRepository.getFamilyById(currentUser.familyId!);

    result.fold(
      (failure) {
        status.value = FamilyStatus.error;
        errorMessage.value = _mapFailureToMessage(failure);
        currentFamily.value = null;
        _logger.e("Error loading family: ${failure.message}");
      },
      (family) {
        status.value = FamilyStatus.success;
        currentFamily.value = family;
        _logger.i("Family loaded successfully: ${family.name}");

        // Cargar los miembros de la familia
        loadFamilyMembers();
      },
    );
  }

  /// Creates a new family
  Future<void> createFamily() async {
    final currentUser = _sessionController.currentUser.value;
    if (currentUser == null) {
      _logger.e("No user logged in, can't create family");
      errorMessage.value = 'not_logged_in'.tr;
      return;
    }

    if (currentUser.familyId != null) {
      _logger.w("User already belongs to a family");
      errorMessage.value = 'already_in_family'.tr;
      return;
    }

    final familyName = familyNameController.text.trim();
    if (familyName.isEmpty) {
      errorMessage.value = TrKeys.requiredField.tr;
      return;
    }

    isCreatingFamily.value = true;
    status.value = FamilyStatus.loading;
    errorMessage.value = '';

    _logger.i("Creating family: $familyName");
    final result = await _familyRepository.createFamily(
      name: familyName,
      createdBy: currentUser.uid,
    );

    result.fold(
      (failure) {
        status.value = FamilyStatus.error;
        errorMessage.value = _mapFailureToMessage(failure);
        isCreatingFamily.value = false;
        _logger.e("Error creating family: ${failure.message}");
      },
      (family) async {
        // Update the user's familyId in session
        final updatedUser = currentUser.copyWith(familyId: family.id);

        // Persistir el cambio en Firebase
        _logger.i("Updating user familyId in Firestore: ${family.id}");
        final saveResult = await _userRepository.saveParent(updatedUser);

        saveResult.fold(
          (failure) {
            status.value = FamilyStatus.error;
            errorMessage.value = _mapFailureToMessage(failure);
            isCreatingFamily.value = false;
            _logger.e("Error updating user in Firestore: ${failure.message}");
          },
          (_) {
            // Actualizar la sesión después de guardar en Firestore
            _sessionController.setCurrentUser(updatedUser);

            currentFamily.value = family;
            status.value = FamilyStatus.success;
            isCreatingFamily.value = false;
            familyNameController.clear();

            _logger.i("Family created successfully: ${family.name}");

            // Show success message
            Get.snackbar(
              'family_created_title'.tr,
              'family_created_message'.tr,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.withValues(alpha: 0.1),
              colorText: Colors.green,
            );
          },
        );
      },
    );
  }

  /// Joins an existing family using an invite code
  Future<void> joinFamily() async {
    final currentUser = _sessionController.currentUser.value;
    if (currentUser == null) {
      _logger.e("No user logged in, can't join family");
      errorMessage.value = 'not_logged_in'.tr;
      return;
    }

    if (currentUser.familyId != null) {
      _logger.w("User already belongs to a family");
      errorMessage.value = 'already_in_family'.tr;
      return;
    }

    final code = inviteCodeController.text.trim();
    if (code.isEmpty) {
      errorMessage.value = TrKeys.requiredField.tr;
      return;
    }

    isJoiningFamily.value = true;
    status.value = FamilyStatus.loading;
    errorMessage.value = '';

    _logger.i("Joining family with code: $code");
    final result = await _familyRepository.getFamilyByInviteCode(code);

    result.fold(
      (failure) {
        status.value = FamilyStatus.error;
        errorMessage.value = _mapFailureToMessage(failure);
        isJoiningFamily.value = false;
        _logger.e("Error joining family: ${failure.message}");
      },
      (family) async {
        // Add the user to the family
        final addMemberResult = await _familyRepository.addMemberToFamily(
          familyId: family.id,
          userId: currentUser.uid,
        );

        addMemberResult.fold(
          (failure) {
            status.value = FamilyStatus.error;
            errorMessage.value = _mapFailureToMessage(failure);
            isJoiningFamily.value = false;
            _logger.e("Error adding member to family: ${failure.message}");
          },
          (_) async {
            // Update the user's familyId in session
            final updatedUser = currentUser.copyWith(familyId: family.id);

            // Persistir el cambio en Firebase
            _logger.i("Updating user familyId in Firestore: ${family.id}");
            final saveResult = await _userRepository.saveParent(updatedUser);

            saveResult.fold(
              (failure) {
                status.value = FamilyStatus.error;
                errorMessage.value = _mapFailureToMessage(failure);
                isJoiningFamily.value = false;
                _logger
                    .e("Error updating user in Firestore: ${failure.message}");
              },
              (_) {
                // Actualizar la sesión después de guardar en Firestore
                _sessionController.setCurrentUser(updatedUser);

                currentFamily.value = family;
                status.value = FamilyStatus.success;
                isJoiningFamily.value = false;
                inviteCodeController.clear();

                _logger.i("Successfully joined family: ${family.name}");

                // Show success message
                Get.snackbar(
                  'family_joined_title'.tr,
                  'family_joined_message'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                  colorText: Colors.green,
                );
              },
            );
          },
        );
      },
    );
  }

  /// Generates a new invite code for the current family
  Future<void> generateNewInviteCode() async {
    if (currentFamily.value == null) {
      _logger.e("No current family, can't generate code");
      errorMessage.value = 'no_family'.tr;
      return;
    }

    isGeneratingCode.value = true;
    status.value = FamilyStatus.loading;
    errorMessage.value = '';

    _logger
        .i("Generating new invite code for family: ${currentFamily.value!.id}");
    final result = await _familyRepository
        .generateFamilyInviteCode(currentFamily.value!.id);

    result.fold(
      (failure) {
        status.value = FamilyStatus.error;
        errorMessage.value = _mapFailureToMessage(failure);
        isGeneratingCode.value = false;
        _logger.e("Error generating invite code: ${failure.message}");
      },
      (code) {
        inviteCode.value = code;
        // Update the current family with the new code
        currentFamily.value = currentFamily.value!.copyWith(inviteCode: code);
        status.value = FamilyStatus.success;
        isGeneratingCode.value = false;

        _logger.i("Invite code generated successfully: $code");
      },
    );
  }

  /// Leaves the current family
  Future<void> leaveFamily() async {
    final currentUser = _sessionController.currentUser.value;
    if (currentUser == null || currentFamily.value == null) {
      _logger.e("No user logged in or no current family");
      return;
    }

    // Check if the user is the creator of the family
    if (currentFamily.value!.createdBy == currentUser.uid) {
      _logger.w("User is the creator of the family, can't leave");
      errorMessage.value = 'creator_cant_leave'.tr;
      return;
    }

    status.value = FamilyStatus.loading;
    errorMessage.value = '';

    _logger.i("Leaving family: ${currentFamily.value!.id}");
    final result = await _familyRepository.removeMemberFromFamily(
      familyId: currentFamily.value!.id,
      userId: currentUser.uid,
    );

    result.fold(
      (failure) {
        status.value = FamilyStatus.error;
        errorMessage.value = _mapFailureToMessage(failure);
        _logger.e("Error leaving family: ${failure.message}");
      },
      (_) async {
        // Update the user's familyId in session
        final updatedUser = currentUser.copyWith(familyId: null);

        // Persistir el cambio en Firebase
        _logger.i("Removing familyId from user in Firestore");
        final saveResult = await _userRepository.saveParent(updatedUser);

        saveResult.fold(
          (failure) {
            status.value = FamilyStatus.error;
            errorMessage.value = _mapFailureToMessage(failure);
            _logger.e("Error updating user in Firestore: ${failure.message}");
          },
          (_) {
            // Actualizar la sesión después de guardar en Firestore
            _sessionController.setCurrentUser(updatedUser);

            currentFamily.value = null;
            status.value = FamilyStatus.success;

            _logger.i("Successfully left family");

            // Show success message
            Get.snackbar(
              'family_left_title'.tr,
              'family_left_message'.tr,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.withValues(alpha: 0.1),
              colorText: Colors.green,
            );
          },
        );
      },
    );
  }

  /// Carga los usuarios que pertenecen a la familia actual
  Future<void> loadFamilyMembers() async {
    if (currentFamily.value == null) {
      _logger.w("No hay familia actual, no se pueden cargar miembros");
      return;
    }

    isLoadingMembers.value = true;
    membersErrorMessage.value = '';
    familyMembers.clear();

    try {
      final family = currentFamily.value!;
      _logger.i("Cargando miembros de la familia: ${family.id}");

      // Cargar información de cada miembro
      for (final memberId in family.members) {
        try {
          // Determinar si el miembro es padre o hijo
          final userResult = await _userRepository.getUserById(memberId);

          userResult.fold(
            (failure) {
              _logger.w(
                  "No se pudo cargar el usuario $memberId: ${failure.message}");
            },
            (user) {
              _logger.d("Usuario cargado: ${user.displayName} (${user.type})");
              familyMembers.add(user);
            },
          );
        } catch (e) {
          _logger.e("Error cargando miembro $memberId: $e");
        }
      }

      // Ordenar miembros (creador primero, luego padres, luego niños)
      familyMembers.sort((a, b) {
        // El creador va primero
        if (a.uid == family.createdBy) return -1;
        if (b.uid == family.createdBy) return 1;

        // Después ordenamos por tipo (padres primero, luego niños)
        if (a.type != b.type) {
          return a.type == 'parent' ? -1 : 1;
        }

        // Si son del mismo tipo, ordenamos alfabéticamente
        return a.displayName.compareTo(b.displayName);
      });

      _logger.i("Miembros de familia cargados: ${familyMembers.length}");
    } catch (e) {
      _logger.e("Error cargando miembros de familia: $e");
      membersErrorMessage.value = 'error_loading_family_members'.tr;
    } finally {
      isLoadingMembers.value = false;
    }
  }

  /// Maps failure types to user-friendly messages
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return TrKeys.serverErrorMessage.tr;
      case NetworkFailure:
        return TrKeys.connectionErrorMessage.tr;
      case NotFoundFailure:
        return 'family_not_found'.tr;
      case ValidationFailure:
        return failure.message;
      default:
        return TrKeys.unexpectedErrorMessage.tr;
    }
  }

  /// Clears all form fields
  void clearForms() {
    familyNameController.clear();
    inviteCodeController.clear();
    errorMessage.value = '';
    status.value = FamilyStatus.initial;
  }
}
