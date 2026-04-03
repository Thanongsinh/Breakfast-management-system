import api from '@/services/api';
import type { Bill, BillFilters, GenerateBillsRequest } from '@/types/bill.types';
import type { ApiResponse, PaginatedResponse } from '@/types/api.types';

export const getBills = async (filters?: BillFilters, page = 1, limit = 20): Promise<PaginatedResponse<Bill>> => {
  const { data } = await api.get<PaginatedResponse<Bill>>('/owner/bills', {
    params: { ...filters, page, limit },
  });
  return data;
};

export const getBillById = async (id: number): Promise<Bill> => {
  const { data } = await api.get<ApiResponse<Bill>>(`/owner/bills/${id}`);
  return data.data;
};

export const generateBills = async (month: number, year: number): Promise<ApiResponse<{ generated: number }>> => {
  const { data } = await api.post<ApiResponse<{ generated: number }>>('/owner/bills/generate', { month, year });
  return data;
};

export const deleteBill = async (id: number): Promise<ApiResponse<void>> => {
  const { data } = await api.delete<ApiResponse<void>>(`/owner/bills/${id}`);
  return data;
};
