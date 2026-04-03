'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/utils';
import {
  LayoutDashboard,
  Users,
  CreditCard,
  TrendingUp,
} from 'lucide-react';

const navigation = [
  { name: 'Dashboard', href: '/admin/dashboard', icon: LayoutDashboard },
  { name: 'Owners', href: '/admin/owners', icon: Users },
  { name: 'Payments', href: '/admin/payments', icon: CreditCard },
  { name: 'Stats', href: '/admin/stats', icon: TrendingUp },
];

export function AdminSidebar() {
  const pathname = usePathname();

  return (
    <div className="w-64 bg-indigo-600 text-white min-h-screen flex flex-col">
      <div className="p-6 border-b border-indigo-500">
        <h2 className="text-xl font-bold">Rental System</h2>
        <p className="text-sm text-indigo-200 mt-1">Admin Portal</p>
      </div>

      <nav className="mt-2 flex-1">
        {navigation.map((item) => {
          const isActive = pathname.startsWith(item.href);
          const Icon = item.icon;
          return (
            <Link
              key={item.name}
              href={item.href}
              className={cn(
                'flex items-center gap-3 px-6 py-3 text-sm font-medium transition-colors',
                isActive
                  ? 'bg-indigo-700 text-white border-l-4 border-white'
                  : 'text-indigo-100 hover:bg-indigo-700 hover:text-white'
              )}
            >
              <Icon className="w-5 h-5" />
              {item.name}
            </Link>
          );
        })}
      </nav>
    </div>
  );
}
