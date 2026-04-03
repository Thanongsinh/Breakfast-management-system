import api from '@/services/api';
import type {
  Tenant,
  Contract,
  CreateTenantRequest,
  UpdateTenantRequest,
  CreateContractRequest,
  TerminateContractRequest,
} from '@/types/tenant.types';
import type { ApiResponse } from '@/types/api.types';

export const getTenants = async (page = 1, limit = 50): Promise<Tenant[]> => {
  const { data } = await api.get<ApiResponse<Tenant[]>>('/owner/tenants', {
    params: { page, limit },
  });
  return data.data;
};

export const getTenantById = async (id: number): Promise<Tenant> => {
  const { data } = await api.get<ApiResponse<Tenant>>(`/owner/tenants/${id}`);
  return data.data;
};

export const createTenant = async (tenantData: CreateTenantRequest): Promise<Tenant> => {
  const { data } = await api.post<ApiResponse<Tenant>>('/owner/tenants', tenantData);
  return data.data;
};

export const updateTenant = async (id: number, tenantData: UpdateTenantRequest): Promise<Tenant> => {
  const { data } = await api.put<ApiResponse<Tenant>>(`/owner/tenants/${id}`, tenantData);
  return data.data;
};

export const deleteTenant = async (id: number): Promise<void> => {
  await api.delete(`/owner/tenants/${id}`);
};

export const getContracts = async (tenantId?: number): Promise<Contract[]> => {
  const url = tenantId ? `/owner/contracts?tenantId=${tenantId}` : '/owner/contracts';
  const { data } = await api.get<ApiResponse<Contract[]>>(url);
  return data.data;
};

export const createContract = async (contractData: CreateContractRequest): Promise<Contract> => {
  const { data } = await api.post<ApiResponse<Contract>>('/owner/contracts', contractData);
  return data.data;
};

export const terminateContract = async (
  id: number,
  terminationData: TerminateContractRequest
): Promise<Contract> => {
  const { data } = await api.post<ApiResponse<Contract>>(`/owner/contracts/${id}/terminate`, terminationData);
  return data.data;
};
