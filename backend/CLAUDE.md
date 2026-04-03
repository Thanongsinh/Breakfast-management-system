# rental-system — Backend

Go / Fiber REST API. รองรับ web-owner, web-admin, และ Flutter mobile.
Cash-only — ไม่มี payment gateway ใดๆ.

---

## Tech stack

| Layer | Technology |
|---|---|
| Framework | Go + Fiber v2 |
| ORM | GORM |
| Database | PostgreSQL |
| Cache | Redis |
| Storage | MinIO |
| Auth | JWT (golang-jwt/jwt) |
| PDF | gofpdf |
| Excel | excelize |
| Logging | Zap (uber-go/zap) |
| Scheduler | robfig/cron v3 |
| Config | Viper (config.yaml + ENV override) |
| LINE Notify | HTTP client |

---

## Project structure

```
backend/
├── main.go
├── config.yaml
├── api/
│   ├── controllers/
│   │   ├── auth.controller.go
│   │   ├── building.controller.go
│   │   ├── room.controller.go
│   │   ├── tenant.controller.go
│   │   ├── contract.controller.go
│   │   ├── bill.controller.go
│   │   ├── payment.controller.go      # cash confirm only — no gateway
│   │   ├── maintenance.controller.go
│   │   ├── report.controller.go
│   │   ├── admin.controller.go
│   │   └── notification.controller.go
│   ├── middleware/
│   │   ├── auth.middleware.go
│   │   ├── role.middleware.go
│   │   ├── tenant_scope.middleware.go  # CRITICAL: owner sees only own data
│   │   ├── ratelimit.middleware.go
│   │   ├── logger.middleware.go
│   │   └── cors.middleware.go
│   └── routes/
│       ├── auth.route.go
│       ├── owner.route.go
│       ├── tenant.route.go
│       ├── admin.route.go
│       └── router.go
├── bootstrap/
│   ├── app.go
│   ├── config.go       # Viper: config.yaml + ENV override
│   ├── database.go
│   ├── redis.go
│   └── minio.go
├── core/
│   ├── logs/logger.go
│   └── utilities/
│       ├── response.go
│       ├── pagination.go
│       ├── pdf.go          # ใบเสร็จ + สัญญา PDF
│       └── excel.go
├── data/
│   ├── repositories/
│   │   ├── user.repository.go
│   │   ├── building.repository.go
│   │   ├── room.repository.go
│   │   ├── tenant.repository.go
│   │   ├── contract.repository.go
│   │   ├── bill.repository.go
│   │   ├── payment.repository.go
│   │   └── maintenance.repository.go
│   └── services/
│       ├── auth.service.go
│       ├── building.service.go
│       ├── room.service.go
│       ├── tenant.service.go
│       ├── contract.service.go
│       ├── bill.service.go
│       ├── payment.service.go      # ConfirmCashPayment → PDF → LINE
│       ├── maintenance.service.go
│       ├── notification.service.go # LINE Notify only
│       ├── report.service.go
│       ├── storage.service.go
│       └── cron.service.go
└── domain/
    ├── entites/
    │   ├── user.entity.go
    │   ├── building.entity.go
    │   ├── room.entity.go
    │   ├── tenant.entity.go
    │   ├── contract.entity.go
    │   ├── bill.entity.go
    │   ├── payment.entity.go       # cash only: amount, confirmed_by, note
    │   └── maintenance.entity.go
    └── models/
        ├── auth.model.go
        ├── building.model.go
        ├── room.model.go
        ├── bill.model.go
        ├── payment.model.go        # ConfirmCashPaymentRequest
        ├── maintenance.model.go
        ├── dashboard.model.go
        ├── report.model.go
        └── pagination.model.go
```

---

## Database entities

### users
```go
ID           uint
Name         string
Email        string   `gorm:"unique"`
PasswordHash string
Role         string   // owner | tenant | admin
Phone        string
LineUserID   string
CreatedAt    time.Time
UpdatedAt    time.Time
```

### buildings
```go
ID          uint
OwnerID     uint
Name        string
Address     string
TotalFloors int
Images      pq.StringArray
```

### rooms
```go
ID         uint
BuildingID uint
Number     string
Floor      int
Type       string   // single | double | studio
SizeSqm    float64
RentPrice  float64
Status     string   // available | occupied | maintenance
Images     pq.StringArray
```

### tenants
```go
ID               uint
UserID           uint
RoomID           uint
ContractID       uint
EmergencyContact string
IDCardNumber     string
MoveInDate       time.Time
```

### contracts
```go
ID         uint
RoomID     uint
TenantID   uint
StartDate  time.Time
EndDate    time.Time
RentAmount float64
Deposit    float64
PDFPath    string
Status     string   // active | expired | terminated
```

### bills
```go
ID             uint
TenantID       uint
RoomID         uint
Month          int
Year           int
RentAmount     float64
WaterUnit      float64
WaterPrice     float64
ElectricUnit   float64
ElectricPrice  float64
OtherFees      float64
OtherFeesNote  string
Total          float64
DueDate        time.Time
Status         string   // unpaid | paid | overdue
```

