'use client';

import { DataTable } from '@/components/shared/DataTable';
import { StatusBadge } from '@/components/shared/StatusBadge';
import { formatCurrency, formatDate } from '@/lib/utils';
import type { Payment } from '@/types/payment.types';

interface PendingPaymentsTableProps {
  payments: Payment[];
  onPaymentClick?: (payment: Payment) => void;
}

export function PendingPaymentsTable({ payments, onPaymentClick }: PendingPaymentsTableProps) {
  const columns = [
    {
      key: 'bill',
      label: 'Bill Info',
      render: (payment: Payment) => (
        <div>
          <p className="font-medium">{payment.bill?.roomNumber}</p>
          <p className="text-xs text-gray-500">{payment.bill?.buildingName}</p>
        </div>
      ),
    },
    {
      key: 'tenantName',
      label: 'Tenant',
      render: (payment: Payment) => payment.bill?.tenantName || '-',
    },
    {
      key: 'amount',
      label: 'Amount',
      render: (payment: Payment) => (
        <span className="font-semibold">{formatCurrency(payment.amount)}</span>
      ),
    },
    {
      key: 'method',
      label: 'Method',
      render: (payment: Payment) => (
        <span className="capitalize">{payment.method.replace('_', ' ')}</span>
      ),
    },
    {
      key: 'createdAt',
      label: 'Submitted',
      render: (payment: Payment) => formatDate(payment.createdAt),
    },
    {
      key: 'status',
      label: 'Status',
      render: (payment: Payment) => <StatusBadge status={payment.status} />,
    },
  ];

  return <DataTable data={payments} columns={columns} onRowClick={onPaymentClick} />;
}
