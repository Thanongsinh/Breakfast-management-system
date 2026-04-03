import api from '@/services/api';
import type {
  Building,
  Room,
  CreateBuildingRequest,
  UpdateBuildingRequest,
  CreateRoomRequest,
  UpdateRoomRequest,
} from '@/types/building.types';
import type { ApiResponse } from '@/types/api.types';

export const getBuildings = async (): Promise<Building[]> => {
  const { data } = await api.get<ApiResponse<Building[]>>('/owner/buildings');
  return data.data;
};

export const getBuildingById = async (id: number): Promise<Building> => {
  const { data } = await api.get<ApiResponse<Building>>(`/owner/buildings/${id}`);
  return data.data;
};

export const createBuilding = async (buildingData: CreateBuildingRequest): Promise<Building> => {
  const { data } = await api.post<ApiResponse<Building>>('/owner/buildings', buildingData);
  return data.data;
};

export const updateBuilding = async (id: number, buildingData: UpdateBuildingRequest): Promise<Building> => {
  const { data } = await api.put<ApiResponse<Building>>(`/owner/buildings/${id}`, buildingData);
  return data.data;
};

export const deleteBuilding = async (id: number): Promise<void> => {
  await api.delete(`/owner/buildings/${id}`);
};

export const getRooms = async (buildingId: number): Promise<Room[]> => {
  const { data } = await api.get<ApiResponse<Room[]>>(`/owner/buildings/${buildingId}/rooms`);
  return data.data;
};

export const createRoom = async (roomData: CreateRoomRequest): Promise<Room> => {
  const { data } = await api.post<ApiResponse<Room>>('/owner/rooms', roomData);
  return data.data;
};

export const updateRoom = async (id: number, roomData: UpdateRoomRequest): Promise<Room> => {
  const { data } = await api.put<ApiResponse<Room>>(`/owner/rooms/${id}`, roomData);
  return data.data;
};

export const deleteRoom = async (id: number): Promise<void> => {
  await api.delete(`/owner/rooms/${id}`);
};
