'use client';

import { useSession, signOut } from 'next-auth/react';
import { RoleBadge } from '@/components/shared/RoleBadge';
import type { Role } from '@/types/auth.types';

export function TopBar() {
  const { data: session } = useSession();
  const user = session?.user;
  const role = (user as any)?.role as Role;

  const handleSignOut = async () => {
    await signOut({ callbackUrl: '/login' });
  };

  return (
    <div className="h-16 bg-white border-b border-gray-200 px-6 flex items-center justify-between">
      <div className="flex items-center gap-4">
        <h1 className="text-xl font-semibold text-gray-900">Rental Management System</h1>
      </div>

      <div className="flex items-center gap-4">
        {role && <RoleBadge role={role} />}
        <div className="text-sm">
          <p className="font-medium text-gray-900">{user?.name}</p>
          <p className="text-gray-500">{user?.email}</p>
        </div>
        <button
          onClick={handleSignOut}
          className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
        >
          Sign Out
        </button>
      </div>
    </div>
  );
}
