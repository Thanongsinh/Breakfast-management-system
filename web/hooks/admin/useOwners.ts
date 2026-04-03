'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import * as ownerService from '@/services/admin/owner.service';
import type { OwnerFilters } from '@/services/admin/owner.service';

export function useOwners(filters?: OwnerFilters) {
  return useQuery({
    queryKey: ['admin', 'owners', filters],
    queryFn: () => ownerService.getOwners(filters),
  });
}

export function useOwner(id: number) {
  return useQuery({
    queryKey: ['admin', 'owners', id],
    queryFn: () => ownerService.getOwnerById(id),
    enabled: !!id,
  });
}

export function useUpdateOwnerStatus() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ ownerId, status }: { ownerId: number; status: 'active' | 'inactive' }) =>
      ownerService.updateOwnerStatus(ownerId, status),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['admin', 'owners'] });
      queryClient.invalidateQueries({ queryKey: ['admin', 'stats'] });
    },
  });
}

export function useCreateOwner() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: { name: string; email: string; password: string; phoneNumber?: string }) =>
      ownerService.createOwner(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['admin', 'owners'] });
      queryClient.invalidateQueries({ queryKey: ['admin', 'stats'] });
    },
  });
}
