import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fashion_boutique/shared/services/api_service.dart';

class MockDio extends Mock implements Dio {}

class MockApiService extends Mock implements ApiService {}

// Helper to create mock responses
Response<T> mockResponse<T>({
  required T data,
  int statusCode = 200,
  String statusMessage = 'OK',
}) {
  return Response<T>(
    data: data,
    statusCode: statusCode,
    statusMessage: statusMessage,
    requestOptions: RequestOptions(path: ''),
  );
}

// Sample mock data
final mockUserData = {
  'id': 'user-123',
  'email': 'test@example.com',
  'name': 'Test User',
};

final mockTokenData = {
  'accessToken': 'mock-access-token',
  'refreshToken': 'mock-refresh-token',
  'user': mockUserData,
};

final mockParcelData = {
  'id': 'parcel-123',
  'trackingNumber': '1Z999AA10123456784',
  'carrier': 'UPS',
  'carrierName': 'UPS',
  'title': 'Test Package',
  'status': 'IN_TRANSIT',
  'createdAt': DateTime.now().toIso8601String(),
  'updatedAt': DateTime.now().toIso8601String(),
  'trackingEvents': [],
};

final mockParcelsListData = {
  'data': [mockParcelData],
  'meta': {
    'total': 1,
    'page': 1,
    'limit': 20,
    'totalPages': 1,
  },
};

final mockStatsData = {
  'total': 5,
  'inTransit': 2,
  'delivered': 2,
  'pending': 1,
  'exception': 0,
};
