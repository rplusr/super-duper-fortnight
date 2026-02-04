import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

import '../services/error_handler.dart';

class RetryConfig {
  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;
  final double multiplier;
  final bool Function(dynamic error)? retryIf;

  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.multiplier = 2.0,
    this.retryIf,
  });

  static const defaultConfig = RetryConfig();

  static const networkConfig = RetryConfig(
    maxAttempts: 4,
    initialDelay: Duration(seconds: 2),
    maxDelay: Duration(seconds: 16),
    multiplier: 2.0,
  );
}

class RetryHelper {
  static Future<T> retry<T>({
    required Future<T> Function() action,
    RetryConfig config = RetryConfig.defaultConfig,
    void Function(int attempt, dynamic error)? onRetry,
  }) async {
    int attempt = 0;
    Duration delay = config.initialDelay;

    while (true) {
      attempt++;

      try {
        return await action();
      } catch (error) {
        if (attempt >= config.maxAttempts) {
          rethrow;
        }

        // Check if we should retry this error
        if (config.retryIf != null && !config.retryIf!(error)) {
          rethrow;
        }

        // Default retry logic - only retry network errors
        if (!_shouldRetry(error)) {
          rethrow;
        }

        onRetry?.call(attempt, error);

        // Wait before retrying
        await Future.delayed(delay);

        // Calculate next delay with exponential backoff
        delay = Duration(
          milliseconds: min(
            (delay.inMilliseconds * config.multiplier).round(),
            config.maxDelay.inMilliseconds,
          ),
        );
      }
    }
  }

  static bool _shouldRetry(dynamic error) {
    if (error is DioException) {
      // Retry on network errors
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return true;
      }

      // Retry on 5xx server errors
      final statusCode = error.response?.statusCode;
      if (statusCode != null && statusCode >= 500 && statusCode < 600) {
        return true;
      }
    }

    if (error is AppException) {
      return error.isNetworkError;
    }

    return false;
  }

  /// Retry with jitter to avoid thundering herd problem
  static Future<T> retryWithJitter<T>({
    required Future<T> Function() action,
    RetryConfig config = RetryConfig.defaultConfig,
    void Function(int attempt, dynamic error)? onRetry,
  }) async {
    final random = Random();
    int attempt = 0;
    Duration delay = config.initialDelay;

    while (true) {
      attempt++;

      try {
        return await action();
      } catch (error) {
        if (attempt >= config.maxAttempts) {
          rethrow;
        }

        if (!_shouldRetry(error)) {
          rethrow;
        }

        onRetry?.call(attempt, error);

        // Add jitter (0-25% of delay)
        final jitter = (delay.inMilliseconds * 0.25 * random.nextDouble()).round();
        final delayWithJitter = Duration(milliseconds: delay.inMilliseconds + jitter);

        await Future.delayed(delayWithJitter);

        delay = Duration(
          milliseconds: min(
            (delay.inMilliseconds * config.multiplier).round(),
            config.maxDelay.inMilliseconds,
          ),
        );
      }
    }
  }
}
