import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import { auth } from '@/lib/auth';

export async function middleware(request: NextRequest) {
  const session = await auth();
  const { pathname } = request.nextUrl;

  // Public routes
  if (pathname === '/login') {
    if (session?.user?.role) {
      const role = session.user.role;
      return NextResponse.redirect(new URL(`/${role}/dashboard`, request.url));
    }
    return NextResponse.next();
  }

  // Root redirect
  if (pathname === '/') {
    if (session?.user?.role) {
      const role = session.user.role;
      return NextResponse.redirect(new URL(`/${role}/dashboard`, request.url));
    }
    return NextResponse.redirect(new URL('/login', request.url));
  }

  // Protected routes - require valid session with user
  if (!session?.user?.role) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  const role = session.user.role;

  // Role-based access control
  if (pathname.startsWith('/owner') && role !== 'owner') {
    return NextResponse.redirect(new URL(`/${role}/dashboard`, request.url));
  }

  if (pathname.startsWith('/admin') && role !== 'admin') {
    return NextResponse.redirect(new URL(`/${role}/dashboard`, request.url));
  }

  if (pathname.startsWith('/tenant') && role !== 'tenant') {
    // Tenant routes don't exist in web, redirect to login with message
    return NextResponse.redirect(new URL('/login?error=tenant_web_not_supported', request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'],
};
