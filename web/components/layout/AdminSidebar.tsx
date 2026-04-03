'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/utils';

const navigation = [
  { name: 'Dashboard', href: '/admin/dashboard' },
  { name: 'Owners', href: '/admin/owners' },
  { name: 'Payments', href: '/admin/payments' },
  { name: 'Reports', href: '/admin/reports' },
];

export function AdminSidebar() {
  const pathname = usePathname();

  return (
    <div className="w-64 bg-admin text-white min-h-screen">
      <div className="p-6">
        <h2 className="text-lg font-semibold">Admin Portal</h2>
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
                  ? 'bg-admin-dark text-white'
                  : 'text-indigo-100 hover:bg-admin-light hover:text-white'
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
