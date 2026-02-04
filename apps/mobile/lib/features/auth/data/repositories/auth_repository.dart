import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/auth_tokens.dart';
import '../../../../shared/models/user.dart';
import '../../../../shared/services/api_service.dart';
import '../../../../shared/services/secure_storage_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiServiceProvider),
    ref.watch(secureStorageServiceProvider),
  );
});

class AuthRepository {
  final ApiService _apiService;
  final SecureStorageService _secureStorage;

  AuthRepository(this._apiService, this._secureStorage);

  Future<AuthTokens> register({
    required String email,
    required String password,
    String? name,
  }) async {
    final response = await _apiService.post(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        if (name != null) 'name': name,
      },
    );

    final tokens = AuthTokens.fromJson(response.data as Map<String, dynamic>);
    await _secureStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );

    return tokens;
  }

  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final tokens = AuthTokens.fromJson(response.data as Map<String, dynamic>);
    await _secureStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );

    return tokens;
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      await _apiService.post(
        '/auth/logout',
        data: {'refreshToken': refreshToken},
      );
    } catch (e) {
      // Ignore errors during logout
    } finally {
      await _secureStorage.clearTokens();
    }
  }

  Future<User> getCurrentUser() async {
    final response = await _apiService.get('/users/me');
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<User> updateProfile({
    String? name,
    String? pushToken,
    bool? notificationsEnabled,
  }) async {
    final response = await _apiService.patch(
      '/users/me',
      data: {
        if (name != null) 'name': name,
        if (pushToken != null) 'pushToken': pushToken,
        if (notificationsEnabled != null)
          'notificationsEnabled': notificationsEnabled,
      },
    );
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<bool> isAuthenticated() async {
    return _secureStorage.hasTokens();
  }
}

class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, [this.code]);

  factory AuthException.fromDioError(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      return AuthException(
        data['message'] as String? ?? 'An error occurred',
        data['statusCode']?.toString(),
      );
    }
    return AuthException('An error occurred');
  }

  @override
  String toString() => message;
}
