import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> loadCurrentSession();
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(String name, String email, String password);
  Future<void> logout();
  Future<List<UserEntity>> fetchAvailableUsers();
  UserEntity? get currentUser;
}
