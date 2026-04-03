'use client';

import { DataTable } from '@/components/shared/DataTable';
import { StatusBadge } from '@/components/shared/StatusBadge';
import { formatCurrency, formatDate } from '@/lib/utils';
import type { Bill } from '@/types/bill.types';

interface BillTableProps {
  bills: Bill[];
  onBillClick?: (bill: Bill) => void;
}

export function BillTable({ bills, onBillClick }: BillTableProps) {
  const columns = [
    {
      key: 'roomNumber',
      label: 'Room',
      render: (bill: Bill) => (
        <div>
          <p className="font-medium">{bill.roomNumber}</p>
          <p className="text-xs text-gray-500">{bill.buildingName}</p>
        </div>
      ),
    },
    {
      key: 'tenantName',
      label: 'Tenant',
      render: (bill: Bill) => bill.tenantName || '-',
    },
    {
      key: 'amount',
      label: 'Amount',
      render: (bill: Bill) => (
        <span className="font-semibold">{formatCurrency(bill.amount)}</span>
      ),
    },
    {
      key: 'dueDate',
      label: 'Due Date',
      render: (bill: Bill) => formatDate(bill.dueDate),
    },
    {
      key: 'status',
      label: 'Status',
      render: (bill: Bill) => <StatusBadge status={bill.status} />,
    },
    {
      key: 'paidAt',
      label: 'Paid At',
      render: (bill: Bill) => (bill.paidAt ? formatDate(bill.paidAt) : '-'),
    },
  ];

  return <DataTable data={bills} columns={columns} onRowClick={onBillClick} />;
}
