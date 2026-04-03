import api from '@/services/api';

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

export const statsService = {
  getMRR: async (months: number = 12): Promise<MRRData[]> => {
    // TODO: implement
    const response = await api.get('/admin/stats/mrr', { params: { months } });
    return response.data;
  },

  getDashboardStats: async (): Promise<DashboardStats> => {
    // TODO: implement
    const response = await api.get('/admin/stats/dashboard');
    return response.data;
  },
};
