import api from '@/services/api';
import type { User } from '@/types/auth.types';
import type { ApiResponse, PaginatedResponse } from '@/types/api.types';

export interface OwnerFilters {
  status?: 'active' | 'inactive';
  page?: number;
  limit?: number;
}

export interface UpdateOwnerStatusRequest {
  ownerId: number;
  status: 'active' | 'inactive';
}

export const ownerService = {
  getOwners: async (filters?: OwnerFilters): Promise<PaginatedResponse<User>> => {
    // TODO: implement
    const response = await api.get('/admin/owners', { params: filters });
    return response.data;
  },

  getOwnerById: async (id: number): Promise<User> => {
    // TODO: implement
    const response = await api.get(`/admin/owners/${id}`);
    return response.data;
  },

  updateOwnerStatus: async (data: UpdateOwnerStatusRequest): Promise<ApiResponse<User>> => {
    // TODO: implement
    const response = await api.patch(`/admin/owners/${data.ownerId}/status`, {
      status: data.status,
    });
    return response.data;
  },
};
