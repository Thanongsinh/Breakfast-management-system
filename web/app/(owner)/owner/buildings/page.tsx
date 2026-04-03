'use client';

import { useBuildings } from '@/hooks/owner/useBuildings';
import { StatCard } from '@/components/shared/StatCard';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { formatCurrency } from '@/lib/utils';
import Link from 'next/link';
import { Building2, Users, DoorOpen } from 'lucide-react';

export default function BuildingsPage() {
  const { data: buildings, isLoading, error } = useBuildings();

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
        <p className="text-red-800">Failed to load buildings</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Buildings</h1>
          <p className="text-gray-600">Manage your properties</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {buildings?.map((building) => (
          <Link key={building.id} href={`/owner/buildings/${building.id}`}>
            <div className="bg-white rounded-lg shadow p-6 hover:shadow-lg transition-shadow cursor-pointer border-l-4 border-blue-600">
              <div className="flex items-start justify-between mb-4">
                <div>
                  <h3 className="text-lg font-semibold text-gray-900">{building.name}</h3>
                  <p className="text-sm text-gray-500 mt-1">{building.address}</p>
                </div>
                <Building2 className="w-8 h-8 text-blue-600" />
              </div>

              <div className="grid grid-cols-3 gap-3 mt-4">
                <div className="text-center">
                  <p className="text-2xl font-bold text-gray-900">{building.totalRooms}</p>
                  <p className="text-xs text-gray-500">Total Rooms</p>
                </div>
                <div className="text-center">
                  <p className="text-2xl font-bold text-green-600">{building.occupiedRooms}</p>
                  <p className="text-xs text-gray-500">Occupied</p>
                </div>
                <div className="text-center">
                  <p className="text-2xl font-bold text-blue-600">{building.availableRooms}</p>
                  <p className="text-xs text-gray-500">Available</p>
                </div>
              </div>

              <div className="mt-4 pt-4 border-t border-gray-200">
                <div className="flex justify-between items-center text-sm">
                  <span className="text-gray-500">Occupancy Rate</span>
                  <span className="font-semibold text-gray-900">
                    {building.totalRooms > 0
                      ? `${Math.round((building.occupiedRooms / building.totalRooms) * 100)}%`
                      : '0%'
                    }
                  </span>
                </div>
              </div>
            </div>
          </Link>
        ))}
      </div>

      {buildings && buildings.length === 0 && (
        <div className="bg-white rounded-lg shadow p-12 text-center">
          <Building2 className="w-16 h-16 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-semibold text-gray-900 mb-2">No Buildings Yet</h3>
          <p className="text-gray-600">Create your first building to get started</p>
        </div>
      )}
    </div>
  );
}
