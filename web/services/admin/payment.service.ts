import api from '@/services/api';
import type { Payment, PaymentFilters, ConfirmCashPaymentRequest } from '@/types/payment.types';
import type { ApiResponse, PaginatedResponse } from '@/types/api.types';

export interface ConfirmPaymentRequest {
  paymentId: number;
  note?: string;
}

export interface RejectPaymentRequest {
  paymentId: number;
  reason: string;
}

export const getPendingPayments = async (filters?: PaymentFilters, page = 1, limit = 20): Promise<PaginatedResponse<Payment>> => {
  const { data } = await api.get<PaginatedResponse<Payment>>('/admin/payments/pending', {
    params: { ...filters, page, limit },
  });
  return data;
};

export const getAllPayments = async (filters?: PaymentFilters, page = 1, limit = 20): Promise<PaginatedResponse<Payment>> => {
  const { data } = await api.get<PaginatedResponse<Payment>>('/admin/payments', {
    params: { ...filters, page, limit },
  });
  return data;
};

export const confirmPayment = async (confirmData: ConfirmPaymentRequest): Promise<Payment> => {
  const { data } = await api.post<ApiResponse<Payment>>('/admin/payments/confirm', confirmData);
  return data.data;
};

export const rejectPayment = async (rejectData: RejectPaymentRequest): Promise<Payment> => {
  const { data } = await api.post<ApiResponse<Payment>>('/admin/payments/reject', rejectData);
  return data.data;
};

export const confirmCashPayment = async (paymentData: ConfirmCashPaymentRequest): Promise<Payment> => {
  const { data } = await api.post<ApiResponse<Payment>>('/admin/payments/confirm-cash', paymentData);
  return data.data;
};
