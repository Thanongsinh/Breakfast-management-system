'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { ownerService } from '@/services/admin/owner.service';
import type { OwnerFilters, UpdateOwnerStatusRequest } from '@/services/admin/owner.service';

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
    mutationFn: (data: UpdateOwnerStatusRequest) => ownerService.updateOwnerStatus(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['admin', 'owners'] });
      queryClient.invalidateQueries({ queryKey: ['admin', 'stats'] });
    },
  });
}
