import api from '@/services/api';
import type {
  Building,
  Room,
  CreateBuildingRequest,
  UpdateBuildingRequest,
  CreateRoomRequest,
  UpdateRoomRequest,
} from '@/types/building.types';
import type { ApiResponse, PaginatedResponse } from '@/types/api.types';

export const buildingService = {
  getBuildings: async (): Promise<Building[]> => {
    // TODO: implement
    const response = await api.get('/owner/buildings');
    return response.data;
  },

  getBuildingById: async (id: number): Promise<Building> => {
    // TODO: implement
    const response = await api.get(`/owner/buildings/${id}`);
    return response.data;
  },

  createBuilding: async (data: CreateBuildingRequest): Promise<ApiResponse<Building>> => {
    // TODO: implement
    const response = await api.post('/owner/buildings', data);
    return response.data;
  },

  updateBuilding: async (id: number, data: UpdateBuildingRequest): Promise<ApiResponse<Building>> => {
    // TODO: implement
    const response = await api.put(`/owner/buildings/${id}`, data);
    return response.data;
  },

  deleteBuilding: async (id: number): Promise<ApiResponse<void>> => {
    // TODO: implement
    const response = await api.delete(`/owner/buildings/${id}`);
    return response.data;
  },

  getRooms: async (buildingId: number): Promise<Room[]> => {
    // TODO: implement
    const response = await api.get(`/owner/buildings/${buildingId}/rooms`);
    return response.data;
  },

  createRoom: async (data: CreateRoomRequest): Promise<ApiResponse<Room>> => {
    // TODO: implement
    const response = await api.post('/owner/rooms', data);
    return response.data;
  },

  updateRoom: async (id: number, data: UpdateRoomRequest): Promise<ApiResponse<Room>> => {
    // TODO: implement
    const response = await api.put(`/owner/rooms/${id}`, data);
    return response.data;
  },

  deleteRoom: async (id: number): Promise<ApiResponse<void>> => {
    // TODO: implement
    const response = await api.delete(`/owner/rooms/${id}`);
    return response.data;
  },
};
