import '../models/building.dart';
import 'api_client.dart';

class BuildingService {
  final _apiClient = ApiClient();

  // Get all buildings for current owner
  Future<List<Building>> getBuildings() async {
    try {
      final response = await _apiClient.get('/owner/buildings');
      final data = response.data as Map<String, dynamic>;
      final buildings = (data['data'] as List)
          .map((json) => Building.fromJson(json as Map<String, dynamic>))
          .toList();
      return buildings;
    } catch (e) {
      throw Exception('Failed to fetch buildings: $e');
    }
  }

  // Get building by ID
  Future<Building> getBuildingById(int id) async {
    try {
      final response = await _apiClient.get('/owner/buildings/$id');
      final data = response.data as Map<String, dynamic>;
      return Building.fromJson(data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch building: $e');
    }
  }

  // Create new building
  Future<Building> createBuilding({
    required String name,
    required String address,
  }) async {
    try {
      final response = await _apiClient.post(
        '/owner/buildings',
        data: {
          'name': name,
          'address': address,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return Building.fromJson(data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create building: $e');
    }
  }

  // Update building
  Future<Building> updateBuilding({
    required int id,
    required String name,
    required String address,
  }) async {
    try {
      final response = await _apiClient.put(
        '/owner/buildings/$id',
        data: {
          'name': name,
          'address': address,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return Building.fromJson(data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update building: $e');
    }
  }

  // Delete building
  Future<void> deleteBuilding(int id) async {
    try {
      await _apiClient.delete('/owner/buildings/$id');
    } catch (e) {
      throw Exception('Failed to delete building: $e');
    }
  }
}
