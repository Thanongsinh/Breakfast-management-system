import '../models/room.dart';
import 'api_client.dart';

class RoomService {
  final _apiClient = ApiClient();

  // Get rooms by building ID
  Future<List<Room>> getRoomsByBuilding(int buildingId) async {
    try {
      final response = await _apiClient.get('/owner/rooms/building/$buildingId');
      final data = response.data as Map<String, dynamic>;
      final rooms = (data['data'] as List)
          .map((json) => Room.fromJson(json as Map<String, dynamic>))
          .toList();
      return rooms;
    } catch (e) {
      throw Exception('Failed to fetch rooms: $e');
    }
  }

  // Get room by ID
  Future<Room> getRoomById(int id) async {
    try {
      final response = await _apiClient.get('/owner/rooms/$id');
      final data = response.data as Map<String, dynamic>;
      return Room.fromJson(data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch room: $e');
    }
  }

  // Create new room
  Future<Room> createRoom({
    required int buildingId,
    required String roomNumber,
    required double monthlyRate,
  }) async {
    try {
      final response = await _apiClient.post(
        '/owner/rooms',
        data: {
          'buildingId': buildingId,
          'roomNumber': roomNumber,
          'monthlyRate': monthlyRate,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return Room.fromJson(data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create room: $e');
    }
  }

  // Update room
  Future<Room> updateRoom({
    required int id,
    required String roomNumber,
    required double monthlyRate,
  }) async {
    try {
      final response = await _apiClient.put(
        '/owner/rooms/$id',
        data: {
          'roomNumber': roomNumber,
          'monthlyRate': monthlyRate,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return Room.fromJson(data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update room: $e');
    }
  }

  // Update room status
  Future<Room> updateRoomStatus({
    required int id,
    required String status,
  }) async {
    try {
      final response = await _apiClient.put(
        '/owner/rooms/$id/status',
        data: {'status': status},
      );
      final data = response.data as Map<String, dynamic>;
      return Room.fromJson(data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update room status: $e');
    }
  }

  // Delete room
  Future<void> deleteRoom(int id) async {
    try {
      await _apiClient.delete('/owner/rooms/$id');
    } catch (e) {
      throw Exception('Failed to delete room: $e');
    }
  }
}
