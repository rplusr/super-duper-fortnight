import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import 'secure_storage_service.dart';

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

class ParcelUpdate {
  final String parcelId;
  final String? status;
  final DateTime? estimatedDelivery;
  final DateTime? lastSyncAt;
  final int? newEventsCount;

  ParcelUpdate({
    required this.parcelId,
    this.status,
    this.estimatedDelivery,
    this.lastSyncAt,
    this.newEventsCount,
  });

  factory ParcelUpdate.fromJson(Map<String, dynamic> json) {
    return ParcelUpdate(
      parcelId: json['parcelId'] as String,
      status: json['status'] as String?,
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.parse(json['estimatedDelivery'] as String)
          : null,
      lastSyncAt: json['lastSyncAt'] != null
          ? DateTime.parse(json['lastSyncAt'] as String)
          : null,
      newEventsCount: json['newEventsCount'] as int?,
    );
  }
}

class StatusChange {
  final String parcelId;
  final String oldStatus;
  final String newStatus;
  final DateTime timestamp;

  StatusChange({
    required this.parcelId,
    required this.oldStatus,
    required this.newStatus,
    required this.timestamp,
  });

  factory StatusChange.fromJson(Map<String, dynamic> json) {
    return StatusChange(
      parcelId: json['parcelId'] as String,
      oldStatus: json['oldStatus'] as String,
      newStatus: json['newStatus'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class TrackingEventUpdate {
  final String parcelId;
  final Map<String, dynamic> event;

  TrackingEventUpdate({
    required this.parcelId,
    required this.event,
  });

  factory TrackingEventUpdate.fromJson(Map<String, dynamic> json) {
    return TrackingEventUpdate(
      parcelId: json['parcelId'] as String,
      event: json['event'] as Map<String, dynamic>,
    );
  }
}

class WebSocketService {
  static WebSocketService? _instance;
  static WebSocketService get instance {
    _instance ??= WebSocketService._();
    return _instance!;
  }

  WebSocketService._();

  io.Socket? _socket;
  final SecureStorageService _secureStorage = SecureStorageService();

  String _baseUrl = '';

  // Stream controllers for events
  final _connectionStatusController = StreamController<ConnectionStatus>.broadcast();
  final _parcelUpdateController = StreamController<ParcelUpdate>.broadcast();
  final _statusChangeController = StreamController<StatusChange>.broadcast();
  final _trackingEventController = StreamController<TrackingEventUpdate>.broadcast();

  Stream<ConnectionStatus> get connectionStatus => _connectionStatusController.stream;
  Stream<ParcelUpdate> get parcelUpdates => _parcelUpdateController.stream;
  Stream<StatusChange> get statusChanges => _statusChangeController.stream;
  Stream<TrackingEventUpdate> get trackingEvents => _trackingEventController.stream;

  ConnectionStatus _currentStatus = ConnectionStatus.disconnected;
  ConnectionStatus get currentConnectionStatus => _currentStatus;

  void configure(String baseUrl) {
    _baseUrl = baseUrl;
  }

  Future<void> connect() async {
    if (_socket != null && _socket!.connected) {
      return;
    }

    final token = await _secureStorage.getAccessToken();
    if (token == null) {
      _updateStatus(ConnectionStatus.error);
      return;
    }

    _updateStatus(ConnectionStatus.connecting);

    _socket = io.io(
      '$_baseUrl/events',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setAuth({'token': token})
          .build(),
    );

    _setupListeners();
    _socket!.connect();
  }

  void _setupListeners() {
    _socket!.onConnect((_) {
      _updateStatus(ConnectionStatus.connected);
    });

    _socket!.onDisconnect((_) {
      _updateStatus(ConnectionStatus.disconnected);
    });

    _socket!.onReconnecting((_) {
      _updateStatus(ConnectionStatus.reconnecting);
    });

    _socket!.onConnectError((error) {
      _updateStatus(ConnectionStatus.error);
    });

    _socket!.onError((error) {
      _updateStatus(ConnectionStatus.error);
    });

    // Listen for parcel updates
    _socket!.on('parcel:updated', (data) {
      if (data is Map<String, dynamic>) {
        _parcelUpdateController.add(ParcelUpdate.fromJson(data));
      }
    });

    // Listen for status changes
    _socket!.on('parcel:status-changed', (data) {
      if (data is Map<String, dynamic>) {
        _statusChangeController.add(StatusChange.fromJson(data));
      }
    });

    // Listen for new tracking events
    _socket!.on('tracking:new-event', (data) {
      if (data is Map<String, dynamic>) {
        _trackingEventController.add(TrackingEventUpdate.fromJson(data));
      }
    });

    // Listen for connection acknowledgement
    _socket!.on('connected', (data) {
      // Connection confirmed by server
    });
  }

  void _updateStatus(ConnectionStatus status) {
    _currentStatus = status;
    _connectionStatusController.add(status);
  }

  void subscribeToParcel(String parcelId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('subscribe:parcel', {'parcelId': parcelId});
    }
  }

  void unsubscribeFromParcel(String parcelId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('unsubscribe:parcel', {'parcelId': parcelId});
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _updateStatus(ConnectionStatus.disconnected);
  }

  Future<void> reconnect() async {
    disconnect();
    await connect();
  }

  void dispose() {
    disconnect();
    _connectionStatusController.close();
    _parcelUpdateController.close();
    _statusChangeController.close();
    _trackingEventController.close();
  }
}
