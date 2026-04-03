'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { buildingService } from '@/services/owner/building.service';
import type {
  CreateBuildingRequest,
  UpdateBuildingRequest,
  CreateRoomRequest,
  UpdateRoomRequest,
} from '@/types/building.types';

export function useBuildings() {
  return useQuery({
    queryKey: ['owner', 'buildings'],
    queryFn: () => buildingService.getBuildings(),
  });
}

export function useBuilding(id: number) {
  return useQuery({
    queryKey: ['owner', 'buildings', id],
    queryFn: () => buildingService.getBuildingById(id),
    enabled: !!id,
  });
}

export function useRooms(buildingId: number) {
  return useQuery({
    queryKey: ['owner', 'buildings', buildingId, 'rooms'],
    queryFn: () => buildingService.getRooms(buildingId),
    enabled: !!buildingId,
  });
}

export function useCreateBuilding() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateBuildingRequest) => buildingService.createBuilding(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['owner', 'buildings'] });
    },
  });
}

export function useUpdateBuilding() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: number; data: UpdateBuildingRequest }) =>
      buildingService.updateBuilding(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['owner', 'buildings'] });
    },
  });
}

export function useDeleteBuilding() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: number) => buildingService.deleteBuilding(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['owner', 'buildings'] });
    },
  });
}

export function useCreateRoom() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateRoomRequest) => buildingService.createRoom(data),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['owner', 'buildings', variables.buildingId] });
      queryClient.invalidateQueries({ queryKey: ['owner', 'buildings'] });
    },
  });
}

export function useUpdateRoom() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: number; data: UpdateRoomRequest }) =>
      buildingService.updateRoom(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['owner', 'buildings'] });
    },
  });
}

export function useDeleteRoom() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: number) => buildingService.deleteRoom(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['owner', 'buildings'] });
    },
  });
}
