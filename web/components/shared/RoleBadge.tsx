import { cn } from '@/lib/utils';
import type { Role } from '@/types/auth.types';

interface RoleBadgeProps {
  role: Role;
  className?: string;
}

const roleConfig: Record<Role, { label: string; className: string }> = {
  owner: {
    label: 'Owner',
    className: 'bg-blue-100 text-blue-800 border-blue-300',
  },
  admin: {
    label: 'Admin',
    className: 'bg-indigo-100 text-indigo-800 border-indigo-300',
  },
  tenant: {
    label: 'Tenant',
    className: 'bg-purple-100 text-purple-800 border-purple-300',
  },
};

export function RoleBadge({ role, className }: RoleBadgeProps) {
  const config = roleConfig[role];

  return (
    <span
      className={cn(
        'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border',
        config.className,
        className
      )}
    >
      {config.label}
    </span>
  );
}
