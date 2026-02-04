import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/services/api_service.dart';
import '../models/parcel.dart';
import '../models/parcel_stats.dart';

final parcelsRepositoryProvider = Provider<ParcelsRepository>((ref) {
  return ParcelsRepository(ref.watch(apiServiceProvider));
});

class ParcelsRepository {
  final ApiService _apiService;

  ParcelsRepository(this._apiService);

  Future<ParcelsResponse> getParcels({
    int page = 1,
    int limit = 20,
    ParcelStatus? status,
    CarrierType? carrier,
    String? search,
    bool archived = false,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      'archived': archived,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };

    if (status != null) {
      queryParams['status'] = status.name.toUpperCase();
    }
    if (carrier != null) {
      queryParams['carrier'] = carrier.apiValue;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await _apiService.get(
      '/parcels',
      queryParameters: queryParams,
    );

    return ParcelsResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Parcel> getParcel(String id) async {
    final response = await _apiService.get('/parcels/$id');
    return Parcel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Parcel> createParcel({
    required String trackingNumber,
    CarrierType? carrier,
    String? title,
    String? description,
  }) async {
    final response = await _apiService.post(
      '/parcels',
      data: {
        'trackingNumber': trackingNumber,
        if (carrier != null) 'carrier': carrier.apiValue,
        if (title != null) 'title': title,
        if (description != null) 'description': description,
      },
    );
    return Parcel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Parcel> updateParcel(
    String id, {
    String? title,
    String? description,
    bool? notifyOnUpdate,
    bool? notifyOnDelivery,
  }) async {
    final response = await _apiService.patch(
      '/parcels/$id',
      data: {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (notifyOnUpdate != null) 'notifyOnUpdate': notifyOnUpdate,
        if (notifyOnDelivery != null) 'notifyOnDelivery': notifyOnDelivery,
      },
    );
    return Parcel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteParcel(String id) async {
    await _apiService.delete('/parcels/$id');
  }

  Future<Parcel> refreshParcel(String id) async {
    final response = await _apiService.post('/parcels/$id/refresh');
    return Parcel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Parcel> archiveParcel(String id) async {
    final response = await _apiService.post('/parcels/$id/archive');
    return Parcel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Parcel> unarchiveParcel(String id) async {
    final response = await _apiService.post('/parcels/$id/unarchive');
    return Parcel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ParcelStats> getStats() async {
    final response = await _apiService.get('/parcels/stats');
    return ParcelStats.fromJson(response.data as Map<String, dynamic>);
  }
}

class ParcelsResponse {
  final List<Parcel> data;
  final PaginationMeta meta;

  ParcelsResponse({required this.data, required this.meta});

  factory ParcelsResponse.fromJson(Map<String, dynamic> json) {
    return ParcelsResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => Parcel.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}

class PaginationMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalPages: json['totalPages'] as int,
    );
  }

  bool get hasNextPage => page < totalPages;
}
