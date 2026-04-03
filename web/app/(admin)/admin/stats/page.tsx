'use client';

import { useMRR, useDashboardStats } from '@/hooks/admin/useStats';
import { MRRChart } from '@/components/admin/MRRChart';
import { StatCard } from '@/components/shared/StatCard';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { formatCurrency } from '@/lib/utils';
import { TrendingUp } from 'lucide-react';

export default function AdminStatsPage() {
  const { data: mrrData, isLoading: mrrLoading } = useMRR(12);
  const { data: stats, isLoading: statsLoading } = useDashboardStats();

  if (mrrLoading || statsLoading) {
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
        <h1 className="text-2xl font-bold text-gray-900">Statistics</h1>
        <p className="text-gray-600">Detailed system metrics and trends</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <StatCard
          title="Current MRR"
          value={formatCurrency(stats?.currentMRR || 0)}
          className="border-l-4 border-indigo-600"
        />
        <StatCard
          title="Total Revenue"
          value={formatCurrency(stats?.totalRevenue || 0)}
          className="border-l-4 border-green-500"
        />
        <StatCard
          title="Occupancy Rate"
          value={`${occupancyRate}%`}
          className="border-l-4 border-blue-500"
        />
      </div>

      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">
          Monthly Recurring Revenue (12 Months)
        </h2>
        {mrrData && mrrData.length > 0 ? (
          <MRRChart data={mrrData} />
        ) : (
          <div className="text-center py-12">
            <TrendingUp className="w-16 h-16 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-semibold text-gray-900 mb-2">No MRR Data</h3>
            <p className="text-gray-600">MRR data will appear as revenue is generated</p>
          </div>
        )}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">System Overview</h2>
          <div className="space-y-3">
            <div className="flex justify-between items-center py-2 border-b">
              <span className="text-gray-600">Total Owners</span>
              <span className="font-semibold text-gray-900">{stats?.totalOwners || 0}</span>
            </div>
            <div className="flex justify-between items-center py-2 border-b">
              <span className="text-gray-600">Active Owners</span>
              <span className="font-semibold text-green-600">{stats?.activeOwners || 0}</span>
            </div>
            <div className="flex justify-between items-center py-2 border-b">
              <span className="text-gray-600">Total Buildings</span>
              <span className="font-semibold text-gray-900">{stats?.totalBuildings || 0}</span>
            </div>
            <div className="flex justify-between items-center py-2 border-b">
              <span className="text-gray-600">Total Rooms</span>
              <span className="font-semibold text-gray-900">{stats?.totalRooms || 0}</span>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Revenue Metrics</h2>
          <div className="space-y-3">
            <div className="flex justify-between items-center py-2 border-b">
              <span className="text-gray-600">Occupied Rooms</span>
              <span className="font-semibold text-gray-900">
                {stats?.occupiedRooms || 0} / {stats?.totalRooms || 0}
              </span>
            </div>
            <div className="flex justify-between items-center py-2 border-b">
              <span className="text-gray-600">Pending Payments</span>
              <span className="font-semibold text-orange-600">{stats?.pendingPayments || 0}</span>
            </div>
            <div className="flex justify-between items-center py-2 border-b">
              <span className="text-gray-600">Avg per Room</span>
              <span className="font-semibold text-gray-900">
                {stats?.occupiedRooms && stats.currentMRR
                  ? formatCurrency(stats.currentMRR / stats.occupiedRooms)
                  : formatCurrency(0)
                }
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
