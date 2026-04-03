import api from '@/services/api';
import type {
  MaintenanceRequest,
  CreateMaintenanceRequest,
  UpdateMaintenanceRequest,
  MaintenanceFilters,
} from '@/types/maintenance.types';
import type { ApiResponse, PaginatedResponse } from '@/types/api.types';

export const maintenanceService = {
  getMaintenance: async (filters?: MaintenanceFilters): Promise<PaginatedResponse<MaintenanceRequest>> => {
    // TODO: implement
    const response = await api.get('/owner/maintenance', { params: filters });
    return response.data;
  },

  getMaintenanceById: async (id: number): Promise<MaintenanceRequest> => {
    // TODO: implement
    const response = await api.get(`/owner/maintenance/${id}`);
    return response.data;
  },

  createMaintenance: async (data: CreateMaintenanceRequest): Promise<ApiResponse<MaintenanceRequest>> => {
    // TODO: implement
    const response = await api.post('/owner/maintenance', data);
    return response.data;
  },

  updateStatus: async (
    id: number,
    data: UpdateMaintenanceRequest
  ): Promise<ApiResponse<MaintenanceRequest>> => {
    // TODO: implement
    const response = await api.patch(`/owner/maintenance/${id}`, data);
    return response.data;
  },

  deleteMaintenance: async (id: number): Promise<ApiResponse<void>> => {
    // TODO: implement
    const response = await api.delete(`/owner/maintenance/${id}`);
    return response.data;
  },
};
