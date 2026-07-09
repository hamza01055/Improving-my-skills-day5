import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/secure_storage_service.dart';
import 'models/auth_response.dart';
import 'models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(secureStorageProvider),
  );
});

/// Single source of truth for authentication against the backend.
class AuthRepository {
  const AuthRepository(this._api, this._storage);

  final ApiClient _api;
  final SecureStorageService _storage;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final res = await _api.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    final auth = AuthResponse.fromJson(res.data as Map<String, dynamic>);
    await _storage.saveToken(auth.accessToken);
    return auth.user;
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await _api.post(
      ApiEndpoints.register,
      data: {'name': name, 'email': email, 'password': password},
    );
    final auth = AuthResponse.fromJson(res.data as Map<String, dynamic>);
    await _storage.saveToken(auth.accessToken);
    return auth.user;
  }

  Future<void> forgotPassword(String email) async {
    await _api.post(ApiEndpoints.forgotPassword, data: {'email': email});
  }

  /// Restores the session from a stored token, or returns null.
  Future<UserModel?> restoreSession() async {
    final String? token = await _storage.readToken();
    if (token == null) return null;
    try {
      final res = await _api.get(ApiEndpoints.me);
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      await _storage.clear();
      return null;
    }
  }

  Future<void> logout() => _storage.clear();
}
