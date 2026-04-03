import api from '@/services/api';
import type {
  Tenant,
  Contract,
  CreateTenantRequest,
  UpdateTenantRequest,
  CreateContractRequest,
  TerminateContractRequest,
} from '@/types/tenant.types';
import type { ApiResponse, PaginatedResponse } from '@/types/api.types';

export const tenantService = {
  getTenants: async (): Promise<Tenant[]> => {
    // TODO: implement
    const response = await api.get('/owner/tenants');
    return response.data;
  },

  getTenantById: async (id: number): Promise<Tenant> => {
    // TODO: implement
    const response = await api.get(`/owner/tenants/${id}`);
    return response.data;
  },

  createTenant: async (data: CreateTenantRequest): Promise<ApiResponse<Tenant>> => {
    // TODO: implement
    const response = await api.post('/owner/tenants', data);
    return response.data;
  },

  updateTenant: async (id: number, data: UpdateTenantRequest): Promise<ApiResponse<Tenant>> => {
    // TODO: implement
    const response = await api.put(`/owner/tenants/${id}`, data);
    return response.data;
  },

  deleteTenant: async (id: number): Promise<ApiResponse<void>> => {
    // TODO: implement
    const response = await api.delete(`/owner/tenants/${id}`);
    return response.data;
  },

  getContracts: async (tenantId?: number): Promise<Contract[]> => {
    // TODO: implement
    const url = tenantId ? `/owner/contracts?tenantId=${tenantId}` : '/owner/contracts';
    const response = await api.get(url);
    return response.data;
  },

  createContract: async (data: CreateContractRequest): Promise<ApiResponse<Contract>> => {
    // TODO: implement
    const response = await api.post('/owner/contracts', data);
    return response.data;
  },

  terminateContract: async (
    id: number,
    data: TerminateContractRequest
  ): Promise<ApiResponse<Contract>> => {
    // TODO: implement
    const response = await api.post(`/owner/contracts/${id}/terminate`, data);
    return response.data;
  },
};
