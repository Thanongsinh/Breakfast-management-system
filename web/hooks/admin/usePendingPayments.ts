'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { adminPaymentService } from '@/services/admin/payment.service';
import type { PaymentFilters } from '@/types/payment.types';
import type { ConfirmPaymentRequest, RejectPaymentRequest } from '@/services/admin/payment.service';

export function usePendingPayments(filters?: PaymentFilters) {
  return useQuery({
    queryKey: ['admin', 'payments', 'pending', filters],
    queryFn: () => adminPaymentService.getPendingPayments(filters),
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
