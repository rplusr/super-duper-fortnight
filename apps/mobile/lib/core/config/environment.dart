import 'package:flutter/foundation.dart';

enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static Environment _environment = Environment.development;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static Environment get environment => _environment;

  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.production;

  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.development:
        return const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'http://localhost:3000/api',
        );
      case Environment.staging:
        return const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://staging-api.parceltracker.app/api',
        );
      case Environment.production:
        return const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://api.parceltracker.app/api',
        );
    }
  }

  static String get wsBaseUrl {
    switch (_environment) {
      case Environment.development:
        return const String.fromEnvironment(
          'WS_BASE_URL',
          defaultValue: 'http://localhost:3000',
        );
      case Environment.staging:
        return const String.fromEnvironment(
          'WS_BASE_URL',
          defaultValue: 'https://staging-api.parceltracker.app',
        );
      case Environment.production:
        return const String.fromEnvironment(
          'WS_BASE_URL',
          defaultValue: 'https://api.parceltracker.app',
        );
    }
  }

  static bool get enableLogging {
    return kDebugMode || !isProduction;
  }

  static bool get enableCrashReporting {
    return isProduction || isStaging;
  }

  static bool get enableAnalytics {
    return isProduction;
  }

  static Map<String, dynamic> toMap() {
    return {
      'environment': _environment.name,
      'apiBaseUrl': apiBaseUrl,
      'wsBaseUrl': wsBaseUrl,
      'enableLogging': enableLogging,
      'enableCrashReporting': enableCrashReporting,
      'enableAnalytics': enableAnalytics,
    };
  }
}
