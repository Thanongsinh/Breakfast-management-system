import '../models/maintenance_request.dart';
import 'api_client.dart';

class MaintenanceService {
  final _apiClient = ApiClient();

  Future<List<MaintenanceRequest>> getMaintenanceRequests({
    String? status,
    String? priority,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (priority != null) queryParams['priority'] = priority;
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiClient.get(
        '/maintenance',
        queryParameters: queryParams,
      );

      final data = response.data as Map<String, dynamic>;
      final requestsList = data['requests'] as List;
      return requestsList
          .map((item) => MaintenanceRequest.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<MaintenanceRequest> getMaintenanceRequestById(String requestId) async {
    try {
      final response = await _apiClient.get('/maintenance/$requestId');
      final data = response.data as Map<String, dynamic>;
      return MaintenanceRequest.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<MaintenanceRequest> createMaintenanceRequest({
    required String title,
    required String description,
    required String category,
    required String priority,
    List<String>? images,
  }) async {
    try {
      final response = await _apiClient.post(
        '/maintenance',
        data: {
          'title': title,
          'description': description,
          'category': category,
          'priority': priority,
          'images': images ?? [],
        },
      );

      final data = response.data as Map<String, dynamic>;
      return MaintenanceRequest.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<MaintenanceRequest> updateMaintenanceRequest({
    required String requestId,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? status,
    DateTime? scheduledDate,
    String? completionNotes,
  }) async {
    try {
      final response = await _apiClient.put(
        '/maintenance/$requestId',
        data: {
          'title': title,
          'description': description,
          'category': category,
          'priority': priority,
          'status': status,
          'scheduledDate': scheduledDate?.toIso8601String(),
          'completionNotes': completionNotes,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return MaintenanceRequest.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMaintenanceRequest(String requestId) async {
    try {
      await _apiClient.delete('/maintenance/$requestId');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMaintenanceStats() async {
    try {
      final response = await _apiClient.get('/maintenance/stats');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
