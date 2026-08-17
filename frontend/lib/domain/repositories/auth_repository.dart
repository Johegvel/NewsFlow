import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> loadCurrentSession();
  Future<UserEntity> login(String email);
  Future<UserEntity> register(String name, String email);
  Future<void> logout();
  Future<List<UserEntity>> fetchAvailableUsers();
  UserEntity? get currentUser;
}
