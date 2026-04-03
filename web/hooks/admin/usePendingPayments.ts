'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import * as adminPaymentService from '@/services/admin/payment.service';
import type { PaymentFilters, ConfirmCashPaymentRequest } from '@/types/payment.types';
import type { ConfirmPaymentRequest, RejectPaymentRequest } from '@/services/admin/payment.service';

export function usePendingPayments(filters?: PaymentFilters) {
  return useQuery({
    queryKey: ['admin', 'payments', 'pending', filters],
    queryFn: () => adminPaymentService.getPendingPayments(filters),
  });
}

export function useAllPayments(filters?: PaymentFilters) {
  return useQuery({
    queryKey: ['admin', 'payments', filters],
    queryFn: () => adminPaymentService.getAllPayments(filters),
  });
}

export function useConfirmPayment() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: ConfirmPaymentRequest) => adminPaymentService.confirmPayment(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['admin', 'payments'] });
      queryClient.invalidateQueries({ queryKey: ['admin', 'stats'] });
    },
  });
}

export function useRejectPayment() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: RejectPaymentRequest) => adminPaymentService.rejectPayment(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['admin', 'payments'] });
    },
  });
}

export function useConfirmCashPayment() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: ConfirmCashPaymentRequest) => adminPaymentService.confirmCashPayment(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['admin', 'payments'] });
      queryClient.invalidateQueries({ queryKey: ['admin', 'stats'] });
    },
  });
}
