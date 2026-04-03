# rental-system — Mobile (Flutter)

Flutter 3 — รองรับ 2 roles: เจ้าของ (owner) และ ผู้เช่า (tenant).
1 แอพ, multi-account switcher, สีแยกตาม role.
Cash-only: ไม่มี in-app payment.

---

## Tech stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3 + Dart |
| State | flutter_riverpod |
| Navigation | go_router |
| HTTP | dio |
| Secure storage | flutter_secure_storage |
| Notifications | flutter_local_notifications |
| Image picker | image_picker |
| PDF viewer | flutter_pdfview |
| Cache | cached_network_image |
| Date | intl |

---

## Multi-account system

แอพเดียวรองรับหลาย account ต่างกันได้:
- ผู้เช่าหลายคนในครอบครัวใช้เครื่องเดียวกัน
- เจ้าของที่มีหลาย account
- ผู้เช่า 1 คน + เจ้าของ 1 คน ในเครื่องเดียวกันก็ได้

### Secure storage keys
```dart
'accounts_list'         // JSON: [{id, name, role, room, building}]
'token_{userId}'        // JWT access token
'refresh_{userId}'      // JWT refresh token
'active_user_id'        // active account ID
```

### สลับ account
1. กด avatar มุมขวาบน → AccountSwitcherSheet (bottom sheet)
2. เลือก account → update `active_user_id` → reload providers
3. App bar สีเปลี่ยนตาม role ของ account ที่เลือก
4. "+ เพิ่มบัญชีใหม่" → LoginScreen → save token → กลับมา

---

## Color per role

```dart
const ownerPrimary  = Color(0xFF2563EB); // น้ำเงิน
const ownerLight    = Color(0xFFEFF6FF);
const ownerDark     = Color(0xFF1E40AF);

const tenantPrimary = Color(0xFF7C3AED); // ม่วง
const tenantLight   = Color(0xFFF5F3FF);
const tenantDark    = Color(0xFF5B21B6);

Color get primaryColor =>
  currentUser.role == 'owner' ? ownerPrimary : tenantPrimary;
```

---

## Project structure

```
mobile/
├── pubspec.yaml
└── lib/
    ├── main.dart
    ├── app/
    │   ├── router.dart          # GoRouter แยก branch ตาม role
    │   ├── theme.dart           # dynamic theme by role
    │   └── constants.dart
    ├── screens/
    │   ├── auth/
    │   │   ├── login_screen.dart
    │   │   └── account_switcher_screen.dart
    │   ├── tenant/
    │   │   ├── home_screen.dart
    │   │   ├── billing_screen.dart
    │   │   ├── bill_detail_screen.dart
    │   │   ├── payment_history_screen.dart
    │   │   ├── receipt_screen.dart
    │   │   ├── maintenance_screen.dart
    │   │   ├── maintenance_form_screen.dart
    │   │   ├── maintenance_detail_screen.dart
    │   │   └── contract_screen.dart
    │   └── owner/
    │       ├── home_screen.dart
    │       ├── billing_screen.dart
    │       ├── confirm_cash_screen.dart
    │       ├── maintenance_screen.dart
    │       └── room_screen.dart
    ├── widgets/
    │   ├── account_switcher_sheet.dart
    │   ├── role_aware_scaffold.dart  # app bar สีตาม role
    │   ├── bill_card.dart
    │   ├── status_badge.dart
    │   ├── confirm_cash_bottom_sheet.dart
    │   └── empty_state.dart
    ├── providers/
    │   ├── auth_provider.dart        # active user + role
    │   ├── account_provider.dart     # account list + switcher
    │   ├── billing_provider.dart
    │   ├── payment_provider.dart
    │   ├── maintenance_provider.dart
    │   └── contract_provider.dart
    ├── services/
    │   ├── api_client.dart           # dio + active user JWT
    │   ├── auth_service.dart
    │   ├── storage_service.dart      # multi-account token store
    │   ├── billing_service.dart
    │   ├── payment_service.dart
    │   └── maintenance_service.dart
    └── models/
        ├── account.dart              # { id, name, role, room, building }
        ├── user.dart
        ├── bill.dart
        ├── payment.dart
        ├── maintenance_request.dart
        └── contract.dart
```

