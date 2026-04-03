'use client';

import { useState } from 'react';
import { useMaintenance } from '@/hooks/owner/useMaintenance';
import { DataTable } from '@/components/shared/DataTable';
import { StatusBadge } from '@/components/shared/StatusBadge';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { formatDate } from '@/lib/utils';
import type { MaintenanceRequest, MaintenanceFilters } from '@/types/maintenance.types';
import { Wrench } from 'lucide-react';

export default function MaintenancePage() {
  const [filters, setFilters] = useState<MaintenanceFilters>({});
  const { data, isLoading, error } = useMaintenance(filters);

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
        <p className="text-red-800">Failed to load maintenance requests</p>
      </div>
    );
  }

  const columns = [
    {
      key: 'room',
      label: 'Room',
      render: (request: MaintenanceRequest) => (
        <div>
          <p className="font-medium">{request.roomNumber}</p>
          <p className="text-xs text-gray-500">{request.buildingName}</p>
        </div>
      ),
    },
    {
      key: 'title',
      label: 'Issue',
      render: (request: MaintenanceRequest) => (
        <div>
          <p className="font-medium">{request.title}</p>
          <p className="text-xs text-gray-500">{request.description}</p>
        </div>
      ),
    },
    {
      key: 'priority',
      label: 'Priority',
      render: (request: MaintenanceRequest) => {
        const colors = {
          low: 'bg-gray-100 text-gray-800',
          medium: 'bg-blue-100 text-blue-800',
          high: 'bg-orange-100 text-orange-800',
          urgent: 'bg-red-100 text-red-800',
        };
        return (
          <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${colors[request.priority]}`}>
            {request.priority.toUpperCase()}
          </span>
        );
      },
    },
    {
      key: 'status',
      label: 'Status',
      render: (request: MaintenanceRequest) => <StatusBadge status={request.status} />,
    },
    {
      key: 'reportedAt',
      label: 'Reported',
      render: (request: MaintenanceRequest) => formatDate(request.reportedAt),
    },
    {
      key: 'completedAt',
      label: 'Completed',
      render: (request: MaintenanceRequest) =>
        request.completedAt ? formatDate(request.completedAt) : '-',
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Maintenance</h1>
          <p className="text-gray-600">Track and manage maintenance requests</p>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow p-6">
        <div className="mb-4 flex gap-4">
          <select
            className="px-3 py-2 border border-gray-300 rounded-md"
            onChange={(e) => setFilters({ ...filters, status: e.target.value as any })}
          >
            <option value="">All Statuses</option>
            <option value="pending">Pending</option>
            <option value="in_progress">In Progress</option>
            <option value="completed">Completed</option>
          </select>

          <select
            className="px-3 py-2 border border-gray-300 rounded-md"
            onChange={(e) => setFilters({ ...filters, priority: e.target.value as any })}
          >
            <option value="">All Priorities</option>
            <option value="low">Low</option>
            <option value="medium">Medium</option>
            <option value="high">High</option>
            <option value="urgent">Urgent</option>
          </select>
        </div>

        {data && data.items.length > 0 ? (
          <DataTable data={data.items} columns={columns} />
        ) : (
          <div className="text-center py-12">
            <Wrench className="w-16 h-16 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-semibold text-gray-900 mb-2">No Maintenance Requests</h3>
            <p className="text-gray-600">All caught up! No maintenance requests to show.</p>
          </div>
        )}
      </div>
    </div>
  );
}
