'use client';

import { useDashboardStats, useMRR } from '@/hooks/admin/useStats';
import { StatCard } from '@/components/shared/StatCard';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { MRRChart } from '@/components/admin/MRRChart';
import { formatCurrency } from '@/lib/utils';

export default function AdminDashboardPage() {
  const { data: stats, isLoading: statsLoading } = useDashboardStats();
  const { data: mrrData, isLoading: mrrLoading } = useMRR(12);

  if (statsLoading || mrrLoading) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  const occupancyRate = stats?.totalRooms
    ? ((stats.occupiedRooms / stats.totalRooms) * 100).toFixed(1)
    : 0;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Admin Dashboard</h1>
        <p className="text-gray-600">System overview and metrics</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          title="Total Owners"
          value={stats?.totalOwners || 0}
          className="border-l-4 border-indigo-500"
        />
        <StatCard
          title="Active Owners"
          value={stats?.activeOwners || 0}
          className="border-l-4 border-green-500"
        />
        <StatCard
          title="Total Buildings"
          value={stats?.totalBuildings || 0}
          className="border-l-4 border-blue-500"
        />
        <StatCard
          title="Total Rooms"
          value={stats?.totalRooms || 0}
          className="border-l-4 border-purple-500"
        />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <StatCard
          title="Occupancy Rate"
          value={`${occupancyRate}%`}
          className="border-l-4 border-yellow-500"
        />
        <StatCard
          title="Current MRR"
          value={formatCurrency(stats?.currentMRR || 0)}
          className="border-l-4 border-admin"
        />
        <StatCard
          title="Pending Payments"
          value={stats?.pendingPayments || 0}
          className="border-l-4 border-orange-500"
        />
      </div>

      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">
          Monthly Recurring Revenue Trend
        </h2>
        {mrrData && <MRRChart data={mrrData} />}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Quick Stats</h2>
          <div className="space-y-3">
            <div className="flex justify-between items-center py-2 border-b">
              <span className="text-gray-600">Total Revenue</span>
              <span className="font-semibold text-gray-900">
                {formatCurrency(stats?.totalRevenue || 0)}
              </span>
            </div>
            <div className="flex justify-between items-center py-2 border-b">
              <span className="text-gray-600">Occupied Rooms</span>
              <span className="font-semibold text-gray-900">
                {stats?.occupiedRooms || 0} / {stats?.totalRooms || 0}
              </span>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">System Health</h2>
          <div className="space-y-3">
            <div className="flex justify-between items-center py-2 border-b">
              <span className="text-gray-600">Active Owners</span>
              <span className="px-2 py-1 bg-green-100 text-green-800 text-sm rounded">
                {stats?.activeOwners || 0}
              </span>
            </div>
            <div className="flex justify-between items-center py-2 border-b">
              <span className="text-gray-600">Pending Reviews</span>
              <span className="px-2 py-1 bg-yellow-100 text-yellow-800 text-sm rounded">
                {stats?.pendingPayments || 0}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
