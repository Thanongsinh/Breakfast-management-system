'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/utils';

const navigation = [
  { name: 'Dashboard', href: '/owner/dashboard' },
  { name: 'Buildings', href: '/owner/buildings' },
  { name: 'Tenants', href: '/owner/tenants' },
  { name: 'Billing', href: '/owner/billing' },
  { name: 'Payments', href: '/owner/payments' },
  { name: 'Maintenance', href: '/owner/maintenance' },
  { name: 'Reports', href: '/owner/reports' },
];

export function OwnerSidebar() {
  const pathname = usePathname();

  return (
    <div className="w-64 bg-owner text-white min-h-screen">
      <div className="p-6">
        <h2 className="text-lg font-semibold">Owner Portal</h2>
      </div>

      <nav className="mt-6">
        {navigation.map((item) => {
          const isActive = pathname === item.href;
          return (
            <Link
              key={item.name}
              href={item.href}
              className={cn(
                'block px-6 py-3 text-sm font-medium transition-colors',
                isActive
                  ? 'bg-owner-dark text-white'
                  : 'text-blue-100 hover:bg-owner-light hover:text-white'
              )}
            >
              {item.name}
            </Link>
          );
        })}
      </nav>
    </div>
  );
}
