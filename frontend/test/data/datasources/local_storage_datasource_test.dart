import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/data/datasources/local_storage_datasource.dart';
import 'package:frontend/data/models/auth_session_model.dart';
import 'package:frontend/data/models/user_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('persists and restores the complete authentication session', () async {
    final dataSource = LocalStorageDataSourceImpl();
    const session = AuthSessionModel(
      token: 'jwt-token',
      user: UserModel(
        id: 7,
        name: 'Usuario de prueba',
        email: 'user@example.com',
      ),
    );

    await dataSource.saveSession(session);
    final restored = await dataSource.getStoredSession();

    expect(restored?.token, 'jwt-token');
    expect(restored?.user.id, 7);

    await dataSource.clearSession();
    expect(await dataSource.getStoredSession(), isNull);
  });
}
