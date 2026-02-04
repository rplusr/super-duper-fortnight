class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://localhost:3000/api';
  static const String wsUrl = 'http://localhost:3000';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Endpoints
  static const String health = '/health';
  static const String users = '/users';
  static const String auth = '/auth';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String products = '/products';
  static const String categories = '/categories';
  static const String cart = '/cart';
  static const String orders = '/orders';
}
