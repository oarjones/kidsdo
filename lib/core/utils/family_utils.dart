import 'package:kidsdo/domain/entities/family.dart';
import 'package:kidsdo/domain/entities/parent.dart';
import 'package:kidsdo/domain/entities/child.dart';

/// Utility class for family-related operations
class FamilyUtils {
  /// Checks if a user is the creator of a family
  static bool isCreator(String userId, Family family) {
    return family.createdBy == userId;
  }

  /// Checks if a user is a member of a family
  static bool isMember(String userId, Family family) {
    return family.members.contains(userId);
  }

  /// Gets the role of a user in a family
  static String getUserRole(String userId, Family family) {
    if (isCreator(userId, family)) {
      return 'creator';
    } else if (isMember(userId, family)) {
      return 'member';
    } else {
      return 'none';
    }
  }

  /// Filters children by family ID
  static List<Child> filterChildrenByFamily(
      List<Child> children, String familyId) {
    return children.where((child) => child.familyId == familyId).toList();
  }

  /// Gets the parent of a family
  static Parent? getParentFromFamily(List<Parent> parents, Family family) {
    try {
      return parents.firstWhere((parent) => parent.uid == family.createdBy);
    } catch (e) {
      return null;
    }
  }

  /// Checks if a family code is valid (6 characters)
  static bool isValidFamilyCode(String code) {
    return code.length == 6;
  }

  /// Formats the family code for display (adds spaces every 2 characters)
  static String formatFamilyCode(String code) {
    if (code.length != 6) {
      return code;
    }
    return '${code.substring(0, 2)} ${code.substring(2, 4)} ${code.substring(4, 6)}';
  }
}
