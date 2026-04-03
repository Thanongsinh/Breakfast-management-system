import api from '@/services/api';
import type {
  MaintenanceRequest,
  CreateMaintenanceRequest as CreateMaintenanceRequestType,
  UpdateMaintenanceRequest,
  MaintenanceFilters,
} from '@/types/maintenance.types';
import type { ApiResponse, PaginatedResponse } from '@/types/api.types';

export const getMaintenance = async (filters?: MaintenanceFilters, page = 1, limit = 20): Promise<PaginatedResponse<MaintenanceRequest>> => {
  const { data } = await api.get<PaginatedResponse<MaintenanceRequest>>('/owner/maintenance', {
    params: { ...filters, page, limit },
  });
  return data;
};

export const getMaintenanceById = async (id: number): Promise<MaintenanceRequest> => {
  const { data } = await api.get<ApiResponse<MaintenanceRequest>>(`/owner/maintenance/${id}`);
  return data.data;
};

export const createMaintenance = async (maintenanceData: CreateMaintenanceRequestType): Promise<MaintenanceRequest> => {
  const { data } = await api.post<ApiResponse<MaintenanceRequest>>('/owner/maintenance', maintenanceData);
  return data.data;
};

export const updateStatus = async (
  id: number,
  updateData: UpdateMaintenanceRequest
): Promise<MaintenanceRequest> => {
  const { data } = await api.patch<ApiResponse<MaintenanceRequest>>(`/owner/maintenance/${id}`, updateData);
  return data.data;
};

export const uploadImages = async (id: number, images: File[]): Promise<MaintenanceRequest> => {
  const formData = new FormData();
  images.forEach((image) => {
    formData.append('images', image);
  });
  const { data } = await api.post<ApiResponse<MaintenanceRequest>>(`/owner/maintenance/${id}/images`, formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
  });
  return data.data;
};

export const deleteMaintenance = async (id: number): Promise<void> => {
  await api.delete(`/owner/maintenance/${id}`);
};
