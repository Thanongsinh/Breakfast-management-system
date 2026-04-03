'use client';

import { useSession, signOut } from 'next-auth/react';
import { RoleBadge } from '@/components/shared/RoleBadge';
import { LogOut } from 'lucide-react';

export function TopBar() {
  const { data: session } = useSession();
  const user = session?.user;

  const handleSignOut = async () => {
    await signOut({ callbackUrl: '/login' });
  };

  return (
    <div className="h-16 bg-white border-b border-gray-200 px-6 flex items-center justify-between shadow-sm">
      <div className="flex items-center gap-4">
        <h1 className="text-lg font-semibold text-gray-900">
          {user?.role === 'owner' ? 'Owner Dashboard' : 'Admin Dashboard'}
        </h1>
      </div>

      <div className="flex items-center gap-4">
        {user?.role && <RoleBadge role={user.role} />}
        <div className="text-sm border-l pl-4">
          <p className="font-medium text-gray-900">{user?.name}</p>
          <p className="text-xs text-gray-500">{user?.email}</p>
        </div>
        <button
          onClick={handleSignOut}
          className="flex items-center gap-2 px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 transition-colors"
        >
          <LogOut className="w-4 h-4" />
          Logout
        </button>
      </div>
    </div>
  );
}
