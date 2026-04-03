import api from '@/services/api';
import type { ApiResponse } from '@/types/api.types';

export interface IncomeReport {
  month: number;
  year: number;
  totalIncome: number;
  totalExpenses: number;
  netIncome: number;
  buildingBreakdown: {
    buildingId: number;
    buildingName: string;
    income: number;
  }[];
}

export interface UnpaidReport {
  buildingId: number;
  buildingName: string;
  unpaidBills: number;
  totalUnpaid: number;
  overdueCount: number;
}

export const reportService = {
  getIncomeReport: async (month: number, year: number): Promise<IncomeReport> => {
    // TODO: implement
    const response = await api.get('/owner/reports/income', {
      params: { month, year },
    });
    return response.data;
  },

  getUnpaidReport: async (): Promise<UnpaidReport[]> => {
    // TODO: implement
    const response = await api.get('/owner/reports/unpaid');
    return response.data;
  },

  exportToExcel: async (month: number, year: number): Promise<Blob> => {
    // TODO: implement
    const response = await api.get('/owner/reports/export', {
      params: { month, year },
      responseType: 'blob',
    });
    return response.data;
  },
};
