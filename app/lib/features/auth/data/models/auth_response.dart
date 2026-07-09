import 'user_model.dart';

/// Payload returned by /auth/login and /auth/register.
class AuthResponse {
  const AuthResponse({required this.accessToken, required this.user});

  final String accessToken;
  final UserModel user;

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        accessToken: json['access_token'] as String,
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      );
}
