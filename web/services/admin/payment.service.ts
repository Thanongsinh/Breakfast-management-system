import api from '@/services/api';
import type { Payment, PaymentFilters } from '@/types/payment.types';
import type { ApiResponse, PaginatedResponse } from '@/types/api.types';

export interface ConfirmPaymentRequest {
  paymentId: number;
  note?: string;
}

export interface RejectPaymentRequest {
  paymentId: number;
  reason: string;
}

export const adminPaymentService = {
  getPendingPayments: async (filters?: PaymentFilters): Promise<PaginatedResponse<Payment>> => {
    // TODO: implement
    const response = await api.get('/admin/payments/pending', { params: filters });
    return response.data;
  },

  confirmPayment: async (data: ConfirmPaymentRequest): Promise<ApiResponse<Payment>> => {
    // TODO: implement
    const response = await api.post('/admin/payments/confirm', data);
    return response.data;
  },

  rejectPayment: async (data: RejectPaymentRequest): Promise<ApiResponse<Payment>> => {
    // TODO: implement
    const response = await api.post('/admin/payments/reject', data);
    return response.data;
  },

  confirmCashPayment: async (billId: number, amount: number): Promise<ApiResponse<Payment>> => {
    // TODO: implement
    const response = await api.post('/admin/payments/confirm-cash', { billId, amount });
    return response.data;
  },
};
