import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

enum ErrorType {
  network,
  server,
  authentication,
  validation,
  timeout,
  unknown,
}

class AppException implements Exception {
  final String message;
  final ErrorType type;
  final dynamic originalError;
  final int? statusCode;

  AppException({
    required this.message,
    required this.type,
    this.originalError,
    this.statusCode,
  });

  factory AppException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException(
          message: 'Connection timed out. Please try again.',
          type: ErrorType.timeout,
          originalError: error,
        );

      case DioExceptionType.connectionError:
        return AppException(
          message: 'No internet connection. Please check your network.',
          type: ErrorType.network,
          originalError: error,
        );

      case DioExceptionType.badResponse:
        return _handleStatusCode(error);

      case DioExceptionType.cancel:
        return AppException(
          message: 'Request was cancelled.',
          type: ErrorType.unknown,
          originalError: error,
        );

      default:
        return AppException(
          message: 'An unexpected error occurred.',
          type: ErrorType.unknown,
          originalError: error,
        );
    }
  }

  static AppException _handleStatusCode(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    String message = 'An error occurred';
    if (data is Map<String, dynamic>) {
      final serverMessage = data['message'];
      if (serverMessage is String) {
        message = serverMessage;
      } else if (serverMessage is List) {
        message = serverMessage.join(', ');
      }
    }

    switch (statusCode) {
      case 400:
        return AppException(
          message: message,
          type: ErrorType.validation,
          statusCode: statusCode,
          originalError: error,
        );
      case 401:
        return AppException(
          message: 'Session expired. Please log in again.',
          type: ErrorType.authentication,
          statusCode: statusCode,
          originalError: error,
        );
      case 403:
        return AppException(
          message: 'You do not have permission to perform this action.',
          type: ErrorType.authentication,
          statusCode: statusCode,
          originalError: error,
        );
      case 404:
        return AppException(
          message: 'The requested resource was not found.',
          type: ErrorType.server,
          statusCode: statusCode,
          originalError: error,
        );
      case 409:
        return AppException(
          message: message,
          type: ErrorType.validation,
          statusCode: statusCode,
          originalError: error,
        );
      case 500:
      case 502:
      case 503:
        return AppException(
          message: 'Server error. Please try again later.',
          type: ErrorType.server,
          statusCode: statusCode,
          originalError: error,
        );
      default:
        return AppException(
          message: message,
          type: ErrorType.unknown,
          statusCode: statusCode,
          originalError: error,
        );
    }
  }

  factory AppException.fromError(dynamic error) {
    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      return AppException.fromDioError(error);
    }

    if (error is SocketException) {
      return AppException(
        message: 'No internet connection.',
        type: ErrorType.network,
        originalError: error,
      );
    }

    if (error is TimeoutException) {
      return AppException(
        message: 'Request timed out. Please try again.',
        type: ErrorType.timeout,
        originalError: error,
      );
    }

    return AppException(
      message: error?.toString() ?? 'An unexpected error occurred.',
      type: ErrorType.unknown,
      originalError: error,
    );
  }

  @override
  String toString() => message;

  bool get isNetworkError => type == ErrorType.network || type == ErrorType.timeout;
  bool get isAuthError => type == ErrorType.authentication;
}

class ErrorHandler {
  static void logError(dynamic error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('Error: $error');
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }

    // In production, send to error tracking service (e.g., Sentry, Crashlytics)
  }

  static AppException handleError(dynamic error, [StackTrace? stackTrace]) {
    logError(error, stackTrace);
    return AppException.fromError(error);
  }
}
