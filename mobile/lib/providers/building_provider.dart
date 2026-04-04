import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/building.dart';
import '../services/building_service.dart';

final buildingServiceProvider = Provider<BuildingService>((ref) => BuildingService());

class BuildingState {
  final List<Building> buildings;
  final Building? selectedBuilding;
  final bool isLoading;
  final String? error;

  BuildingState({
    this.buildings = const [],
    this.selectedBuilding,
    this.isLoading = false,
    this.error,
  });

  BuildingState copyWith({
    List<Building>? buildings,
    Building? selectedBuilding,
    bool? isLoading,
    String? error,
  }) {
    return BuildingState(
      buildings: buildings ?? this.buildings,
      selectedBuilding: selectedBuilding ?? this.selectedBuilding,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get totalBuildings => buildings.length;
  int get totalRooms => buildings.fold(0, (sum, b) => sum + b.totalRooms);
  int get occupiedRooms => buildings.fold(0, (sum, b) => sum + b.occupiedRooms);
  double get averageOccupancy =>
      totalRooms > 0 ? (occupiedRooms / totalRooms) * 100 : 0;
}

class BuildingNotifier extends StateNotifier<BuildingState> {
  final BuildingService _buildingService;

  BuildingNotifier(this._buildingService) : super(BuildingState());

  Future<void> loadBuildings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final buildings = await _buildingService.getBuildings();
      state = state.copyWith(buildings: buildings, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadBuildingById(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final building = await _buildingService.getBuildingById(id);
      state = state.copyWith(selectedBuilding: building, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createBuilding({
    required String name,
    required String address,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _buildingService.createBuilding(
        name: name,
        address: address,
      );
      await loadBuildings();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> updateBuilding({
    required int id,
    required String name,
    required String address,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _buildingService.updateBuilding(
        id: id,
        name: name,
        address: address,
      );
      await loadBuildings();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> deleteBuilding(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _buildingService.deleteBuilding(id);
      await loadBuildings();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void clearSelectedBuilding() {
    state = state.copyWith(selectedBuilding: null);
  }
}

final buildingProvider = StateNotifierProvider<BuildingNotifier, BuildingState>((ref) {
  final buildingService = ref.watch(buildingServiceProvider);
  return BuildingNotifier(buildingService);
});
