import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../widgets/role_aware_scaffold.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';
import '../../providers/payment_provider.dart';
import '../../app/constants.dart';

class PaymentHistoryScreen extends ConsumerStatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  ConsumerState<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  void _loadPayments() {
    final status = _selectedStatus == 'all' ? null : _selectedStatus;
    ref.read(paymentProvider.notifier).loadPayments(status: status);
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);

    return RoleAwareScaffold(
      title: 'Payment History',
      body: Column(
        children: [
          _buildFilterChips(),
          const SizedBox(height: AppConstants.spacingSm),
          Expanded(
            child: _buildPaymentsList(paymentState),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
      child: Row(
        children: [
          _buildFilterChip('All', 'all'),
          _buildFilterChip('Confirmed', 'confirmed'),
          _buildFilterChip('Pending', 'pending'),
          _buildFilterChip('Rejected', 'rejected'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedStatus == value;
    return Padding(
      padding: const EdgeInsets.only(right: AppConstants.spacingSm),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedStatus = value;
          });
          _loadPayments();
        },
      ),
    );
  }

  Widget _buildPaymentsList(PaymentState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppConstants.errorColor),
            const SizedBox(height: AppConstants.spacingMd),
            Text(state.error!),
            const SizedBox(height: AppConstants.spacingMd),
            ElevatedButton(
              onPressed: _loadPayments,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final payments = state.payments;
    if (payments.isEmpty) {
      return const EmptyState(
        icon: Icons.payment,
        title: 'No Payments',
        message: 'You have no payment history yet',
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadPayments(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        itemCount: payments.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spacingMd),
        itemBuilder: (context, index) {
          final payment = payments[index];
          return _buildPaymentCard(payment);
        },
      ),
    );
  }

  Widget _buildPaymentCard(payment) {
    return Card(
      child: InkWell(
        onTap: () {
          if (payment.isConfirmed) {
            context.push('/tenant/payments/${payment.id}/receipt');
          }
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
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
                          AppConstants.formatCurrency(payment.amount),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppConstants.tenantPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppConstants.spacingXs),
                        Text(
                          DateFormat(AppConstants.dateFormat).format(payment.paymentDate),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: payment.status),
                ],
              ),
              const Divider(height: AppConstants.spacingLg),
              Row(
                children: [
                  Icon(
                    _getPaymentMethodIcon(payment.method),
                    size: 16,
                    color: AppConstants.textSecondary,
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  Text(
                    _formatPaymentMethod(payment.method),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              if (payment.notes != null) ...[
                const SizedBox(height: AppConstants.spacingSm),
                Text(
                  payment.notes!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConstants.textSecondary,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (payment.isConfirmed) ...[
                const SizedBox(height: AppConstants.spacingSm),
                Row(
                  children: [
                    const Icon(
                      Icons.receipt,
                      size: 16,
                      color: AppConstants.successColor,
                    ),
                    const SizedBox(width: AppConstants.spacingSm),
                    Text(
                      'View Receipt',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppConstants.successColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: AppConstants.spacingXs),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppConstants.successColor,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'bank_transfer':
        return Icons.account_balance;
      case 'e-wallet':
        return Icons.wallet;
      default:
        return Icons.payment;
    }
  }

  String _formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Cash';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'e-wallet':
        return 'E-Wallet';
      default:
        return method;
    }
  }
}
