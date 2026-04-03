# rental-system v3

ระบบจัดการห้องเช่า — 1 web + 1 mobile app, 3 roles, cash-only payment.

---

## Structure

```
rental-system/
├── CLAUDE.md
├── backend/CLAUDE.md    ← Go/Fiber API
├── web/CLAUDE.md        ← Next.js 14 — 3 roles in 1 app
└── mobile/CLAUDE.md     ← Flutter — owner + tenant, multi-account
```

---

## 3 User roles — 1 web, 1 app

| Role | Web route | Mobile | Color |
|---|---|---|---|
| เจ้าของ (owner) | /owner/* | รองรับ | น้ำเงิน #2563EB |
| ผู้เช่า (tenant) | — (mobile only) | รองรับ | ม่วง #7C3AED |
| Admin | /admin/* | ไม่มี | Indigo #4F46E5 |

Login หน้าเดียว `app.rental.com/login` → redirect ตาม role อัตโนมัติ

---

## Payment — Cash only

- ผู้เช่านำเงินสดมาจ่ายที่สำนักงาน
- เจ้าของ หรือ admin กด "รับเงินสดแล้ว"
- ระบบ generate ใบเสร็จ PDF + ส่ง LINE Notify อัตโนมัติ
- ไม่มี: payment gateway, QR, slip upload

---

## API base

- Owner: `/api/v1/owner/*`
- Tenant: `/api/v1/tenant/*`
- Admin:  `/api/v1/admin/*`
