import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:kidsdo/data/models/reward_model.dart';
import 'package:kidsdo/domain/entities/reward.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

abstract class IRewardRemoteDataSource {
  Future<RewardModel> createReward(RewardModel reward);
  Stream<List<RewardModel>> getRewardsStream(String familyId);
  Future<List<RewardModel>> getRewardsOnce(String familyId);
  Future<RewardModel> updateReward(RewardModel reward);
  Future<void> deleteReward(
      {required String familyId, required String rewardId});
  Future<List<RewardModel>> getPredefinedRewards({String? category});
}

class RewardRemoteDataSourceImpl implements IRewardRemoteDataSource {
  final FirebaseFirestore _firestore;
  final Logger _logger;

  // Para generar IDs si es necesario aquí, aunque es mejor en el repo/controller
  final Uuid _uuid;

  static const String _rewardsCollection = 'rewards'; // Colección raíz
  // O si es subcolección de familias:
  // static const String _familiesCollection = 'families';
  // static const String _familyRewardsSubCollection = 'rewards';

  RewardRemoteDataSourceImpl({
    FirebaseFirestore?
        firestore, // Hacemos opcional para usar Get.find si no se provee
    Logger? logger,
    Uuid? uuid,
  })  : _firestore = firestore ?? Get.find<FirebaseFirestore>(),
        _logger = logger ?? Get.find<Logger>(),
        _uuid = uuid ?? Get.find<Uuid>();

  @override
  Future<RewardModel> createReward(RewardModel reward) async {
    try {
      _logger.d('Attempting to create reward in Firestore: ${reward.name}');
      // Asumimos que el ID, createdAt, y updatedAt se manejan antes de llamar aquí,
      // o se generan aquí si no vienen.
      // El modelo ya debería tener un ID.
      final docRef = _firestore.collection(_rewardsCollection).doc(reward.id);
      await docRef.set(reward.toFirestore());
      _logger.i('Reward created successfully in Firestore: ${reward.id}');
      return reward; // Devuelve el mismo modelo ya que Firestore no devuelve el doc en set.
    } on FirebaseException catch (e) {
      _logger.e(
          'FirebaseException while creating reward: ${e.message}, code: ${e.code}');
      throw Exception(
          'Error creating reward: ${e.message}'); // Será atrapado como ServerFailure
    } catch (e) {
      _logger.e('Unexpected error while creating reward: $e');
      throw Exception('Unexpected error creating reward');
    }
  }

  @override
  Stream<List<RewardModel>> getRewardsStream(String familyId) {
    _logger.d('Streaming rewards for familyId: $familyId');
    return _firestore
        .collection(_rewardsCollection)
        .where('familyId', isEqualTo: familyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final rewards = snapshot.docs
          .map((doc) => RewardModel.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
      _logger.i('Streamed ${rewards.length} rewards for family $familyId');
      return rewards;
    }).handleError((error) {
      _logger.e('Error in getRewardsStream for family $familyId: $error');
      // Considerar cómo manejar errores en streams para que no cierren el stream principal.
      // Podría emitir una lista vacía o una lista con un "Reward de Error".
      // O dejar que el repositorio lo maneje con Either.
      throw Exception('Failed to stream rewards: $error');
    });
  }

