'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import * as paymentService from '@/services/owner/payment.service';
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

export function useDownloadReceipt() {
  return useMutation({
    mutationFn: async (paymentId: number) => {
      const blob = await paymentService.downloadReceipt(paymentId);
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `receipt-${paymentId}.pdf`;
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(url);
      document.body.removeChild(a);
    },
  });
}
