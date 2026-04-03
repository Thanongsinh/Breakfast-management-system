'use client';

import { useState } from 'react';
import { usePendingPayments, useConfirmPayment, useRejectPayment } from '@/hooks/admin/usePendingPayments';
import { PendingPaymentsTable } from '@/components/admin/PendingPaymentsTable';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { ConfirmDialog } from '@/components/shared/ConfirmDialog';
import type { Payment } from '@/types/payment.types';

export default function AdminPaymentsPage() {
  const [selectedPayment, setSelectedPayment] = useState<Payment | null>(null);
  const [showConfirmDialog, setShowConfirmDialog] = useState(false);
  const [showRejectDialog, setShowRejectDialog] = useState(false);

  const { data, isLoading } = usePendingPayments({ status: 'pending' });
  const confirmPayment = useConfirmPayment();
  const rejectPayment = useRejectPayment();

  const handleConfirm = () => {
    if (selectedPayment) {
      confirmPayment.mutate({ paymentId: selectedPayment.id });
      setSelectedPayment(null);
    }
  };

  const handleReject = () => {
    if (selectedPayment) {
      rejectPayment.mutate({
        paymentId: selectedPayment.id,
        reason: 'Invalid payment proof',
      });
      setSelectedPayment(null);
    }
  };

  if (isLoading) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Pending Payments</h1>
        <p className="text-gray-600">Review and confirm payment submissions</p>
      </div>

      <div className="bg-white rounded-lg shadow p-6">
        <PendingPaymentsTable
          payments={data?.items || []}
          onPaymentClick={(payment) => setSelectedPayment(payment)}
        />

        {selectedPayment && (
          <div className="mt-6 p-4 bg-gray-50 rounded-lg">
            <h3 className="text-lg font-semibold text-gray-900 mb-3">Payment Details</h3>
            <div className="space-y-2">
              <p className="text-sm text-gray-600">
                Room: {selectedPayment.bill?.roomNumber} - {selectedPayment.bill?.buildingName}
              </p>
              <p className="text-sm text-gray-600">
                Tenant: {selectedPayment.bill?.tenantName || 'N/A'}
              </p>
              <p className="text-sm text-gray-600">
                Amount: {selectedPayment.amount}
              </p>
              <p className="text-sm text-gray-600">
                Method: {selectedPayment.method.replace('_', ' ')}
              </p>
              {selectedPayment.slipUrl && (
                <p className="text-sm text-gray-600">
                  <a
                    href={selectedPayment.slipUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-blue-600 hover:underline"
                  >
                    View Payment Slip
                  </a>
                </p>
              )}
            </div>
            <div className="flex gap-3 mt-4">
              <button
                onClick={() => setShowConfirmDialog(true)}
                className="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700"
              >
                Confirm Payment
              </button>
              <button
                onClick={() => setShowRejectDialog(true)}
                className="px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700"
              >
                Reject Payment
              </button>
            </div>
          </div>
        )}
      </div>

      <ConfirmDialog
        isOpen={showConfirmDialog}
        onClose={() => setShowConfirmDialog(false)}
        onConfirm={handleConfirm}
        title="Confirm Payment"
        message="Are you sure you want to confirm this payment?"
        confirmText="Confirm"
        variant="info"
      />

      <ConfirmDialog
        isOpen={showRejectDialog}
        onClose={() => setShowRejectDialog(false)}
        onConfirm={handleReject}
        title="Reject Payment"
        message="Are you sure you want to reject this payment?"
        confirmText="Reject"
        variant="danger"
      />
    </div>
  );
}