  @override
  Future<List<RewardModel>> getRewardsOnce(String familyId) async {
    try {
      _logger.d('Fetching rewards once for familyId: $familyId');
      final snapshot = await _firestore
          .collection(_rewardsCollection)
          .where('familyId', isEqualTo: familyId)
          .orderBy('createdAt', descending: true)
          .get();

      final rewards = snapshot.docs
          .map((doc) => RewardModel.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
      _logger.i('Fetched ${rewards.length} rewards for family $familyId');
      return rewards;
    } on FirebaseException catch (e) {
      _logger.e('FirebaseException while fetching rewards once: ${e.message}');
      throw Exception('Error fetching rewards: ${e.message}');
    } catch (e) {
      _logger.e('Unexpected error while fetching rewards once: $e');
      throw Exception('Unexpected error fetching rewards');
    }
  }

  @override
  Future<RewardModel> updateReward(RewardModel reward) async {
    try {
      _logger.d('Attempting to update reward in Firestore: ${reward.id}');
      final docRef = _firestore.collection(_rewardsCollection).doc(reward.id);
      // Asegurarse que updatedAt se actualiza (el modelo lo hace, pero podrías forzarlo aquí)
      // final rewardToUpdate = reward.copyWith(updatedAt: DateTime.now()); // No es necesario si el modelo ya lo hace
      await docRef.update(reward.toFirestore());
      _logger.i('Reward updated successfully in Firestore: ${reward.id}');
      return reward; // Devuelve el modelo actualizado.
    } on FirebaseException catch (e) {
      _logger.e('FirebaseException while updating reward: ${e.message}');
      throw Exception('Error updating reward: ${e.message}');
    } catch (e) {
      _logger.e('Unexpected error while updating reward: $e');
      throw Exception('Unexpected error updating reward');
    }
  }

  @override
  Future<void> deleteReward(
      {required String familyId, required String rewardId}) async {
    // Si usamos una colección raíz 'rewards', el familyId no es necesario para la ruta de borrado
    // pero es bueno tenerlo para logging o verificaciones adicionales si se necesitaran.
    try {
      _logger.d(
          'Attempting to delete reward from Firestore: $rewardId for family $familyId');
      await _firestore.collection(_rewardsCollection).doc(rewardId).delete();
      _logger.i('Reward deleted successfully from Firestore: $rewardId');
    } on FirebaseException catch (e) {
      _logger.e('FirebaseException while deleting reward: ${e.message}');
      throw Exception('Error deleting reward: ${e.message}');
    } catch (e) {
      _logger.e('Unexpected error while deleting reward: $e');
      throw Exception('Unexpected error deleting reward');
    }
  }

  @override
  Future<List<RewardModel>> getPredefinedRewards({String? category}) async {
    try {
      _logger.d('Fetching predefined rewards. Category: $category');
      Query query =
          _firestore.collection('predefined_rewards'); // Nueva colección
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }
      // query = query.orderBy('name_en'); // O algún orden

      final snapshot = await query.get();
      final languageCode = Get.locale?.languageCode ?? 'es';

      final rewards = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Adaptar PredefinedReward de Firestore a RewardModel/Entity
        return RewardModel(
          id: doc.id, // Este es el ID de la plantilla
          familyId: '', // No aplica o es un placeholder
          name: data['name_$languageCode'] ?? data['name_en'] ?? doc.id,
          description:
              data['description_$languageCode'] ?? data['description_en'],
          pointsRequired: data['pointsRequired'] as int,
          type: rewardTypeFromString(data['type'] as String?),
          icon: data['icon'] as String?,
          createdAt: DateTime
              .now(), // No es relevante para plantillas o usar un valor fijo
          updatedAt: DateTime.now(), // No es relevante
          createdBy: 'system', // Identificador para plantillas
          status: RewardStatus.available, // Plantillas siempre disponibles
          typeSpecificData: data['typeSpecificData'] != null
              ? Map<String, dynamic>.from(data['typeSpecificData'] as Map)
              : null,
          isUnique: data['isUnique'] as bool? ?? false,
          isEnabled: true, // Plantillas siempre habilitadas
        );
      }).toList();
      _logger.i('Fetched ${rewards.length} predefined rewards.');
      return rewards;
    } on FirebaseException catch (e) {
      _logger.e(
          'FirebaseException while fetching predefined rewards: ${e.message}');
      throw Exception('Error fetching predefined rewards: ${e.message}');
    } catch (e) {
      _logger.e('Unexpected error while fetching predefined rewards: $e');
      throw Exception('Unexpected error fetching predefined rewards');
    }
  }
}