### payments (cash only)
```go
ID             uint
BillID         uint
TenantID       uint
Amount         float64    // จำนวนเงินที่รับจริง
PaidAt         time.Time
ConfirmedBy    uint       // owner หรือ admin user_id
ReceiptPDFPath string
Note           string     // หมายเหตุ เช่น "จ่ายแบ่ง 2 ครั้ง"
```

### maintenance_requests
```go
ID          uint
RoomID      uint
TenantID    uint
Title       string
Description string
Images      pq.StringArray
Status      string   // pending | in_progress | done
Priority    string   // low | medium | high
ResolvedAt  *time.Time
```

---

## Cash payment flow

```
1. ระบบ generate บิลอัตโนมัติวันที่ 1 ของเดือน (cron)
2. LINE Notify แจ้งผู้เช่า — ยอดบิลและวันครบกำหนด
3. ผู้เช่านำเงินสดมาจ่ายที่สำนักงาน
4. เจ้าของ/admin กด "รับเงินสดแล้ว" → ระบุจำนวน + หมายเหตุ
5. ระบบ generate ใบเสร็จ PDF (async goroutine)
6. LINE Notify ส่งใบเสร็จให้ผู้เช่าอัตโนมัติ
```

`payment.service.go` — `ConfirmCashPayment(req, confirmedBy)`:
1. Update bill status → paid
2. Create payment record
3. `go func() { generatePDF(); uploadMinIO(); sendLINE() }()`

---

## API endpoints

### Auth
```
POST /api/v1/auth/login
POST /api/v1/auth/logout
POST /api/v1/auth/refresh
GET  /api/v1/auth/profile
```

### Owner `/api/v1/owner/*`
```
GET  /dashboard
GET/POST/PUT/DELETE /buildings
GET/POST/PUT/DELETE /buildings/:id/rooms
POST /rooms/:id/images
PUT  /rooms/:id/status
GET/POST/PUT/DELETE /tenants
POST /contracts
GET  /contracts/:id/pdf
GET  /bills
POST /bills/generate          ← generate รายเดือน (manual หรือ cron)
GET  /bills/:id
POST /payments/confirm-cash   ← รับเงินสด (cash only)
GET  /payments
GET  /payments/:id/receipt
GET/PUT /maintenance
GET  /reports/income
GET  /reports/unpaid
GET  /reports/export
```

### Tenant `/api/v1/tenant/*`
```
GET  /dashboard
GET  /bills
GET  /bills/:id
GET  /payments
GET  /payments/:id/receipt
POST /maintenance
GET  /maintenance
GET  /maintenance/:id
POST /maintenance/:id/images
GET  /contracts/current
GET  /contracts/:id/pdf
```

### Admin `/api/v1/admin/*`
```
GET  /dashboard
GET  /payments/pending        ← รายการค้างชำระทุก owner
POST /payments/confirm-cash   ← admin update แทนเจ้าของได้
GET  /owners
PUT  /owners/:id/status
GET  /stats/mrr
```

---

## Config pattern (Viper)

```yaml
# config.yaml — commit ได้ ไม่มี secret
server:
  port: "8080"
  env: development
database:
  host: localhost
  port: "5432"
  user: postgres
  password: ""        # override: DATABASE_PASSWORD
  name: rental_db
  sslmode: disable
redis:
  host: localhost
  port: "6379"
  password: ""        # override: REDIS_PASSWORD
minio:
  endpoint: localhost:9000
  access_key: ""      # override: MINIO_ACCESSKEY
  secret_key: ""      # override: MINIO_SECRETKEY
  use_ssl: false
jwt:
  secret: ""          # override: JWT_SECRET
  access_expire_hours: 24
  refresh_expire_days: 30
line:
  notify_token: ""    # override: LINE_NOTIFYTOKEN
billing:
  water_rate_per_unit: 5.0
  electric_rate_per_unit: 1000.0
  due_day: 5
cron:
  bill_generate:  "0 0 1 * *"
  reminder_first: "0 9 25 * *"
  reminder_final: "0 9 28 * *"
```

ENV override: `database.password` → `DATABASE_PASSWORD` (AutomaticEnv + replacer)

---

## Alert thresholds (default)

| Metric | Warning | Critical |
|---|---|---|
| CPU load1 | >1.5 | >2.5 |
| RAM usage | >80% | >90% |
| Bill overdue | >3 days | >7 days |
| Host unreachable | >2 min | >5 min |

---

## Coding conventions

- Controller: thin — validate, call service, return response
- Service: business logic ทั้งหมด
- Repository: DB queries เท่านั้น
- ใช้ `core/utilities/response.go` ทุก JSON response
- ใช้ Zap logger ทุก log — ห้าม fmt.Println
- Error bubble up to controller — services return `(result, error)`
- GORM soft delete (deleted_at) สำหรับ room/tenant/contract
- Pagination ทุก list endpoint: `?page=1&limit=20`
- ห้าม raw SQL — ใช้ GORM parameterized queries เสมอ

---

## Standard response

```json
{ "success": true, "data": {...} }
{ "success": true, "data": [...], "pagination": {...} }
{ "success": false, "error": "message" }
```

---

## Error codes

| HTTP | When |
|---|---|
| 400 | Invalid input |
| 401 | Missing/invalid JWT |
| 403 | Wrong role or not owner of resource |
| 404 | Not found |
| 409 | Duplicate (bill already generated) |
| 500 | Internal error — log with Zap |
