'use client';

import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { formatCurrency } from '@/lib/utils';
import type { ConfirmCashPaymentRequest } from '@/types/payment.types';
import type { Bill } from '@/types/bill.types';

interface ConfirmCashModalProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: (data: ConfirmCashPaymentRequest) => void;
  bill: Bill | null;
}

interface FormData {
  amount: number;
  paidDate: string;
  note: string;
}

export function ConfirmCashModal({ isOpen, onClose, onConfirm, bill }: ConfirmCashModalProps) {
  const { register, handleSubmit, reset, formState: { errors } } = useForm<FormData>({
    defaultValues: {
      amount: bill?.amount || 0,
      paidDate: new Date().toISOString().split('T')[0],
      note: '',
    },
  });

  if (!isOpen || !bill) return null;

  const onSubmit = (data: FormData) => {
    onConfirm({
      billId: bill.id,
      amount: data.amount,
      paidDate: data.paidDate,
      note: data.note,
    });
    reset();
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
      <div className="bg-white rounded-lg shadow-xl max-w-md w-full mx-4">
        <div className="p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Confirm Cash Payment</h3>

          <div className="mb-4 p-3 bg-gray-50 rounded">
            <p className="text-sm text-gray-600">Room: {bill.roomNumber}</p>
            <p className="text-sm text-gray-600">Tenant: {bill.tenantName || 'N/A'}</p>
            <p className="text-sm font-semibold text-gray-900 mt-1">
              Bill Amount: {formatCurrency(bill.amount)}
            </p>
          </div>

          <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Amount Received
              </label>
              <input
                type="number"
                step="0.01"
                {...register('amount', { required: 'Amount is required', min: 0 })}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              {errors.amount && (
                <p className="text-sm text-red-600 mt-1">{errors.amount.message}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Payment Date
              </label>
              <input
                type="date"
                {...register('paidDate', { required: 'Date is required' })}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              {errors.paidDate && (
                <p className="text-sm text-red-600 mt-1">{errors.paidDate.message}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Note (Optional)
              </label>
              <textarea
                {...register('note')}
                rows={3}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>

            <div className="flex justify-end gap-3 mt-6">
              <button
                type="button"
                onClick={onClose}
                className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                type="submit"
                className="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700"
              >
                Confirm Payment
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}
