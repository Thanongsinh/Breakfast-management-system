import api from '@/services/api';
import type { Payment, PaymentFilters, ConfirmCashPaymentRequest, PaymentReceipt } from '@/types/payment.types';
import type { ApiResponse, PaginatedResponse } from '@/types/api.types';

export const getPayments = async (filters?: PaymentFilters, page = 1, limit = 20): Promise<PaginatedResponse<Payment>> => {
  const { data } = await api.get<PaginatedResponse<Payment>>('/owner/payments', {
    params: { ...filters, page, limit },
  });
  return data;
};

export const confirmCashPayment = async (paymentData: ConfirmCashPaymentRequest): Promise<Payment> => {
  const { data } = await api.post<ApiResponse<Payment>>('/owner/payments/confirm-cash', paymentData);
  return data.data;
};

export const getReceipt = async (paymentId: number): Promise<PaymentReceipt> => {
  const { data } = await api.get<ApiResponse<PaymentReceipt>>(`/owner/payments/${paymentId}/receipt`);
  return data.data;
};

export const downloadReceipt = async (paymentId: number): Promise<Blob> => {
  const { data } = await api.get<Blob>(`/owner/payments/${paymentId}/receipt/pdf`, {
    responseType: 'blob',
  });
  return data;
};
