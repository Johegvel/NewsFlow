import 'user_model.dart';

class AuthSessionModel {
  final String token;
  final String? refreshToken;
  final UserModel user;

  const AuthSessionModel({
    required this.token,
    this.refreshToken,
    required this.user,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    final token = json['token'] as String?;
    final refreshToken = json['refresh_token'] as String?;
    final user = json['user'];

    if (token == null || token.isEmpty || user is! Map<String, dynamic>) {
      throw const FormatException('Respuesta de autenticación inválida');
    }

    return AuthSessionModel(
      token: token,
      refreshToken: refreshToken,
      user: UserModel.fromJson(user),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      if (refreshToken != null) 'refresh_token': refreshToken,
      'user': user.toJson(),
    };
  }

  AuthSessionModel copyWith({
    String? token,
    String? refreshToken,
    UserModel? user,
  }) {
    return AuthSessionModel(
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
    );
  }
}
