import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import '../utils/api_exception.dart';
import 'secure_storage_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(secureStorageProvider));
});

/// Endpoints that must never trigger the refresh-and-retry flow: they
/// either don't carry a bearer token, or retrying them on 401 would
/// create an infinite loop against the refresh mechanism itself.
const _authExemptPaths = <String>[
  ApiEndpoints.login,
  ApiEndpoints.register,
  ApiEndpoints.refresh,
  ApiEndpoints.logout,
];

/// Thin Dio wrapper: base config, bearer-token injection, error mapping,
/// and transparent access-token refresh-and-retry on 401.
class ApiClient {
  ApiClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final String? token = await _storage.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final bool is401 = error.response?.statusCode == 401;
          final String path = error.requestOptions.path;
          final bool exempt = _authExemptPaths.any(path.endsWith);
          final bool alreadyRetried =
              error.requestOptions.extra['retried'] == true;

          if (!is401 || exempt || alreadyRetried) {
            handler.next(error);
            return;
          }

          final String? newAccessToken = await _refreshAccessToken();
          if (newAccessToken == null) {
            onSessionExpired?.call();
            handler.next(error);
            return;
          }

          final RequestOptions retryOptions = error.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          retryOptions.extra['retried'] = true;
          try {
            final Response<dynamic> response = await _dio.fetch(retryOptions);
            handler.resolve(response);
          } on DioException catch (e) {
            handler.next(e);
          }
        },
      ),
    );
  }

  final SecureStorageService _storage;
  late final Dio _dio;

  /// Set by the auth layer; invoked when refresh fails so the app can
  /// react (the router already redirects to login once auth state flips).
  void Function()? onSessionExpired;

  Future<String?>? _refreshInFlight;

  /// Ensures only one refresh call is ever in flight, even if many
  /// requests 401 concurrently.
  Future<String?> _refreshAccessToken() {
    return _refreshInFlight ??= _doRefresh().whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<String?> _doRefresh() async {
    final String? refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null) return null;
    try {
      final response = await _dio.post(
        ApiEndpoints.refresh,
        data: {'refresh_token': refreshToken},
      );
      final data = response.data as Map<String, dynamic>;
      final String newAccess = data['access_token'] as String;
      final String newRefresh = data['refresh_token'] as String;
      await _storage.saveToken(newAccess);
      await _storage.saveRefreshToken(newRefresh);
      return newAccess;
    } catch (_) {
      await _storage.clear();
      return null;
    }
  }

  Future<Response<dynamic>> get(String path,
      {Map<String, dynamic>? query}) async {
    try {
      return await _dio.get(path, queryParameters: query);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Response<dynamic>> post(String path, {Object? data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Response<dynamic>> put(String path, {Object? data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Response<dynamic>> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Response<dynamic>> postForm(String path, FormData data) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
