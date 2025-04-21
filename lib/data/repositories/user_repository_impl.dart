import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kidsdo/core/errors/failures.dart';
import 'package:kidsdo/data/datasources/remote/user_remote_datasource.dart';
import 'package:kidsdo/data/models/child_model.dart';
import 'package:kidsdo/data/models/parent_model.dart';
import 'package:kidsdo/domain/entities/base_user.dart';
import 'package:kidsdo/domain/entities/child.dart';
import 'package:kidsdo/domain/entities/parent.dart';
import 'package:kidsdo/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements IUserRepository {
  final IUserRemoteDataSource _userRemoteDataSource;

  UserRepositoryImpl({
    required IUserRemoteDataSource userRemoteDataSource,
  }) : _userRemoteDataSource = userRemoteDataSource;

  @override
  Future<Either<Failure, void>> saveParent(Parent parent) async {
    try {
      await _userRemoteDataSource.saveParent(ParentModel.fromEntity(parent));
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveChild(Child child) async {
    try {
      await _userRemoteDataSource.saveChild(ChildModel.fromEntity(child));
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BaseUser>> getUserById(String userId) async {
    try {
      final userModel = await _userRemoteDataSource.getUserById(userId);
      return Right(userModel);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        return const Left(NotFoundFailure(message: 'Usuario no encontrado'));
      }
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Parent>> getParentById(String parentId) async {
    try {
      final parentModel = await _userRemoteDataSource.getParentById(parentId);
      return Right(parentModel);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        return const Left(NotFoundFailure(message: 'Padre no encontrado'));
      } else if (e.code == 'invalid-type') {
        return const Left(
            ValidationFailure(message: 'El usuario no es un padre'));
      }
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Child>> getChildById(String childId) async {
    try {
      final childModel = await _userRemoteDataSource.getChildById(childId);
      return Right(childModel);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        return const Left(NotFoundFailure(message: 'Hijo no encontrado'));
      } else if (e.code == 'invalid-type') {
        return const Left(
            ValidationFailure(message: 'El usuario no es un hijo'));
      }
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Child>>> getChildrenByParentId(
      String parentId) async {
    try {
      final childrenModels =
          await _userRemoteDataSource.getChildrenByParentId(parentId);
      return Right(childrenModels);
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
      await _userRemoteDataSource.updateChildPoints(childId, points);
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
      await _userRemoteDataSource.updateChildLevel(childId, level);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserSettings(
    String userId,
    Map<String, dynamic> settings,
  ) async {
    try {
      await _userRemoteDataSource.updateUserSettings(userId, settings);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
