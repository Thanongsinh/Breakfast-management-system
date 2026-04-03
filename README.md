# Rental System v3

ระบบจัดการห้องเช่า — Multi-platform rental management system for landlords and tenants in Laos.

## Project Structure

```
rental-v3/
├── backend/     # Go + Fiber REST API
├── web/         # Next.js 14 (Owner & Admin dashboards)
└── mobile/      # Flutter (Owner & Tenant apps)
```

## Tech Stack

### Backend (Go + Fiber)
- **Framework:** Go + Fiber v2
- **Database:** PostgreSQL + GORM
- **Cache:** Redis
- **Storage:** MinIO
- **Auth:** JWT
- **Notifications:** LINE Notify
- **PDF Generation:** gofpdf
- **Excel Export:** excelize
- **Cron Jobs:** robfig/cron v3

### Web (Next.js 14)
- **Framework:** Next.js 14 (App Router)
- **Language:** TypeScript
- **Styling:** Tailwind CSS + shadcn/ui
- **Data Fetching:** TanStack Query v5
- **Forms:** React Hook Form + Zod
- **Charts:** Recharts
- **Auth:** NextAuth v5
- **State:** Zustand

### Mobile (Flutter)
- **Framework:** Flutter 3 + Dart
- **State:** flutter_riverpod
- **Navigation:** go_router
- **HTTP:** dio
- **Secure Storage:** flutter_secure_storage
- **Notifications:** flutter_local_notifications

## Features

### 3 User Roles
- **เจ้าของ (Owner)** - Manage buildings, confirm cash payments, view reports
- **ผู้เช่า (Tenant)** - View bills, pay in person, request maintenance
- **Admin** - Manage owners, view system stats

### Cash-Only Payment System
- No payment gateways or online payments
- Tenants bring cash to the office
- Owner/Admin confirms receipt
- System auto-generates PDF receipt + LINE notification

### Multi-Platform Support
- **Web:** Owner and Admin dashboards
- **Mobile:** Owner and Tenant apps with multi-account support

## Getting Started

### Backend

```bash
cd backend
cp .env.example .env
# Edit .env with your configuration
go mod tidy
go run main.go
```

### Web

```bash
cd web
npm install
cp .env.local.example .env.local
# Edit .env.local with your configuration
npm run dev
```

### Mobile

```bash
cd mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

## Architecture

- **Clean Architecture** - Separated concerns across layers
- **Role-Based Access Control** - Middleware for auth and authorization
- **Multi-Tenancy** - Data isolation per owner
- **RESTful API** - Standardized endpoints for each role

## License

Private project - All rights reserved

## Documentation

See individual CLAUDE.md files in each directory for detailed specifications:
- [backend/CLAUDE.md](backend/CLAUDE.md)
- [web/CLAUDE.md](web/CLAUDE.md)
- [mobile/CLAUDE.md](mobile/CLAUDE.md)
