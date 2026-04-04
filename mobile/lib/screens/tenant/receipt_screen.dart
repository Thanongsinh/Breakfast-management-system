import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../widgets/role_aware_scaffold.dart';
import '../../widgets/status_badge.dart';
import '../../providers/payment_provider.dart';
import '../../app/constants.dart';

class ReceiptScreen extends ConsumerStatefulWidget {
  final String paymentId;

  const ReceiptScreen({
    required this.paymentId,
    super.key,
  });

  @override
  ConsumerState<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends ConsumerState<ReceiptScreen> {
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentDetail();
  }

  void _loadPaymentDetail() {
    ref.read(paymentProvider.notifier).loadPaymentById(widget.paymentId);
  }

  Future<void> _downloadReceipt() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      final receiptUrl = await ref
          .read(paymentProvider.notifier)
          .getReceiptUrl(widget.paymentId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Receipt URL: $receiptUrl'),
          backgroundColor: AppConstants.successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download receipt: $e'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);
    final payment = paymentState.selectedPayment;

    return RoleAwareScaffold(
      title: 'Payment Receipt',
      actions: [
        if (payment != null && payment.isConfirmed)
          IconButton(
            icon: _isDownloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            onPressed: _isDownloading ? null : _downloadReceipt,
            tooltip: 'Download PDF',
          ),
      ],
      body: paymentState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : paymentState.error != null
              ? _buildErrorState(paymentState.error!)
              : payment == null
                  ? _buildNotFoundState()
                  : _buildReceiptContent(payment),
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
            onPressed: _loadPaymentDetail,
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
          Text('Receipt not found'),
        ],
      ),
    );
  }

  Widget _buildReceiptContent(payment) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Column(
        children: [
          _buildReceiptHeader(),
          const SizedBox(height: AppConstants.spacingLg),
          _buildReceiptCard(payment),
          const SizedBox(height: AppConstants.spacingLg),
          _buildReceiptFooter(),
        ],
      ),
    );
  }

  Widget _buildReceiptHeader() {
    return Card(
      color: AppConstants.tenantLight,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle,
              size: 64,
              color: AppConstants.successColor,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              'Payment Received',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppConstants.successColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              'Thank you for your payment',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptCard(payment) {
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
                  'Receipt Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                StatusBadge(status: payment.status),
              ],
            ),
            const Divider(height: AppConstants.spacingLg),
            _buildReceiptRow('Receipt ID', payment.id),
            _buildReceiptRow('Bill ID', payment.billId),
            _buildReceiptRow(
              'Payment Date',
              DateFormat(AppConstants.dateFormat).format(payment.paymentDate),
            ),
            _buildReceiptRow(
              'Payment Method',
              _formatPaymentMethod(payment.method),
            ),
            const Divider(height: AppConstants.spacingLg),
            _buildReceiptRow(
              'Amount',
              AppConstants.formatCurrency(payment.amount),
              isHighlight: true,
            ),
            if (payment.confirmedAt != null) ...[
              const Divider(height: AppConstants.spacingLg),
              _buildReceiptRow(
                'Confirmed At',
                DateFormat(AppConstants.dateTimeFormat).format(payment.confirmedAt),
              ),
            ],
            if (payment.confirmedBy != null)
              _buildReceiptRow('Confirmed By', payment.confirmedBy!),
            if (payment.notes != null) ...[
              const Divider(height: AppConstants.spacingLg),
              Text(
                'Notes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                payment.notes!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppConstants.textSecondary,
                ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                    color: isHighlight ? AppConstants.tenantPrimary : AppConstants.textPrimary,
                  ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptFooter() {
    return Card(
      color: AppConstants.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          children: [
            const Icon(
              Icons.info_outline,
              size: 20,
              color: AppConstants.textSecondary,
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              'This is an official receipt for your payment. Please keep it for your records.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppConstants.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              'Generated on ${DateFormat(AppConstants.dateTimeFormat).format(DateTime.now())}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppConstants.textDisabled,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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
