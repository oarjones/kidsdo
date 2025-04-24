import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/errors/failures.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/family.dart';
import 'package:kidsdo/domain/repositories/family_repository.dart';
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

  FamilyController({
    required IFamilyRepository familyRepository,
    required SessionController sessionController,
    Logger? logger,
  })  : _familyRepository = familyRepository,
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
      (_) {
        // Update the user's familyId in session
        final updatedUser = currentUser.copyWith(familyId: null);
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
