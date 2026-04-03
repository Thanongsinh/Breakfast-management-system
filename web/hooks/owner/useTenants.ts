'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { tenantService } from '@/services/owner/tenant.service';
import type {
  CreateTenantRequest,
  UpdateTenantRequest,
  CreateContractRequest,
  TerminateContractRequest,
} from '@/types/tenant.types';

export function useTenants() {
  return useQuery({
    queryKey: ['owner', 'tenants'],
    queryFn: () => tenantService.getTenants(),
  });
}

export function useTenant(id: number) {
  return useQuery({
    queryKey: ['owner', 'tenants', id],
    queryFn: () => tenantService.getTenantById(id),
    enabled: !!id,
  });
}

export function useContracts(tenantId?: number) {
  return useQuery({
    queryKey: ['owner', 'contracts', tenantId],
    queryFn: () => tenantService.getContracts(tenantId),
  });
}

export function useCreateTenant() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateTenantRequest) => tenantService.createTenant(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['owner', 'tenants'] });
    },
  });
}

export function useUpdateTenant() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: number; data: UpdateTenantRequest }) =>
      tenantService.updateTenant(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['owner', 'tenants'] });
    },
  });
}

export function useDeleteTenant() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: number) => tenantService.deleteTenant(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['owner', 'tenants'] });
    },
  });
}

export function useCreateContract() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateContractRequest) => tenantService.createContract(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['owner', 'contracts'] });
      queryClient.invalidateQueries({ queryKey: ['owner', 'tenants'] });
      queryClient.invalidateQueries({ queryKey: ['owner', 'buildings'] });
    },
  });
}

export function useTerminateContract() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: number; data: TerminateContractRequest }) =>
      tenantService.terminateContract(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['owner', 'contracts'] });
      queryClient.invalidateQueries({ queryKey: ['owner', 'buildings'] });
    },
  });
}
