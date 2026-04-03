'use client';

import { useQuery } from '@tanstack/react-query';
import api from '@/services/api';
import type { ApiResponse } from '@/types/api.types';
import type { Payment } from '@/types/payment.types';

export interface DashboardData {
  totalBuildings: number;
  totalRooms: number;
  occupiedRooms: number;
  availableRooms: number;
  maintenanceRooms: number;
  monthlyIncome: number;
  unpaidBills: number;
  unpaidAmount: number;
  overdueBills: number;
  pendingMaintenance: number;
  urgentMaintenance: number;
  recentPayments: Payment[];
}

export function useDashboard() {
  return useQuery({
    queryKey: ['owner', 'dashboard'],
    queryFn: async () => {
      const { data } = await api.get<ApiResponse<DashboardData>>('/owner/dashboard');
      return data.data;
    },
  });
}

export function useIncomeReport(month: number, year: number) {
  return useQuery({
    queryKey: ['owner', 'reports', 'income', month, year],
    queryFn: async () => {
      const { data } = await api.get<ApiResponse<any>>('/owner/reports/income', {
        params: { month, year },
      });
      return data.data;
    },
    enabled: !!month && !!year,
  });
}
