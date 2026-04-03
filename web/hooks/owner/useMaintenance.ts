'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import * as maintenanceService from '@/services/owner/maintenance.service';
import type {
  CreateMaintenanceRequest as CreateMaintenanceRequestType,
  UpdateMaintenanceRequest,
  MaintenanceFilters,
} from '@/types/maintenance.types';

export function useMaintenance(filters?: MaintenanceFilters) {
  return useQuery({
    queryKey: ['owner', 'maintenance', filters],
    queryFn: () => maintenanceService.getMaintenance(filters),
  });
}

export function useMaintenanceRequest(id: number) {
  return useQuery({
    queryKey: ['owner', 'maintenance', id],
    queryFn: () => maintenanceService.getMaintenanceById(id),
    enabled: !!id,
  });
}

export function useCreateMaintenance() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateMaintenanceRequestType) => maintenanceService.createMaintenance(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['owner', 'maintenance'] });
      queryClient.invalidateQueries({ queryKey: ['owner', 'dashboard'] });
    },
  });
}

export function useUpdateMaintenanceStatus() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: number; data: UpdateMaintenanceRequest }) =>
      maintenanceService.updateStatus(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['owner', 'maintenance'] });
      queryClient.invalidateQueries({ queryKey: ['owner', 'dashboard'] });
    },
  });
}

export function useUploadMaintenanceImages() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, images }: { id: number; images: File[] }) =>
      maintenanceService.uploadImages(id, images),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['owner', 'maintenance'] });
    },
  });
}

export function useDeleteMaintenance() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: number) => maintenanceService.deleteMaintenance(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['owner', 'maintenance'] });
    },
  });
}
