'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { paymentService } from '@/services/owner/payment.service';
import type { PaymentFilters, ConfirmCashPaymentRequest } from '@/types/payment.types';

export function usePayments(filters?: PaymentFilters) {
  return useQuery({
    queryKey: ['owner', 'payments', filters],
    queryFn: () => paymentService.getPayments(filters),
  });
}

export function useConfirmCashPayment() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: ConfirmCashPaymentRequest) => paymentService.confirmCashPayment(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['owner', 'payments'] });
      queryClient.invalidateQueries({ queryKey: ['owner', 'bills'] });
      queryClient.invalidateQueries({ queryKey: ['owner', 'dashboard'] });
    },
  });
}

export function usePaymentReceipt(paymentId: number) {
  return useQuery({
    queryKey: ['owner', 'payments', paymentId, 'receipt'],
    queryFn: () => paymentService.getReceipt(paymentId),
    enabled: !!paymentId,
  });
}
