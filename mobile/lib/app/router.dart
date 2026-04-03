import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/account_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/account_switcher_screen.dart';
import '../screens/tenant/home_screen.dart' as tenant;
import '../screens/tenant/billing_screen.dart' as tenant;
import '../screens/tenant/bill_detail_screen.dart';
import '../screens/tenant/payment_history_screen.dart';
import '../screens/tenant/receipt_screen.dart';
import '../screens/tenant/maintenance_screen.dart' as tenant;
import '../screens/tenant/maintenance_form_screen.dart';
import '../screens/tenant/maintenance_detail_screen.dart';
import '../screens/tenant/contract_screen.dart';
import '../screens/owner/home_screen.dart' as owner;
import '../screens/owner/billing_screen.dart' as owner;
import '../screens/owner/confirm_cash_screen.dart';
import '../screens/owner/maintenance_screen.dart' as owner;
import '../screens/owner/room_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final accountState = ref.watch(accountProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final currentRole = accountState.currentRole;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isAuthenticated && !isLoginRoute) {
        return '/login';
      }

      if (isAuthenticated && isLoginRoute) {
        if (currentRole == 'owner') {
          return '/owner/home';
        } else if (currentRole == 'tenant') {
          return '/tenant/home';
        }
      }

      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/account-switcher',
        builder: (context, state) => const AccountSwitcherScreen(),
      ),

      // Tenant Routes
      GoRoute(
        path: '/tenant/home',
        builder: (context, state) => const tenant.HomeScreen(),
      ),
      GoRoute(
        path: '/tenant/billing',
        builder: (context, state) => const tenant.BillingScreen(),
      ),
      GoRoute(
        path: '/tenant/bill/:id',
        builder: (context, state) {
          final billId = state.pathParameters['id']!;
          return BillDetailScreen(billId: billId);
        },
      ),
      GoRoute(
        path: '/tenant/payment-history',
        builder: (context, state) => const PaymentHistoryScreen(),
      ),
      GoRoute(
        path: '/tenant/receipt/:id',
        builder: (context, state) {
          final paymentId = state.pathParameters['id']!;
          return ReceiptScreen(paymentId: paymentId);
        },
      ),
      GoRoute(
        path: '/tenant/maintenance',
        builder: (context, state) => const tenant.MaintenanceScreen(),
      ),
      GoRoute(
        path: '/tenant/maintenance/new',
        builder: (context, state) => const MaintenanceFormScreen(),
      ),
      GoRoute(
        path: '/tenant/maintenance/:id',
        builder: (context, state) {
          final requestId = state.pathParameters['id']!;
          return MaintenanceDetailScreen(requestId: requestId);
        },
      ),
      GoRoute(
        path: '/tenant/contract',
        builder: (context, state) => const ContractScreen(),
      ),

      // Owner Routes
      GoRoute(
        path: '/owner/home',
        builder: (context, state) => const owner.HomeScreen(),
      ),
      GoRoute(
        path: '/owner/billing',
        builder: (context, state) => const owner.BillingScreen(),
      ),
      GoRoute(
        path: '/owner/confirm-cash',
        builder: (context, state) => const ConfirmCashScreen(),
      ),
      GoRoute(
        path: '/owner/maintenance',
        builder: (context, state) => const owner.MaintenanceScreen(),
      ),
      GoRoute(
        path: '/owner/rooms',
        builder: (context, state) => const RoomScreen(),
      ),
    ],
  );
});
