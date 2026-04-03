import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@/lib/auth';

export async function middleware(request: NextRequest) {
  const session = await auth();

  // Public routes
  if (request.nextUrl.pathname === '/login') {
    if (session) {
      const role = (session.user as any)?.role;
      if (role === 'owner') {
        return NextResponse.redirect(new URL('/owner/dashboard', request.url));
      } else if (role === 'admin') {
        return NextResponse.redirect(new URL('/admin/dashboard', request.url));
      } else if (role === 'tenant') {
        return NextResponse.redirect(new URL('/tenant/dashboard', request.url));
      }
    }
    return NextResponse.next();
  }

  // Protected routes
  if (!session) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  const role = (session.user as any)?.role;
  const pathname = request.nextUrl.pathname;

  // Role-based route protection
  if (pathname.startsWith('/owner') && role !== 'owner') {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  if (pathname.startsWith('/admin') && role !== 'admin') {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  if (pathname.startsWith('/tenant') && role !== 'tenant') {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'],
};
