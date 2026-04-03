'use client';

import { useState } from 'react';
import { useIncomeReport } from '@/hooks/owner/useDashboard';
import { StatCard } from '@/components/shared/StatCard';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { formatCurrency } from '@/lib/utils';
import { BarChart3, Download } from 'lucide-react';

export default function ReportsPage() {
  const currentDate = new Date();
  const [month, setMonth] = useState(currentDate.getMonth() + 1);
  const [year, setYear] = useState(currentDate.getFullYear());

  const { data: report, isLoading } = useIncomeReport(month, year);

  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  const years = Array.from({ length: 5 }, (_, i) => currentDate.getFullYear() - i);

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Reports</h1>
          <p className="text-gray-600">View your financial reports</p>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow p-6">
        <div className="flex gap-4 mb-6">
          <select
            value={month}
            onChange={(e) => setMonth(Number(e.target.value))}
            className="px-3 py-2 border border-gray-300 rounded-md"
          >
            {months.map((m, i) => (
              <option key={m} value={i + 1}>{m}</option>
            ))}
          </select>

          <select
            value={year}
            onChange={(e) => setYear(Number(e.target.value))}
            className="px-3 py-2 border border-gray-300 rounded-md"
          >
            {years.map((y) => (
              <option key={y} value={y}>{y}</option>
            ))}
          </select>
        </div>

        {isLoading ? (
          <div className="flex justify-center py-12">
            <LoadingSpinner size="lg" />
          </div>
        ) : report ? (
          <>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
              <StatCard
                title="Total Income"
                value={formatCurrency(report.totalIncome || 0)}
                className="border-l-4 border-green-500"
              />
              <StatCard
                title="Total Expenses"
                value={formatCurrency(report.totalExpenses || 0)}
                className="border-l-4 border-red-500"
              />
              <StatCard
                title="Net Income"
                value={formatCurrency(report.netIncome || 0)}
                className="border-l-4 border-blue-600"
              />
            </div>

            {report.buildingBreakdown && report.buildingBreakdown.length > 0 && (
              <div className="mt-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Income by Building</h3>
                <div className="space-y-3">
                  {report.buildingBreakdown.map((building: any) => (
                    <div key={building.buildingId} className="flex justify-between items-center py-3 border-b">
                      <span className="font-medium text-gray-900">{building.buildingName}</span>
                      <span className="font-semibold text-green-600">
                        {formatCurrency(building.income)}
                      </span>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </>
        ) : (
          <div className="text-center py-12">
            <BarChart3 className="w-16 h-16 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-semibold text-gray-900 mb-2">No Data Available</h3>
            <p className="text-gray-600">No report data for the selected period</p>
          </div>
        )}
      </div>
    </div>
  );
}
