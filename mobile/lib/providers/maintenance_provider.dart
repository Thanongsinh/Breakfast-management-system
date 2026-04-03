import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/maintenance_request.dart';
import '../services/maintenance_service.dart';

final maintenanceServiceProvider = Provider<MaintenanceService>((ref) => MaintenanceService());

class MaintenanceState {
  final List<MaintenanceRequest> requests;
  final MaintenanceRequest? selectedRequest;
  final Map<String, dynamic>? stats;
  final bool isLoading;
  final String? error;

  MaintenanceState({
    this.requests = const [],
    this.selectedRequest,
    this.stats,
    this.isLoading = false,
    this.error,
  });

  MaintenanceState copyWith({
    List<MaintenanceRequest>? requests,
    MaintenanceRequest? selectedRequest,
    Map<String, dynamic>? stats,
    bool? isLoading,
    String? error,
  }) {
    return MaintenanceState(
      requests: requests ?? this.requests,
      selectedRequest: selectedRequest ?? this.selectedRequest,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<MaintenanceRequest> get pendingRequests =>
      requests.where((r) => r.isPending).toList();
  List<MaintenanceRequest> get inProgressRequests =>
      requests.where((r) => r.isInProgress).toList();
  List<MaintenanceRequest> get completedRequests =>
      requests.where((r) => r.isCompleted).toList();
}

class MaintenanceNotifier extends StateNotifier<MaintenanceState> {
  final MaintenanceService _maintenanceService;

  MaintenanceNotifier(this._maintenanceService) : super(MaintenanceState());

  Future<void> loadRequests({String? status, String? priority}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final requests = await _maintenanceService.getMaintenanceRequests(
        status: status,
        priority: priority,
      );
      state = state.copyWith(requests: requests, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadRequestById(String requestId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final request = await _maintenanceService.getMaintenanceRequestById(requestId);
      state = state.copyWith(selectedRequest: request, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadStats() async {
    try {
      final stats = await _maintenanceService.getMaintenanceStats();
      state = state.copyWith(stats: stats);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> createRequest({
    required String title,
    required String description,
    required String category,
    required String priority,
    List<String>? images,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _maintenanceService.createMaintenanceRequest(
        title: title,
        description: description,
        category: category,
        priority: priority,
        images: images,
      );
      await loadRequests();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> updateRequest({
    required String requestId,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? status,
    DateTime? scheduledDate,
    String? completionNotes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _maintenanceService.updateMaintenanceRequest(
        requestId: requestId,
        title: title,
        description: description,
        category: category,
        priority: priority,
        status: status,
        scheduledDate: scheduledDate,
        completionNotes: completionNotes,
      );
      await loadRequests();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> deleteRequest(String requestId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _maintenanceService.deleteMaintenanceRequest(requestId);
      await loadRequests();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void clearSelectedRequest() {
    state = state.copyWith(selectedRequest: null);
  }
}

final maintenanceProvider = StateNotifierProvider<MaintenanceNotifier, MaintenanceState>((ref) {
  final maintenanceService = ref.watch(maintenanceServiceProvider);
  return MaintenanceNotifier(maintenanceService);
});
