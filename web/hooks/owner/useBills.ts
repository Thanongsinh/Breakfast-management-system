'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import * as billService from '@/services/owner/bill.service';
import type { BillFilters } from '@/types/bill.types';

export function useBills(filters?: BillFilters) {
  return useQuery({
    queryKey: ['owner', 'bills', filters],
    queryFn: () => billService.getBills(filters),
  });
}

export function useBill(id: number) {
  return useQuery({
    queryKey: ['owner', 'bills', id],
    queryFn: () => billService.getBillById(id),
    enabled: !!id,
  });
}

export function useGenerateBills() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ month, year }: { month: number; year: number }) =>
      billService.generateBills(month, year),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['owner', 'bills'] });
      queryClient.invalidateQueries({ queryKey: ['owner', 'dashboard'] });
    },
  });
}

export function useDeleteBill() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: number) => billService.deleteBill(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['owner', 'bills'] });
      queryClient.invalidateQueries({ queryKey: ['owner', 'dashboard'] });
    },
  });
}
