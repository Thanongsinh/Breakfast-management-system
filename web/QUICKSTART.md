# Rental-v3 Web Application - Quick Start Guide

## Prerequisites

- Node.js 18+ installed
- Backend API running on `http://localhost:8080`
- npm or yarn package manager

## Installation & Setup

### 1. Install Dependencies

```bash
cd "d:\New folder (12)\rental-v3\web"
npm install
```

### 2. Configure Environment

Create `.env.local` file:

```bash
# Copy from example
cp .env.example .env.local
```

Edit `.env.local`:

```env
# Backend API URL
NEXT_PUBLIC_API_URL=http://localhost:8080/api/v1

# NextAuth Configuration
NEXTAUTH_URL=http://localhost:3000

# Generate a secret key (use: openssl rand -base64 32)
NEXTAUTH_SECRET=your-secure-random-secret-here
```

### 3. Run Development Server

```bash
npm run dev
```

Application will be available at: **http://localhost:3000**

## Default Login

The application will redirect to `/login` on first visit.

### Test Credentials (Backend Dependent)

**Owner Account:**
```
Email: owner@example.com
Password: password123
```

**Admin Account:**
```
Email: admin@example.com
Password: password123
```

## Application Structure

### Owner Portal (`/owner/*`)
- **Dashboard** - Overview statistics and recent payments
- **Buildings** - Manage properties and rooms
- **Tenants** - Manage tenants and contracts
- **Billing** - Generate and manage bills
- **Payments** - Confirm cash payments and view history
- **Maintenance** - Track maintenance requests
- **Reports** - Financial reports and analytics

### Admin Portal (`/admin/*`)
- **Dashboard** - System-wide statistics
- **Owners** - Manage owner accounts
- **Payments** - Review pending payments
- **Stats** - MRR tracking and detailed statistics

## Key Features

### Authentication Flow
1. User logs in at `/login`
2. NextAuth validates credentials with backend API
3. JWT session created with user role
4. Middleware redirects to role-specific dashboard
5. All API calls automatically include JWT token

### Role-Based Access
- **Owner** → Blue theme, access to `/owner/*` routes
- **Admin** → Indigo theme, access to `/admin/*` routes
- **Tenant** → Blocked on web (mobile app only)

### Data Fetching
- All data fetched using TanStack Query
- Automatic caching and refetching
- Optimistic updates on mutations
- Loading and error states handled

## Development Commands

```bash
# Development server with hot reload
npm run dev

# Build for production
npm run build

# Start production server
npm start

# Type checking
npm run type-check

# Linting
npm run lint
```

## Production Build

```bash
# 1. Build the application
npm run build

# 2. Test production build locally
npm start

# 3. Deploy to your hosting platform
# Follow your platform's deployment guide
```

## Environment Variables

### Required
- `NEXT_PUBLIC_API_URL` - Backend API base URL
- `NEXTAUTH_URL` - Your web application URL
- `NEXTAUTH_SECRET` - Secret key for JWT signing

### Optional
- `NODE_ENV` - Environment (development/production)

## Troubleshooting

### "Invalid credentials" error
- Check if backend API is running
- Verify `NEXT_PUBLIC_API_URL` is correct
- Check backend API CORS settings

### "Unauthorized" errors
- Check if `NEXTAUTH_SECRET` is set
- Verify JWT token is being sent in requests
- Check backend API authentication

### Build errors
- Run `npm install` to ensure all dependencies are installed
- Check TypeScript errors: `npm run type-check`
- Clear Next.js cache: `rm -rf .next`

### Styling issues
- Clear browser cache
- Check if Tailwind CSS is properly configured
- Verify `globals.css` is imported in `app/layout.tsx`

## Project Structure Overview

```
web/
├── app/                    # Next.js 14 App Router
│   ├── (owner)/           # Owner routes (blue theme)
│   ├── (admin)/           # Admin routes (indigo theme)
│   ├── login/             # Login page
│   └── api/               # API routes
├── components/            # React components
│   ├── layout/           # Sidebar, TopBar
│   ├── shared/           # Reusable components
│   ├── owner/            # Owner-specific components
│   └── admin/            # Admin-specific components
├── hooks/                # Custom React hooks
│   ├── owner/           # Owner hooks
│   └── admin/           # Admin hooks
├── services/            # API service layer
│   ├── owner/          # Owner services
│   └── admin/          # Admin services
├── types/              # TypeScript type definitions
├── lib/                # Utility libraries
│   ├── auth.ts        # NextAuth configuration
│   ├── utils.ts       # Helper functions
│   └── queryClient.ts # TanStack Query client
└── middleware.ts      # Route protection

```

## API Integration

All API calls go through the `api` instance which:
- Adds JWT token automatically
- Handles errors globally
- Uses TypeScript types
- Returns properly typed responses

Example:
```typescript
import * as billService from '@/services/owner/bill.service';

// Fetch bills with filters
const bills = await billService.getBills({ status: 'unpaid' });

// Generate bills
await billService.generateBills(12, 2024);
```

## Next Steps

1. ✅ Backend API must be running
2. ✅ Configure environment variables
3. ✅ Run development server
4. ✅ Login with test credentials
5. ✅ Explore owner or admin portals
6. ✅ Test features (billing, payments, etc.)

## Support

For issues or questions:
1. Check IMPLEMENTATION_SUMMARY.md for detailed documentation
2. Review backend API documentation
3. Check browser console for errors
4. Verify environment variables

## Production Deployment

### Recommended Platforms
- **Vercel** (recommended for Next.js)
- **Netlify**
- **AWS Amplify**
- **Docker** (self-hosted)

### Deployment Checklist
- [ ] Set production `NEXTAUTH_SECRET`
- [ ] Configure production `NEXT_PUBLIC_API_URL`
- [ ] Set production `NEXTAUTH_URL`
- [ ] Enable CORS on backend for your domain
- [ ] Test all features in production environment
- [ ] Set up monitoring and error tracking

---

**Status: Ready for Development & Production! 🚀**
