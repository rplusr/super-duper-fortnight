import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/websocket_service.dart';
import '../../core/constants/api_constants.dart';

// WebSocket service provider
final websocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService.instance;
  service.configure(ApiConstants.wsUrl);

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

// Connection status provider
final connectionStatusProvider = StreamProvider<ConnectionStatus>((ref) {
  final service = ref.watch(websocketServiceProvider);
  return service.connectionStatus;
});

// Current connection status provider (non-stream)
final currentConnectionStatusProvider = Provider<ConnectionStatus>((ref) {
  final asyncStatus = ref.watch(connectionStatusProvider);
  return asyncStatus.when(
    data: (status) => status,
    loading: () => ConnectionStatus.disconnected,
    error: (_, __) => ConnectionStatus.error,
  );
});

// Parcel updates stream provider
final parcelUpdatesProvider = StreamProvider<ParcelUpdate>((ref) {
  final service = ref.watch(websocketServiceProvider);
  return service.parcelUpdates;
});

// Status changes stream provider
final statusChangesProvider = StreamProvider<StatusChange>((ref) {
  final service = ref.watch(websocketServiceProvider);
  return service.statusChanges;
});

// Tracking events stream provider
final trackingEventsProvider = StreamProvider<TrackingEventUpdate>((ref) {
  final service = ref.watch(websocketServiceProvider);
  return service.trackingEvents;
});

// WebSocket connection controller
class WebSocketController extends StateNotifier<bool> {
  final WebSocketService _service;
  StreamSubscription? _statusSubscription;

  WebSocketController(this._service) : super(false) {
    _statusSubscription = _service.connectionStatus.listen((status) {
      state = status == ConnectionStatus.connected;
    });
  }

  Future<void> connect() async {
    await _service.connect();
  }

  void disconnect() {
    _service.disconnect();
  }

  Future<void> reconnect() async {
    await _service.reconnect();
  }

  void subscribeToParcel(String parcelId) {
    _service.subscribeToParcel(parcelId);
  }

  void unsubscribeFromParcel(String parcelId) {
    _service.unsubscribeFromParcel(parcelId);
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }
}

final websocketControllerProvider =
    StateNotifierProvider<WebSocketController, bool>((ref) {
  final service = ref.watch(websocketServiceProvider);
  return WebSocketController(service);
});
