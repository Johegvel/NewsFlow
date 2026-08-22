import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local_storage_datasource.dart';
import '../datasources/remote_api_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteApiDataSource remoteDataSource;
  final LocalStorageDataSource localDataSource;

  UserEntity? _cachedUser;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  UserEntity? get currentUser => _cachedUser;

  @override
  Future<UserEntity?> loadCurrentSession() async {
    _cachedUser = await localDataSource.getStoredUser();
    return _cachedUser;
  }

  @override
  Future<UserEntity> login(String email, String password) async {
    final userModel = await remoteDataSource.login(email, password);
    await localDataSource.saveUser(userModel);
    _cachedUser = userModel;
    return userModel;
  }

  @override
  Future<UserEntity> register(String name, String email, String password) async {
    final userModel = await remoteDataSource.register(name, email, password);
    await localDataSource.saveUser(userModel);
    _cachedUser = userModel;
    return userModel;
  }

  @override
  Future<void> logout() async {
    _cachedUser = null;
    await localDataSource.clearUser();
  }

  @override
  Future<List<UserEntity>> fetchAvailableUsers() async {
    return await remoteDataSource.fetchAvailableUsers();
  }
}
