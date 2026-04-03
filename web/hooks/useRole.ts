'use client';

import { useSession } from 'next-auth/react';
import type { Role } from '@/types/auth.types';

export function useRole(): Role | null {
  const { data: session } = useSession();
  return (session?.user as any)?.role || null;
}

export function useIsOwner(): boolean {
  const role = useRole();
  return role === 'owner';
}

export function useIsAdmin(): boolean {
  const role = useRole();
  return role === 'admin';
}

export function useIsTenant(): boolean {
  const role = useRole();
  return role === 'tenant';
}
