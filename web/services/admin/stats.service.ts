import api from '@/services/api';
import type { ApiResponse } from '@/types/api.types';

export interface MRRData {
  month: string;
  mrr: number;
  owners: number;
  buildings: number;
}

export interface DashboardStats {
  totalOwners: number;
  activeOwners: number;
  totalBuildings: number;
  totalRooms: number;
  occupiedRooms: number;
  currentMRR: number;
  pendingPayments: number;
  totalRevenue: number;
}

export const getMRR = async (months: number = 12): Promise<MRRData[]> => {
  const { data } = await api.get<ApiResponse<MRRData[]>>('/admin/stats/mrr', { params: { months } });
  return data.data;
};

export const getDashboardStats = async (): Promise<DashboardStats> => {
  const { data } = await api.get<ApiResponse<DashboardStats>>('/admin/stats/dashboard');
  return data.data;
};
