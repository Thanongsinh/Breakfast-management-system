'use client';

import { useQuery } from '@tanstack/react-query';
import api from '@/services/api';

export interface DashboardData {
  totalBuildings: number;
  totalRooms: number;
  occupiedRooms: number;
  availableRooms: number;
  monthlyIncome: number;
  unpaidBills: number;
  pendingMaintenance: number;
  recentPayments: any[];
}

export function useDashboard() {
  return useQuery({
    queryKey: ['owner', 'dashboard'],
    queryFn: async () => {
      // TODO: implement
      const response = await api.get('/owner/dashboard');
      return response.data as DashboardData;
    },
  });
}
