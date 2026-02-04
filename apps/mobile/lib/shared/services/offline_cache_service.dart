import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/parcels/data/models/parcel.dart';
import '../../features/parcels/data/models/parcel_stats.dart';

class OfflineCacheService {
  static const String _parcelsKey = 'cached_parcels';
  static const String _statsKey = 'cached_stats';
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _userIdKey = 'cached_user_id';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Cache parcels list
  Future<void> cacheParcels(List<Parcel> parcels, String userId) async {
    final prefs = await _preferences;
    final jsonList = parcels.map((p) => _parcelToJson(p)).toList();
    await prefs.setString(_parcelsKey, jsonEncode(jsonList));
    await prefs.setString(_userIdKey, userId);
    await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Get cached parcels
  Future<List<Parcel>?> getCachedParcels(String userId) async {
    final prefs = await _preferences;
    final cachedUserId = prefs.getString(_userIdKey);

    // Return null if cached data is for a different user
    if (cachedUserId != userId) {
      return null;
    }

    final json = prefs.getString(_parcelsKey);
    if (json == null) return null;

    try {
      final List<dynamic> list = jsonDecode(json);
      return list.map((e) => Parcel.fromJson(e)).toList();
    } catch (e) {
      return null;
    }
  }

  // Cache stats
  Future<void> cacheStats(ParcelStats stats) async {
    final prefs = await _preferences;
    await prefs.setString(_statsKey, jsonEncode(_statsToJson(stats)));
  }

  // Get cached stats
  Future<ParcelStats?> getCachedStats() async {
    final prefs = await _preferences;
    final json = prefs.getString(_statsKey);
    if (json == null) return null;

    try {
      return ParcelStats.fromJson(jsonDecode(json));
    } catch (e) {
      return null;
    }
  }

  // Check if cache is stale (older than 5 minutes)
  Future<bool> isCacheStale() async {
    final prefs = await _preferences;
    final lastSync = prefs.getInt(_lastSyncKey);
    if (lastSync == null) return true;

    final lastSyncTime = DateTime.fromMillisecondsSinceEpoch(lastSync);
    return DateTime.now().difference(lastSyncTime).inMinutes > 5;
  }

  // Clear all cached data
  Future<void> clearCache() async {
    final prefs = await _preferences;
    await prefs.remove(_parcelsKey);
    await prefs.remove(_statsKey);
    await prefs.remove(_lastSyncKey);
    await prefs.remove(_userIdKey);
  }

  // Clear cache for specific user (on logout)
  Future<void> clearUserCache() async {
    await clearCache();
  }

  // Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await _preferences;
    final lastSync = prefs.getInt(_lastSyncKey);
    if (lastSync == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(lastSync);
  }

  // Helper to convert Parcel to JSON
  Map<String, dynamic> _parcelToJson(Parcel parcel) {
    return {
      'id': parcel.id,
      'trackingNumber': parcel.trackingNumber,
      'carrier': parcel.carrier.apiValue,
      'carrierName': parcel.carrierName,
      'title': parcel.title,
      'description': parcel.description,
      'status': parcel.status.name.toUpperCase(),
      'estimatedDelivery': parcel.estimatedDelivery?.toIso8601String(),
      'originCountry': parcel.originCountry,
      'destinationCountry': parcel.destinationCountry,
      'weight': parcel.weight,
      'notifyOnUpdate': parcel.notifyOnUpdate,
      'notifyOnDelivery': parcel.notifyOnDelivery,
      'isArchived': parcel.isArchived,
      'lastSyncAt': parcel.lastSyncAt?.toIso8601String(),
      'createdAt': parcel.createdAt.toIso8601String(),
      'updatedAt': parcel.updatedAt.toIso8601String(),
      'trackingEvents': parcel.trackingEvents.map((e) => {
        'id': e.id,
        'status': e.status,
        'statusCode': e.statusCode,
        'description': e.description,
        'location': e.location,
        'city': e.city,
        'country': e.country,
        'timestamp': e.timestamp.toIso8601String(),
      }).toList(),
    };
  }

  // Helper to convert ParcelStats to JSON
  Map<String, dynamic> _statsToJson(ParcelStats stats) {
    return {
      'total': stats.total,
      'inTransit': stats.inTransit,
      'delivered': stats.delivered,
      'pending': stats.pending,
      'exception': stats.exception,
    };
  }
}
