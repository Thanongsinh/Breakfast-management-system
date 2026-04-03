'use client';

import { DataTable } from '@/components/shared/DataTable';
import { formatDate } from '@/lib/utils';
import type { User } from '@/types/auth.types';

interface OwnerTableProps {
  owners: User[];
  onOwnerClick?: (owner: User) => void;
}

export function OwnerTable({ owners, onOwnerClick }: OwnerTableProps) {
  const columns = [
    {
      key: 'name',
      label: 'Name',
      render: (owner: User) => (
        <div>
          <p className="font-medium">{owner.name}</p>
          <p className="text-xs text-gray-500">{owner.email}</p>
        </div>
      ),
    },
    {
      key: 'phoneNumber',
      label: 'Phone',
      render: (owner: User) => owner.phoneNumber || '-',
    },
    {
      key: 'createdAt',
      label: 'Registered',
      render: (owner: User) => formatDate(owner.createdAt),
    },
    {
      key: 'status',
      label: 'Status',
      render: (owner: User) => (
        <span
          className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
            (owner as any).status === 'active'
              ? 'bg-green-100 text-green-800'
              : 'bg-gray-100 text-gray-800'
          }`}
        >
          {(owner as any).status || 'Active'}
        </span>
      ),
    },
  ];

  return <DataTable data={owners} columns={columns} onRowClick={onOwnerClick} />;
}
