# rental-system — Web

Next.js 14 + TypeScript.
1 app, 1 URL (app.rental.com), แยก layout และ route ตาม role หลัง login.

---

## Tech stack

| Layer | Technology |
|---|---|
| Framework | Next.js 14 (App Router) |
| Language | TypeScript |
| Styling | Tailwind CSS |
| UI | shadcn/ui |
| Data fetching | TanStack Query v5 |
| Forms | react-hook-form + Zod |
| Charts | Recharts |
| Auth | Auth.js (NextAuth v5) |
| HTTP | axios |
| State | Zustand |
| PDF | react-pdf |
| Excel | xlsx |

---

## Role-based routing

Login → Auth.js อ่าน role จาก JWT → redirect:

| Role | Redirect | Layout |
|---|---|---|
| owner | /owner/dashboard | sidebar น้ำเงิน |
| admin | /admin/dashboard | sidebar indigo |
| tenant | /login (web ไม่รองรับ tenant) | — |

Middleware ป้องกัน: owner เข้า /admin ไม่ได้ และกลับกัน

---

## Design system

```
Owner theme:  #2563EB (blue)    bg: #EFF6FF   text: #1E40AF
Admin theme:  #4F46E5 (indigo)  bg: #EEF2FF   text: #3730A3

Status:
  ok:      #16A34A / #F0FDF4
  warning: #D97706 / #FFFBEB
  danger:  #DC2626 / #FEF2F2
```

---

## Project structure

```
web/
├── middleware.ts              # role guard: redirect by role
├── app/
│   ├── layout.tsx             # root — providers
│   ├── page.tsx               # redirect → /login
│   ├── login/
│   │   └── page.tsx           # 1 login page สำหรับทุก role
│   ├── (owner)/               # route group — owner only
│   │   ├── layout.tsx         # sidebar น้ำเงิน + topbar
│   │   ├── owner/
│   │   │   ├── dashboard/page.tsx
│   │   │   ├── buildings/
│   │   │   │   ├── page.tsx
│   │   │   │   └── [id]/page.tsx
│   │   │   ├── tenants/
│   │   │   │   ├── page.tsx
│   │   │   │   └── [id]/page.tsx
│   │   │   ├── billing/
│   │   │   │   ├── page.tsx
│   │   │   │   └── [id]/page.tsx
│   │   │   ├── payments/page.tsx
│   │   │   ├── maintenance/
│   │   │   │   ├── page.tsx
│   │   │   │   └── [id]/page.tsx
│   │   │   └── reports/page.tsx
│   └── (admin)/               # route group — admin only
│       ├── layout.tsx         # sidebar indigo + topbar
│       ├── admin/
│       │   ├── dashboard/page.tsx
│       │   ├── payments/page.tsx
│       │   ├── owners/
│       │   │   ├── page.tsx
│       │   │   └── [id]/page.tsx
│       │   └── stats/page.tsx
├── components/
│   ├── layout/
│   │   ├── OwnerSidebar.tsx   # nav items สำหรับ owner
│   │   ├── AdminSidebar.tsx   # nav items สำหรับ admin
│   │   └── TopBar.tsx         # shared — แสดง role badge
│   ├── shared/
│   │   ├── RoleBadge.tsx      # owner=blue / admin=indigo pill
│   │   ├── StatCard.tsx
│   │   ├── DataTable.tsx
│   │   ├── StatusBadge.tsx
│   │   └── ConfirmDialog.tsx
│   ├── owner/
│   │   ├── RoomGrid.tsx       # color-coded room tiles
│   │   ├── BillTable.tsx
│   │   ├── ConfirmCashModal.tsx
│   │   └── IncomeChart.tsx
│   └── admin/
│       ├── PendingPaymentsTable.tsx
│       ├── OwnerTable.tsx
│       └── MRRChart.tsx
├── hooks/
│   ├── useRole.ts             # get current role from session
│   ├── owner/
│   │   ├── useDashboard.ts
│   │   ├── useBills.ts
│   │   └── usePayments.ts
│   └── admin/
│       ├── usePendingPayments.ts
│       └── useOwners.ts
├── services/
│   ├── api.ts                 # axios + JWT + role-aware base URL
│   ├── owner/
│   │   ├── bill.service.ts
│   │   └── payment.service.ts
│   └── admin/
│       ├── payment.service.ts
│       └── owner.service.ts
├── types/
│   ├── auth.types.ts          # User { id, name, role, ... }
│   ├── bill.types.ts
│   ├── payment.types.ts
│   └── api.types.ts
└── lib/
    ├── auth.ts                # Auth.js config
    ├── queryClient.ts
    └── utils.ts
```

