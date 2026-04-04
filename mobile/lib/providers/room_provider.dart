import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/room.dart';
import '../services/room_service.dart';

final roomServiceProvider = Provider<RoomService>((ref) => RoomService());

class RoomState {
  final List<Room> rooms;
  final Room? selectedRoom;
  final bool isLoading;
  final String? error;

  RoomState({
    this.rooms = const [],
    this.selectedRoom,
    this.isLoading = false,
    this.error,
  });

  RoomState copyWith({
    List<Room>? rooms,
    Room? selectedRoom,
    bool? isLoading,
    String? error,
  }) {
    return RoomState(
      rooms: rooms ?? this.rooms,
      selectedRoom: selectedRoom ?? this.selectedRoom,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<Room> get availableRooms => rooms.where((r) => r.isAvailable).toList();
  List<Room> get occupiedRooms => rooms.where((r) => r.isOccupied).toList();
  List<Room> get maintenanceRooms => rooms.where((r) => r.isUnderMaintenance).toList();

  int get totalRooms => rooms.length;
  int get occupiedCount => occupiedRooms.length;
  double get occupancyRate => totalRooms > 0 ? (occupiedCount / totalRooms) * 100 : 0;
}

class RoomNotifier extends StateNotifier<RoomState> {
  final RoomService _roomService;

  RoomNotifier(this._roomService) : super(RoomState());

  Future<void> loadRoomsByBuilding(int buildingId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final rooms = await _roomService.getRoomsByBuilding(buildingId);
      state = state.copyWith(rooms: rooms, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadRoomById(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final room = await _roomService.getRoomById(id);
      state = state.copyWith(selectedRoom: room, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createRoom({
    required int buildingId,
    required String roomNumber,
    required double monthlyRate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _roomService.createRoom(
        buildingId: buildingId,
        roomNumber: roomNumber,
        monthlyRate: monthlyRate,
      );
      await loadRoomsByBuilding(buildingId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> updateRoom({
    required int id,
    required int buildingId,
    required String roomNumber,
    required double monthlyRate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _roomService.updateRoom(
        id: id,
        roomNumber: roomNumber,
        monthlyRate: monthlyRate,
      );
      await loadRoomsByBuilding(buildingId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> updateRoomStatus({
    required int id,
    required int buildingId,
    required String status,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _roomService.updateRoomStatus(id: id, status: status);
      await loadRoomsByBuilding(buildingId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> deleteRoom(int id, int buildingId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _roomService.deleteRoom(id);
      await loadRoomsByBuilding(buildingId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void clearSelectedRoom() {
    state = state.copyWith(selectedRoom: null);
  }
}

final roomProvider = StateNotifierProvider<RoomNotifier, RoomState>((ref) {
  final roomService = ref.watch(roomServiceProvider);
  return RoomNotifier(roomService);
});
