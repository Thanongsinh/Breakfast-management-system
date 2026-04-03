'use client';

import { useState } from 'react';
import { useBills, useGenerateBills } from '@/hooks/owner/useBills';
import { BillTable } from '@/components/owner/BillTable';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import type { BillFilters } from '@/types/bill.types';

export default function BillingPage() {
  const [filters, setFilters] = useState<BillFilters>({});
  const { data, isLoading, error } = useBills(filters);
  const generateBills = useGenerateBills();

  const handleGenerateBills = () => {
    const now = new Date();
    generateBills.mutate({
      month: now.getMonth() + 1,
      year: now.getFullYear(),
    });
  };

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
        <p className="text-red-800">Failed to load bills</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Billing</h1>
          <p className="text-gray-600">Manage your bills and invoices</p>
        </div>
        <button
          onClick={handleGenerateBills}
          disabled={generateBills.isPending}
          className="px-4 py-2 bg-owner text-white rounded-md hover:bg-owner-dark disabled:opacity-50"
        >
          {generateBills.isPending ? 'Generating...' : 'Generate Bills'}
        </button>
      </div>

      <div className="bg-white rounded-lg shadow p-6">
        <div className="mb-4 flex gap-4">
          <select
            className="px-3 py-2 border border-gray-300 rounded-md"
            onChange={(e) => setFilters({ ...filters, status: e.target.value as any })}
          >
            <option value="">All Statuses</option>
            <option value="paid">Paid</option>
            <option value="unpaid">Unpaid</option>
            <option value="overdue">Overdue</option>
          </select>
        </div>

        <BillTable bills={data?.items || []} />

        {data && data.totalPages > 1 && (
          <div className="mt-4 flex justify-center gap-2">
            {Array.from({ length: data.totalPages }, (_, i) => i + 1).map((page) => (
              <button
                key={page}
                onClick={() => setFilters({ ...filters, page })}
                className={`px-3 py-1 rounded ${
                  page === data.page
                    ? 'bg-owner text-white'
                    : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
                }`}
              >
                {page}
              </button>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
