import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../widgets/role_aware_scaffold.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';
import '../../providers/billing_provider.dart';
import '../../providers/payment_provider.dart';
import '../../app/constants.dart';
import '../../models/bill.dart';

class ConfirmCashScreen extends ConsumerStatefulWidget {
  const ConfirmCashScreen({super.key});

  @override
  ConsumerState<ConfirmCashScreen> createState() => _ConfirmCashScreenState();
}

class _ConfirmCashScreenState extends ConsumerState<ConfirmCashScreen> {
  @override
  void initState() {
    super.initState();
    _loadPendingCashPayments();
  }

  void _loadPendingCashPayments() {
    // Load bills with pending cash payment status
    ref.read(billingProvider.notifier).loadBills(status: 'pending');
    ref.read(paymentProvider.notifier).loadPayments(status: 'pending');
  }

  @override
  Widget build(BuildContext context) {
    final billingState = ref.watch(billingProvider);

    // Filter for pending cash payments
    final pendingCashBills = billingState.bills.where((bill) {
      return bill.isPending && bill.paymentMethod == 'cash';
    }).toList();

    return RoleAwareScaffold(
      title: 'Confirm Cash Payments',
      body: _buildPaymentsList(billingState, pendingCashBills),
    );
  }

  Widget _buildPaymentsList(BillingState state, List<Bill> bills) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppConstants.errorColor,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppConstants.textSecondary),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            ElevatedButton(
              onPressed: _loadPendingCashPayments,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (bills.isEmpty) {
      return const EmptyState(
        icon: Icons.check_circle_outline,
        title: 'No Pending Cash Payments',
        message: 'All cash payments have been confirmed',
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadPendingCashPayments(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        itemCount: bills.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spacingMd),
        itemBuilder: (context, index) {
          final bill = bills[index];
          return _buildPaymentCard(bill);
        },
      ),
    );
  }

  Widget _buildPaymentCard(Bill bill) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bill.tenantName ?? 'Unknown Tenant',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        'Room ${bill.roomNumber ?? "N/A"}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppConstants.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: bill.status),
              ],
            ),
            const Divider(height: AppConstants.spacingLg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppConstants.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppConstants.spacingXs),
                    Text(
                      AppConstants.formatCurrency(bill.amount),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppConstants.ownerPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Paid Date',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppConstants.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppConstants.spacingXs),
                    Text(
                      bill.paidAt != null
                          ? DateFormat(AppConstants.dateFormat).format(bill.paidAt!)
                          : 'Not paid yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ],
            ),
            if (bill.notes != null) ...[
              const SizedBox(height: AppConstants.spacingMd),
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                decoration: BoxDecoration(
                  color: AppConstants.ownerLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.note,
                      size: 16,
                      color: AppConstants.textSecondary,
                    ),
                    const SizedBox(width: AppConstants.spacingSm),
                    Expanded(
                      child: Text(
                        bill.notes!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppConstants.spacingMd),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _confirmPayment(bill),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.successColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spacingMd,
                  ),
                ),
                icon: const Icon(Icons.check_circle),
                label: const Text('Confirm Cash Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmPayment(Bill bill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Cash Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Confirm cash payment received from:'),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              bill.tenantName ?? 'Unknown Tenant',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.spacingXs),
            Text(
              'Amount: ${AppConstants.formatCurrency(bill.amount)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            const Text(
              'This will mark the bill as paid and generate a receipt.',
              style: TextStyle(
                fontSize: 12,
                color: AppConstants.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processConfirmation(bill);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.successColor,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _processConfirmation(Bill bill) async {
    try {
      // Create payment confirmation
      await ref.read(paymentProvider.notifier).confirmPayment(
            paymentId: bill.id,
            status: 'confirmed',
            notes: 'Cash payment confirmed by owner',
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: AppConstants.spacingSm),
              Expanded(
                child: Text(
                  'Payment confirmed for ${bill.tenantName ?? "tenant"}',
                ),
              ),
            ],
          ),
          backgroundColor: AppConstants.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Reload the list
      _loadPendingCashPayments();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: AppConstants.spacingSm),
              Expanded(
                child: Text('Error confirming payment: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: AppConstants.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
