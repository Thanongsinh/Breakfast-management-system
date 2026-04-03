'use client';

import { useQuery } from '@tanstack/react-query';
import { statsService } from '@/services/admin/stats.service';

export function useMRR(months: number = 12) {
  return useQuery({
    queryKey: ['admin', 'stats', 'mrr', months],
    queryFn: () => statsService.getMRR(months),
  });
}

export function useDashboardStats() {
  return useQuery({
    queryKey: ['admin', 'stats', 'dashboard'],
    queryFn: () => statsService.getDashboardStats(),
  });
}
