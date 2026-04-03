import { cn } from '@/lib/utils';
import type { BillStatus } from '@/types/bill.types';
import type { PaymentStatus } from '@/types/payment.types';
import type { RoomStatus } from '@/types/building.types';
import type { MaintenanceStatus } from '@/types/maintenance.types';

type Status = BillStatus | PaymentStatus | RoomStatus | MaintenanceStatus;

interface StatusBadgeProps {
  status: Status;
  className?: string;
}

const statusConfig: Record<string, { label: string; className: string }> = {
  // Bill statuses
  paid: { label: 'Paid', className: 'bg-green-100 text-green-800 border-green-300' },
  unpaid: { label: 'Unpaid', className: 'bg-red-100 text-red-800 border-red-300' },
  pending: { label: 'Pending', className: 'bg-yellow-100 text-yellow-800 border-yellow-300' },
  overdue: { label: 'Overdue', className: 'bg-red-100 text-red-800 border-red-300' },

  // Payment statuses
  confirmed: { label: 'Confirmed', className: 'bg-green-100 text-green-800 border-green-300' },
  rejected: { label: 'Rejected', className: 'bg-red-100 text-red-800 border-red-300' },

  // Room statuses
  available: { label: 'Available', className: 'bg-green-100 text-green-800 border-green-300' },
  occupied: { label: 'Occupied', className: 'bg-blue-100 text-blue-800 border-blue-300' },
  maintenance: { label: 'Maintenance', className: 'bg-yellow-100 text-yellow-800 border-yellow-300' },

  // Maintenance statuses
  in_progress: { label: 'In Progress', className: 'bg-blue-100 text-blue-800 border-blue-300' },
  completed: { label: 'Completed', className: 'bg-green-100 text-green-800 border-green-300' },
  cancelled: { label: 'Cancelled', className: 'bg-gray-100 text-gray-800 border-gray-300' },
};

export function StatusBadge({ status, className }: StatusBadgeProps) {
  const config = statusConfig[status] || {
    label: status,
    className: 'bg-gray-100 text-gray-800 border-gray-300',
  };

  return (
    <span
      className={cn(
        'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border',
        config.className,
        className
      )}
    >
      {config.label}
    </span>
  );
}
