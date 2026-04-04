import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../widgets/role_aware_scaffold.dart';
import '../../widgets/status_badge.dart';
import '../../providers/billing_provider.dart';
import '../../app/constants.dart';

class BillDetailScreen extends ConsumerStatefulWidget {
  final String billId;

  const BillDetailScreen({
    required this.billId,
    super.key,
  });

  @override
  ConsumerState<BillDetailScreen> createState() => _BillDetailScreenState();
}

class _BillDetailScreenState extends ConsumerState<BillDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadBillDetail();
  }

  void _loadBillDetail() {
    ref.read(billingProvider.notifier).loadBillById(widget.billId);
  }

  @override
  Widget build(BuildContext context) {
    final billingState = ref.watch(billingProvider);
    final bill = billingState.selectedBill;

    return RoleAwareScaffold(
      title: 'Bill Details',
      body: billingState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : billingState.error != null
              ? _buildErrorState(billingState.error!)
              : bill == null
                  ? _buildNotFoundState()
                  : _buildBillDetails(bill),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppConstants.errorColor),
          const SizedBox(height: AppConstants.spacingMd),
          Text(error),
          const SizedBox(height: AppConstants.spacingMd),
          ElevatedButton(
            onPressed: _loadBillDetail,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 48, color: AppConstants.textDisabled),
          SizedBox(height: AppConstants.spacingMd),
          Text('Bill not found'),
        ],
      ),
    );
  }

  Widget _buildBillDetails(bill) {
    return RefreshIndicator(
      onRefresh: () async => _loadBillDetail(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBillHeader(bill),
            const SizedBox(height: AppConstants.spacingLg),
            _buildBillSummary(bill),
            const SizedBox(height: AppConstants.spacingLg),
            _buildBillBreakdown(bill),
            if (bill.notes != null) ...[
              const SizedBox(height: AppConstants.spacingLg),
              _buildNotesSection(bill.notes!),
            ],
            const SizedBox(height: AppConstants.spacingLg),
            _buildPaymentInstructions(bill),
          ],
        ),
      ),
    );
  }

  Widget _buildBillHeader(bill) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Room ${bill.roomNumber ?? "N/A"}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                StatusBadge(status: bill.status),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppConstants.textSecondary),
                const SizedBox(width: AppConstants.spacingSm),
                Text(
                  'Billing Period: ${DateFormat(AppConstants.dateFormat).format(bill.billingPeriod)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Row(
              children: [
                Icon(
                  Icons.event,
                  size: 16,
                  color: bill.isOverdue ? AppConstants.errorColor : AppConstants.textSecondary,
                ),
                const SizedBox(width: AppConstants.spacingSm),
                Text(
                  'Due Date: ${DateFormat(AppConstants.dateFormat).format(bill.dueDate)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: bill.isOverdue ? AppConstants.errorColor : AppConstants.textPrimary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillSummary(bill) {
    return Card(
      color: AppConstants.tenantLight,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Amount',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppConstants.tenantPrimary,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              AppConstants.formatCurrency(bill.amount),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppConstants.tenantPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillBreakdown(bill) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bill Breakdown',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(height: AppConstants.spacingLg),
            if (bill.rentAmount != null)
              _buildBreakdownItem('Rent', bill.rentAmount),
            if (bill.electricityAmount != null)
              _buildBreakdownItem('Electricity', bill.electricityAmount),
            if (bill.waterAmount != null)
              _buildBreakdownItem('Water', bill.waterAmount),
            if (bill.otherAmount != null)
              _buildBreakdownItem('Other Charges', bill.otherAmount),
            const Divider(height: AppConstants.spacingLg),
            _buildBreakdownItem('Total', bill.amount, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownItem(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                ),
          ),
          Text(
            AppConstants.formatCurrency(amount),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  color: isTotal ? AppConstants.tenantPrimary : AppConstants.textPrimary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(String notes) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.note, size: 20, color: AppConstants.textSecondary),
                const SizedBox(width: AppConstants.spacingSm),
                Text(
                  'Notes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              notes,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInstructions(bill) {
    if (bill.isPaid) {
      return Card(
        color: AppConstants.successColor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: AppConstants.successColor),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Received',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppConstants.successColor,
                          ),
                    ),
                    if (bill.paidAt != null)
                      Text(
                        'Paid on ${DateFormat(AppConstants.dateFormat).format(bill.paidAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: AppConstants.infoColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: AppConstants.infoColor),
                const SizedBox(width: AppConstants.spacingMd),
                Text(
                  'Payment Instructions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppConstants.infoColor,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              'Please bring cash payment to the office during business hours.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              'Office Hours: Monday - Friday, 9:00 AM - 5:00 PM',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppConstants.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
