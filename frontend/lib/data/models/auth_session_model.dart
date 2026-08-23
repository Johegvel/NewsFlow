import 'user_model.dart';

class AuthSessionModel {
  final String token;
  final UserModel user;

  const AuthSessionModel({required this.token, required this.user});

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    final token = json['token'] as String?;
    final user = json['user'];

    if (token == null || token.isEmpty || user is! Map<String, dynamic>) {
      throw const FormatException('Respuesta de autenticación inválida');
    }

    return AuthSessionModel(token: token, user: UserModel.fromJson(user));
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'user': user.toJson()};
  }
}
