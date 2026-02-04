import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/user.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final isAuthenticated = await _authRepository.isAuthenticated();
      if (isAuthenticated) {
        final user = await _authRepository.getCurrentUser();
        state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    try {
      await _authRepository.login(email: email, password: password);
      final user = await _authRepository.getCurrentUser();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
      return true;
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'An unexpected error occurred',
      );
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    String? name,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    try {
      await _authRepository.register(
        email: email,
        password: password,
        name: name,
      );
      final user = await _authRepository.getCurrentUser();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
      return true;
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'An unexpected error occurred',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> refreshUser() async {
    try {
      final user = await _authRepository.getCurrentUser();
      state = state.copyWith(user: user);
    } catch (e) {
      // Ignore refresh errors
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  String _getErrorMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String) return message;
      if (message is List) return message.join(', ');
    }

    switch (error.response?.statusCode) {
      case 401:
        return 'Invalid email or password';
      case 409:
        return 'An account with this email already exists';
      case 400:
        return 'Please check your input and try again';
      default:
        return 'Unable to connect. Please try again.';
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).status == AuthStatus.authenticated;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});
