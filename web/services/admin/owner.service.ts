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

export const getOwners = async (filters?: OwnerFilters, page = 1, limit = 20): Promise<PaginatedResponse<User>> => {
  const { data } = await api.get<PaginatedResponse<User>>('/admin/owners', {
    params: { ...filters, page, limit },
  });
  return data;
};

export const getOwnerById = async (id: number): Promise<User> => {
  const { data } = await api.get<ApiResponse<User>>(`/admin/owners/${id}`);
  return data.data;
};

export const updateOwnerStatus = async (ownerId: number, status: 'active' | 'inactive'): Promise<User> => {
  const { data } = await api.patch<ApiResponse<User>>(`/admin/owners/${ownerId}/status`, {
    status,
  });
  return data.data;
};

export const createOwner = async (ownerData: { name: string; email: string; password: string; phoneNumber?: string }): Promise<User> => {
  const { data } = await api.post<ApiResponse<User>>('/admin/owners', ownerData);
  return data.data;
};
