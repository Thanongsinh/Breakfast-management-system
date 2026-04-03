import api from '@/services/api';
import type { Payment, PaymentFilters, ConfirmCashPaymentRequest, PaymentReceipt } from '@/types/payment.types';
import type { ApiResponse, PaginatedResponse } from '@/types/api.types';

export const paymentService = {
  getPayments: async (filters?: PaymentFilters): Promise<PaginatedResponse<Payment>> => {
    // TODO: implement
    const response = await api.get('/owner/payments', { params: filters });
    return response.data;
  },

  confirmCashPayment: async (data: ConfirmCashPaymentRequest): Promise<ApiResponse<Payment>> => {
    // TODO: implement
    const response = await api.post('/owner/payments/confirm-cash', data);
    return response.data;
  },

  getReceipt: async (paymentId: number): Promise<PaymentReceipt> => {
    // TODO: implement
    const response = await api.get(`/owner/payments/${paymentId}/receipt`);
    return response.data;
  },

  downloadReceipt: async (paymentId: number): Promise<Blob> => {
    // TODO: implement
    const response = await api.get(`/owner/payments/${paymentId}/receipt/pdf`, {
      responseType: 'blob',
    });
    return response.data;
  },
};
