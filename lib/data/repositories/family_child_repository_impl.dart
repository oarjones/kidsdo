import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kidsdo/core/errors/failures.dart';
import 'package:kidsdo/data/datasources/remote/family_child_remote_datasource.dart';
import 'package:kidsdo/data/models/family_child_model.dart';
import 'package:kidsdo/domain/entities/family_child.dart';
import 'package:kidsdo/domain/repositories/family_child_repository.dart';

class FamilyChildRepositoryImpl implements IFamilyChildRepository {
  final IFamilyChildRemoteDataSource _familyChildRemoteDataSource;

  FamilyChildRepositoryImpl({
    required IFamilyChildRemoteDataSource familyChildRemoteDataSource,
  }) : _familyChildRemoteDataSource = familyChildRemoteDataSource;

  @override
  Future<Either<Failure, FamilyChild>> createChild({
    required String familyId,
    required String name,
    required DateTime birthDate,
    String? avatarUrl,
    required String createdBy,
    required Map<String, dynamic> settings,
  }) async {
    try {
      final childModel = await _familyChildRemoteDataSource.createChild(
        familyId: familyId,
        name: name,
        birthDate: birthDate,
        avatarUrl: avatarUrl,
        createdBy: createdBy,
        settings: settings,
      );
      return Right(childModel);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, FamilyChild>> getChildById(String childId) async {
    try {
      final childModel =
          await _familyChildRemoteDataSource.getChildById(childId);
      return Right(childModel);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        return const Left(
            NotFoundFailure(message: 'Perfil infantil no encontrado'));
      }
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FamilyChild>>> getChildrenByFamilyId(
      String familyId) async {
    try {
      final childrenModels =
          await _familyChildRemoteDataSource.getChildrenByFamilyId(familyId);
      return Right(childrenModels);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FamilyChild>>> getChildrenByCreator(
      String creatorId) async {
    try {
      final childrenModels =
          await _familyChildRemoteDataSource.getChildrenByCreator(creatorId);
      return Right(childrenModels);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateChild(FamilyChild child) async {
    try {
      await _familyChildRemoteDataSource
          .updateChild(FamilyChildModel.fromEntity(child));
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChild(String childId) async {
    try {
      await _familyChildRemoteDataSource.deleteChild(childId);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateChildPoints(
      String childId, int points) async {
    try {
      await _familyChildRemoteDataSource.updateChildPoints(childId, points);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateChildLevel(
      String childId, int level) async {
    try {
      await _familyChildRemoteDataSource.updateChildLevel(childId, level);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateChildSettings(
    String childId,
    Map<String, dynamic> settings,
  ) async {
    try {
      await _familyChildRemoteDataSource.updateChildSettings(childId, settings);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
