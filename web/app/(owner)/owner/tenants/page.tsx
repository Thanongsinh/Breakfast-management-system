'use client';

import { useTenants } from '@/hooks/owner/useTenants';
import { DataTable } from '@/components/shared/DataTable';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { formatDate } from '@/lib/utils';
import type { Tenant } from '@/types/tenant.types';
import { Users } from 'lucide-react';

export default function TenantsPage() {
  const { data: tenants, isLoading, error } = useTenants();

  if (isLoading) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-50 border border-red-200 rounded-lg p-4">
        <p className="text-red-800">Failed to load tenants</p>
      </div>
    );
  }

  const columns = [
    {
      key: 'name',
      label: 'Name',
      render: (tenant: Tenant) => (
        <div>
          <p className="font-medium">{tenant.name}</p>
          <p className="text-xs text-gray-500">{tenant.email}</p>
        </div>
      ),
    },
    {
      key: 'phoneNumber',
      label: 'Phone',
      render: (tenant: Tenant) => tenant.phoneNumber,
    },
    {
      key: 'currentRoom',
      label: 'Current Room',
      render: (tenant: Tenant) => (
        <div>
          {tenant.currentRoomNumber ? (
            <>
              <p className="font-medium">{tenant.currentRoomNumber}</p>
              <p className="text-xs text-gray-500">{tenant.currentBuildingName}</p>
            </>
          ) : (
            <span className="text-gray-400">No active contract</span>
          )}
        </div>
      ),
    },
    {
      key: 'idCard',
      label: 'ID Card',
      render: (tenant: Tenant) => tenant.idCard,
    },
    {
      key: 'createdAt',
      label: 'Registered',
      render: (tenant: Tenant) => formatDate(tenant.createdAt),
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Tenants</h1>
          <p className="text-gray-600">Manage your tenants</p>
        </div>
      </div>

      {tenants && tenants.length > 0 ? (
        <div className="bg-white rounded-lg shadow p-6">
          <DataTable data={tenants} columns={columns} />
        </div>
      ) : (
        <div className="bg-white rounded-lg shadow p-12 text-center">
          <Users className="w-16 h-16 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-semibold text-gray-900 mb-2">No Tenants Yet</h3>
          <p className="text-gray-600">Add your first tenant to get started</p>
        </div>
      )}
    </div>
  );
}
