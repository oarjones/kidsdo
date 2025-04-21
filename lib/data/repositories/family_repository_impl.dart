import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kidsdo/core/errors/failures.dart';
import 'package:kidsdo/data/datasources/remote/family_remote_datasource.dart';
import 'package:kidsdo/data/models/family_model.dart';
import 'package:kidsdo/domain/entities/family.dart';
import 'package:kidsdo/domain/repositories/family_repository.dart';

class FamilyRepositoryImpl implements IFamilyRepository {
  final IFamilyRemoteDataSource _familyRemoteDataSource;

  FamilyRepositoryImpl({
    required IFamilyRemoteDataSource familyRemoteDataSource,
  }) : _familyRemoteDataSource = familyRemoteDataSource;

  @override
  Future<Either<Failure, Family>> createFamily({
    required String name,
    required String createdBy,
  }) async {
    try {
      final familyModel = await _familyRemoteDataSource.createFamily(
        name: name,
        createdBy: createdBy,
      );
      return Right(familyModel);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Family>> getFamilyById(String familyId) async {
    try {
      final familyModel = await _familyRemoteDataSource.getFamilyById(familyId);
      return Right(familyModel);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        return const Left(NotFoundFailure(message: 'Familia no encontrada'));
      }
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Family>> getFamilyByInviteCode(
      String inviteCode) async {
    try {
      final familyModel =
          await _familyRemoteDataSource.getFamilyByInviteCode(inviteCode);
      return Right(familyModel);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        return const Left(NotFoundFailure(
            message: 'Familia no encontrada con este código de invitación'));
      }
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateFamily(Family family) async {
    try {
      await _familyRemoteDataSource
          .updateFamily(FamilyModel.fromEntity(family));
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addMemberToFamily({
    required String familyId,
    required String userId,
  }) async {
    try {
      await _familyRemoteDataSource.addMemberToFamily(
        familyId: familyId,
        userId: userId,
      );
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeMemberFromFamily({
    required String familyId,
    required String userId,
  }) async {
    try {
      await _familyRemoteDataSource.removeMemberFromFamily(
        familyId: familyId,
        userId: userId,
      );
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> generateFamilyInviteCode(
      String familyId) async {
    try {
      final inviteCode =
          await _familyRemoteDataSource.generateFamilyInviteCode(familyId);
      return Right(inviteCode);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
