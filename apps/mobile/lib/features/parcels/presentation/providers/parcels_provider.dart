import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/parcel.dart';
import '../../data/models/parcel_stats.dart';
import '../../data/repositories/parcels_repository.dart';

// Stats provider
final parcelStatsProvider = FutureProvider.autoDispose<ParcelStats>((ref) async {
  final repository = ref.watch(parcelsRepositoryProvider);
  return repository.getStats();
});

// Parcels list provider with pagination
class ParcelsListState {
  final List<Parcel> parcels;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? error;
  final ParcelStatus? statusFilter;
  final String? searchQuery;

  const ParcelsListState({
    this.parcels = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
    this.statusFilter,
    this.searchQuery,
  });

  ParcelsListState copyWith({
    List<Parcel>? parcels,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? error,
    ParcelStatus? statusFilter,
    String? searchQuery,
    bool clearError = false,
    bool clearStatusFilter = false,
    bool clearSearchQuery = false,
  }) {
    return ParcelsListState(
      parcels: parcels ?? this.parcels,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: clearError ? null : (error ?? this.error),
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
    );
  }
}

class ParcelsListNotifier extends StateNotifier<ParcelsListState> {
  final ParcelsRepository _repository;

  ParcelsListNotifier(this._repository) : super(const ParcelsListState()) {
    loadParcels();
  }

  Future<void> loadParcels({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, currentPage: 1, clearError: true);
    }

    try {
      final response = await _repository.getParcels(
        page: 1,
        status: state.statusFilter,
        search: state.searchQuery,
      );

      state = state.copyWith(
        parcels: response.data,
        isLoading: false,
        hasMore: response.meta.hasNextPage,
        currentPage: 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load parcels',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final response = await _repository.getParcels(
        page: nextPage,
        status: state.statusFilter,
        search: state.searchQuery,
      );

      state = state.copyWith(
        parcels: [...state.parcels, ...response.data],
        isLoadingMore: false,
        hasMore: response.meta.hasNextPage,
        currentPage: nextPage,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void setStatusFilter(ParcelStatus? status) {
    if (status == state.statusFilter) return;
    state = state.copyWith(
      statusFilter: status,
      clearStatusFilter: status == null,
    );
    loadParcels(refresh: true);
  }

  void setSearchQuery(String? query) {
    state = state.copyWith(
      searchQuery: query,
      clearSearchQuery: query == null || query.isEmpty,
    );
    loadParcels(refresh: true);
  }

  void removeParcel(String id) {
    state = state.copyWith(
      parcels: state.parcels.where((p) => p.id != id).toList(),
    );
  }

  void updateParcel(Parcel parcel) {
    state = state.copyWith(
      parcels: state.parcels.map((p) => p.id == parcel.id ? parcel : p).toList(),
    );
  }
}

final parcelsListProvider =
    StateNotifierProvider.autoDispose<ParcelsListNotifier, ParcelsListState>((ref) {
  return ParcelsListNotifier(ref.watch(parcelsRepositoryProvider));
});

// Single parcel provider
final parcelProvider = FutureProvider.autoDispose.family<Parcel, String>((ref, id) async {
  final repository = ref.watch(parcelsRepositoryProvider);
  return repository.getParcel(id);
});

// Create parcel provider
class CreateParcelState {
  final bool isLoading;
  final String? error;
  final Parcel? createdParcel;

  const CreateParcelState({
    this.isLoading = false,
    this.error,
    this.createdParcel,
  });

  CreateParcelState copyWith({
    bool? isLoading,
    String? error,
    Parcel? createdParcel,
    bool clearError = false,
  }) {
    return CreateParcelState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      createdParcel: createdParcel ?? this.createdParcel,
    );
  }
}

class CreateParcelNotifier extends StateNotifier<CreateParcelState> {
  final ParcelsRepository _repository;

  CreateParcelNotifier(this._repository) : super(const CreateParcelState());

  Future<bool> createParcel({
    required String trackingNumber,
    CarrierType? carrier,
    String? title,
    String? description,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final parcel = await _repository.createParcel(
        trackingNumber: trackingNumber,
        carrier: carrier,
        title: title,
        description: description,
      );

      state = state.copyWith(
        isLoading: false,
        createdParcel: parcel,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to add parcel. It may already exist.',
      );
      return false;
    }
  }

  void reset() {
    state = const CreateParcelState();
  }
}

final createParcelProvider =
    StateNotifierProvider.autoDispose<CreateParcelNotifier, CreateParcelState>((ref) {
  return CreateParcelNotifier(ref.watch(parcelsRepositoryProvider));
});
