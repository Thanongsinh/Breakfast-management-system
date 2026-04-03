import api from '@/services/api';
import type { Bill, BillFilters, GenerateBillsRequest } from '@/types/bill.types';
import type { ApiResponse, PaginatedResponse } from '@/types/api.types';

export const billService = {
  getBills: async (filters?: BillFilters): Promise<PaginatedResponse<Bill>> => {
    // TODO: implement
    const response = await api.get('/owner/bills', { params: filters });
    return response.data;
  },

  getBillById: async (id: number): Promise<Bill> => {
    // TODO: implement
    const response = await api.get(`/owner/bills/${id}`);
    return response.data;
  },

  generateBills: async (data: GenerateBillsRequest): Promise<ApiResponse<{ generated: number }>> => {
    // TODO: implement
    const response = await api.post('/owner/bills/generate', data);
    return response.data;
  },

  deleteBill: async (id: number): Promise<ApiResponse<void>> => {
    // TODO: implement
    const response = await api.delete(`/owner/bills/${id}`);
    return response.data;
  },
};