---

## middleware.ts — role guard

```typescript
export default withAuth(function middleware(req) {
  const role = req.nextauth.token?.role
  const path = req.nextUrl.pathname

  // owner ห้ามเข้า /admin
  if (path.startsWith('/admin') && role !== 'admin') {
    return NextResponse.redirect(new URL('/owner/dashboard', req.url))
  }
  // admin ห้ามเข้า /owner
  if (path.startsWith('/owner') && role !== 'owner') {
    return NextResponse.redirect(new URL('/admin/dashboard', req.url))
  }
}, { pages: { signIn: '/login' } })
```

---

## Login flow

```
POST /login → Auth.js → JWT (role: owner | admin)
  ↓ role === 'owner' → redirect /owner/dashboard  (blue layout)
  ↓ role === 'admin' → redirect /admin/dashboard  (indigo layout)
  ↓ role === 'tenant' → แสดง "กรุณาใช้ mobile app"
```

หน้า login มี 1 form เดียว — ไม่มีปุ่มเลือก role ระบบ detect เองจาก JWT

---

## Owner pages

| Route | Description |
|---|---|
| /owner/dashboard | stat cards, room grid, alerts, income chart |
| /owner/buildings | อาคารทั้งหมด |
| /owner/buildings/[id] | ห้องใน grid — left border color by status |
| /owner/tenants | รายชื่อผู้เช่า |
| /owner/billing | บิลทั้งหมด |
| /owner/billing/[id] | รายละเอียดบิล + ปุ่ม "รับเงินสดแล้ว" |
| /owner/payments | ประวัติรับเงิน |
| /owner/maintenance | รายการแจ้งซ่อม |
| /owner/reports | รายงาน + export Excel |

---

## Admin pages

| Route | Description |
|---|---|
| /admin/dashboard | owner count, ห้องรวม, MRR, ค้างชำระ |
| /admin/payments | รายการค้างชำระทุก owner — update สถานะได้ |
| /admin/owners | owner accounts — activate/suspend |
| /admin/owners/[id] | รายละเอียด owner |
| /admin/stats | MRR trend, usage |

---

## ConfirmCashModal

```typescript
// owner และ admin ใช้ modal เดียวกัน
interface ConfirmCashPaymentRequest {
  billId: number
  amount: number    // จำนวนเงินที่รับจริง
  note?: string
}
// POST /api/v1/owner/payments/confirm-cash  (owner)
// POST /api/v1/admin/payments/confirm-cash  (admin)
// หลัง confirm: PDF generate + LINE Notify อัตโนมัติ
```

---

## Room grid color coding

```
ok      → border-left: 3px solid #16A34A
warning → border-left: 3px solid #D97706
danger  → border-left: 3px solid #DC2626
empty   → border-left: 3px solid #D1D5DB, opacity: 0.7
```

---

## Coding conventions

- Server Components by default
- `'use client'` เฉพาะ interactive components
- Services แยกโฟลเดอร์ owner/ และ admin/
- ไม่มี cross-role imports: owner hooks ไม่ import admin services
- Zod schema ใน file เดียวกับ form
- Currency: `formatCurrency(amount, 'LAK')`
- Date: `formatDate(date, 'DD/MM/YYYY')`
- No `any` — TypeScript strict mode

---

## Environment variables

```env
NEXT_PUBLIC_API_URL=http://localhost:8080
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=
```
