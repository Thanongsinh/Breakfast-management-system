'use client';

import { useState } from 'react';
import { useOwners, useUpdateOwnerStatus } from '@/hooks/admin/useOwners';
import { OwnerTable } from '@/components/admin/OwnerTable';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { ConfirmDialog } from '@/components/shared/ConfirmDialog';
import type { User } from '@/types/auth.types';

export default function OwnersPage() {
  const [selectedOwner, setSelectedOwner] = useState<User | null>(null);
  const [showStatusDialog, setShowStatusDialog] = useState(false);
  const [newStatus, setNewStatus] = useState<'active' | 'inactive'>('active');

  const { data, isLoading } = useOwners();
  const updateStatus = useUpdateOwnerStatus();

  const handleStatusChange = () => {
    if (selectedOwner) {
      updateStatus.mutate({
        ownerId: selectedOwner.id,
        status: newStatus,
      });
      setSelectedOwner(null);
    }
  };

  if (isLoading) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Owners Management</h1>
        <p className="text-gray-600">Manage property owners and their accounts</p>
      </div>

      <div className="bg-white rounded-lg shadow p-6">
        <OwnerTable
          owners={data?.items || []}
          onOwnerClick={(owner) => setSelectedOwner(owner)}
        />

        {selectedOwner && (
          <div className="mt-6 p-4 bg-gray-50 rounded-lg">
            <h3 className="text-lg font-semibold text-gray-900 mb-3">Owner Details</h3>
            <div className="space-y-2">
              <p className="text-sm text-gray-600">Name: {selectedOwner.name}</p>
              <p className="text-sm text-gray-600">Email: {selectedOwner.email}</p>
              <p className="text-sm text-gray-600">
                Phone: {selectedOwner.phoneNumber || 'N/A'}
              </p>
              <p className="text-sm text-gray-600">
                Status: {(selectedOwner as any).status || 'Active'}
              </p>
            </div>
            <div className="flex gap-3 mt-4">
              <button
                onClick={() => {
                  setNewStatus('active');
                  setShowStatusDialog(true);
                }}
                className="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700"
              >
                Activate
              </button>
              <button
                onClick={() => {
                  setNewStatus('inactive');
                  setShowStatusDialog(true);
                }}
                className="px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700"
              >
                Deactivate
              </button>
            </div>
          </div>
        )}
      </div>

      <ConfirmDialog
        isOpen={showStatusDialog}
        onClose={() => setShowStatusDialog(false)}
        onConfirm={handleStatusChange}
        title={`${newStatus === 'active' ? 'Activate' : 'Deactivate'} Owner`}
        message={`Are you sure you want to ${
          newStatus === 'active' ? 'activate' : 'deactivate'
        } this owner account?`}
        confirmText="Confirm"
        variant={newStatus === 'active' ? 'info' : 'warning'}
      />
    </div>
  );
}
