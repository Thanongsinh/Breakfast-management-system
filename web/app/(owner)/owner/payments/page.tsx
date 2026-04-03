'use client';

import { useState } from 'react';
import { usePayments, useConfirmCashPayment } from '@/hooks/owner/usePayments';
import { useBills } from '@/hooks/owner/useBills';
import { DataTable } from '@/components/shared/DataTable';
import { StatusBadge } from '@/components/shared/StatusBadge';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { ConfirmCashModal } from '@/components/owner/ConfirmCashModal';
import { formatCurrency, formatDate } from '@/lib/utils';
import type { Bill } from '@/types/bill.types';
import type { ConfirmCashPaymentRequest } from '@/types/payment.types';

export default function PaymentsPage() {
  const [showCashModal, setShowCashModal] = useState(false);
  const [selectedBill, setSelectedBill] = useState<Bill | null>(null);

  const { data: paymentsData, isLoading: paymentsLoading } = usePayments();
  const { data: billsData } = useBills({ status: 'unpaid' });
  const confirmCash = useConfirmCashPayment();

  const handleConfirmCash = (data: ConfirmCashPaymentRequest) => {
    confirmCash.mutate(data);
  };

  if (paymentsLoading) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  const columns = [
    {
      key: 'bill',
      label: 'Bill Info',
      render: (payment: any) => (
        <div>
          <p className="font-medium">{payment.bill?.roomNumber}</p>
          <p className="text-xs text-gray-500">{payment.bill?.buildingName}</p>
        </div>
      ),
    },
    {
      key: 'amount',
      label: 'Amount',
      render: (payment: any) => (
        <span className="font-semibold">{formatCurrency(payment.amount)}</span>
      ),
    },
    {
      key: 'method',
      label: 'Method',
      render: (payment: any) => (
        <span className="capitalize">{payment.method.replace('_', ' ')}</span>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      render: (payment: any) => <StatusBadge status={payment.status} />,
    },
    {
      key: 'createdAt',
      label: 'Date',
      render: (payment: any) => formatDate(payment.createdAt),
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Payments</h1>
          <p className="text-gray-600">Track and manage payment records</p>
        </div>
      </div>

      {billsData && billsData.items.length > 0 && (
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Unpaid Bills</h2>
          <div className="space-y-2">
            {billsData.items.slice(0, 5).map((bill) => (
              <div
                key={bill.id}
                className="flex justify-between items-center py-2 border-b"
              >
                <div>
                  <p className="font-medium text-gray-900">
                    {bill.roomNumber} - {bill.buildingName}
                  </p>
                  <p className="text-sm text-gray-500">
                    Due: {formatDate(bill.dueDate)}
                  </p>
                </div>
                <div className="flex items-center gap-3">
                  <p className="font-semibold text-gray-900">
                    {formatCurrency(bill.amount)}
                  </p>
                  <button
                    onClick={() => {
                      setSelectedBill(bill);
                      setShowCashModal(true);
                    }}
                    className="px-3 py-1 text-sm bg-green-600 text-white rounded hover:bg-green-700"
                  >
                    Confirm Cash
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Payment History</h2>
        <DataTable data={paymentsData?.items || []} columns={columns} />
      </div>

      <ConfirmCashModal
        isOpen={showCashModal}
        onClose={() => {
          setShowCashModal(false);
          setSelectedBill(null);
        }}
        onConfirm={handleConfirmCash}
        bill={selectedBill}
      />
    </div>
  );
}
