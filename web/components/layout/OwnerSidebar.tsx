'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/utils';
import {
  LayoutDashboard,
  Building2,
  Users,
  FileText,
  CreditCard,
  Wrench,
  BarChart3,
} from 'lucide-react';

const navigation = [
  { name: 'Dashboard', href: '/owner/dashboard', icon: LayoutDashboard },
  { name: 'Buildings', href: '/owner/buildings', icon: Building2 },
  { name: 'Tenants', href: '/owner/tenants', icon: Users },
  { name: 'Billing', href: '/owner/billing', icon: FileText },
  { name: 'Payments', href: '/owner/payments', icon: CreditCard },
  { name: 'Maintenance', href: '/owner/maintenance', icon: Wrench },
  { name: 'Reports', href: '/owner/reports', icon: BarChart3 },
];

export function OwnerSidebar() {
  const pathname = usePathname();

  return (
    <div className="w-64 bg-blue-600 text-white min-h-screen flex flex-col">
      <div className="p-6 border-b border-blue-500">
        <h2 className="text-xl font-bold">Rental System</h2>
        <p className="text-sm text-blue-200 mt-1">Owner Portal</p>
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
                  ? 'bg-blue-700 text-white border-l-4 border-white'
                  : 'text-blue-100 hover:bg-blue-700 hover:text-white'
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
