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

export const getIncomeReport = async (month: number, year: number): Promise<IncomeReport> => {
  const { data } = await api.get<ApiResponse<IncomeReport>>('/owner/reports/income', {
    params: { month, year },
  });
  return data.data;
};

export const getUnpaidReport = async (): Promise<UnpaidReport[]> => {
  const { data } = await api.get<ApiResponse<UnpaidReport[]>>('/owner/reports/unpaid');
  return data.data;
};

export const exportExcel = async (month: number, year: number): Promise<Blob> => {
  const { data } = await api.get<Blob>('/owner/reports/export', {
    params: { month, year },
    responseType: 'blob',
  });
  return data;
};
