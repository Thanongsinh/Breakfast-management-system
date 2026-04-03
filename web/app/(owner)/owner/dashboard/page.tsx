'use client';

import { useDashboard } from '@/hooks/owner/useDashboard';
import { StatCard } from '@/components/shared/StatCard';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { formatCurrency } from '@/lib/utils';

export default function OwnerDashboardPage() {
  const { data, isLoading, error } = useDashboard();

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
        <p className="text-red-800">Failed to load dashboard data</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-gray-600">Welcome back! Here's your property overview</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          title="Total Buildings"
          value={data?.totalBuildings || 0}
          className="border-l-4 border-blue-500"
        />
        <StatCard
          title="Total Rooms"
          value={data?.totalRooms || 0}
          className="border-l-4 border-green-500"
        />
        <StatCard
          title="Occupied Rooms"
          value={data?.occupiedRooms || 0}
          className="border-l-4 border-yellow-500"
        />
        <StatCard
          title="Available Rooms"
          value={data?.availableRooms || 0}
          className="border-l-4 border-purple-500"
        />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <StatCard
          title="Monthly Income"
          value={formatCurrency(data?.monthlyIncome || 0)}
          className="border-l-4 border-owner"
        />
        <StatCard
          title="Unpaid Bills"
          value={data?.unpaidBills || 0}
          className="border-l-4 border-red-500"
        />
        <StatCard
          title="Pending Maintenance"
          value={data?.pendingMaintenance || 0}
          className="border-l-4 border-orange-500"
        />
      </div>

      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Recent Payments</h2>
        {data?.recentPayments && data.recentPayments.length > 0 ? (
          <div className="space-y-3">
            {data.recentPayments.map((payment: any, index: number) => (
              <div key={index} className="flex justify-between items-center py-2 border-b">
                <div>
                  <p className="font-medium text-gray-900">{payment.roomNumber}</p>
                  <p className="text-sm text-gray-500">{payment.date}</p>
                </div>
                <p className="font-semibold text-green-600">
                  {formatCurrency(payment.amount)}
                </p>
              </div>
            ))}
          </div>
        ) : (
          <p className="text-gray-500">No recent payments</p>
        )}
      </div>
    </div>
  );
}