---

## Router

```dart
GoRouter(
  redirect: (ctx, state) {
    final user = ref.read(authProvider);
    if (user == null) return '/login';
    if (state.fullPath == '/') {
      return user.role == 'owner' ? '/owner/home' : '/tenant/home';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/login'),
    GoRoute(path: '/accounts'),     // switcher
    ShellRoute(                     // tenant shell
      builder: (_, __, child) => TenantShell(child: child),
      routes: [
        GoRoute(path: '/tenant/home'),
        GoRoute(path: '/tenant/billing'),
        GoRoute(path: '/tenant/billing/:id'),
        GoRoute(path: '/tenant/payments'),
        GoRoute(path: '/tenant/payments/:id/receipt'),
        GoRoute(path: '/tenant/maintenance'),
        GoRoute(path: '/tenant/maintenance/new'),
        GoRoute(path: '/tenant/maintenance/:id'),
        GoRoute(path: '/tenant/contract'),
      ],
    ),
    ShellRoute(                     // owner shell
      builder: (_, __, child) => OwnerShell(child: child),
      routes: [
        GoRoute(path: '/owner/home'),
        GoRoute(path: '/owner/billing'),
        GoRoute(path: '/owner/billing/:id/confirm'),
        GoRoute(path: '/owner/maintenance'),
        GoRoute(path: '/owner/maintenance/:id'),
      ],
    ),
  ],
)
```

---

## Tenant screens

| Screen | Route | Description |
|---|---|---|
| Home | /tenant/home | บิลเดือนนี้, สถานะ, ประวัติล่าสุด |
| Billing | /tenant/billing | รายละเอียดบิล, วันครบกำหนด |
| Bill detail | /tenant/billing/:id | ค่าเช่า + น้ำ + ไฟ + "นำเงินสดมาจ่าย" |
| History | /tenant/payments | ประวัติการชำระ |
| Receipt | /tenant/payments/:id/receipt | PDF viewer |
| Maintenance | /tenant/maintenance | รายการแจ้งซ่อม |
| New maintenance | /tenant/maintenance/new | แจ้งซ่อม + รูปภาพ |
| Contract | /tenant/contract | สัญญาเช่า + PDF |

**ไม่มีปุ่มจ่ายเงินในแอพ** — แสดงแค่ยอดและคำแนะนำ

---

## Owner screens

| Screen | Route | Description |
|---|---|---|
| Home | /owner/home | ห้องว่าง, ค้างชำระ, รายได้, แจ้งซ่อม |
| Billing | /owner/billing | บิลทั้งหมด + ปุ่ม "รับเงินสด" |
| Confirm cash | /owner/billing/:id/confirm | form: จำนวน + หมายเหตุ |
| Maintenance | /owner/maintenance | รายการ + อัพเดทสถานะ |

---

## Bottom navigation per role

Tenant (4 items): หน้าแรก · บิล · ประวัติ · ซ่อม

Owner (4 items): หน้าแรก · บิล · ซ่อม · ตั้งค่า

---

## Coding conventions

- ใช้ `AsyncValue` จาก Riverpod ทุก async state
- API calls ผ่าน `services/` เสมอ
- JWT เก็บใน `flutter_secure_storage` เท่านั้น
- Navigation ผ่าน `go_router` เท่านั้น
- Image: `cached_network_image`
- Currency: `NumberFormat.currency(locale: 'lo_LA', symbol: '₭')`
- Error: catch `DioException` → แสดงผ่าน snackbar

---

## Build

```bash
flutter run --dart-define=API_BASE_URL=https://api.rental.com

# build
flutter build apk --dart-define=API_BASE_URL=https://api.rental.com
flutter build ios --dart-define=API_BASE_URL=https://api.rental.com
```
