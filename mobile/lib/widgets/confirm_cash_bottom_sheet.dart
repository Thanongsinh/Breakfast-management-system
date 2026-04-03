import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/constants.dart';
import '../providers/payment_provider.dart';

class ConfirmCashBottomSheet extends ConsumerStatefulWidget {
  final String billId;
  final double amount;

  const ConfirmCashBottomSheet({
    required this.billId,
    required this.amount,
    super.key,
  });

  @override
  ConsumerState<ConfirmCashBottomSheet> createState() => _ConfirmCashBottomSheetState();
}

class _ConfirmCashBottomSheetState extends ConsumerState<ConfirmCashBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  DateTime _paymentDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppConstants.spacingLg,
        right: AppConstants.spacingLg,
        top: AppConstants.spacingLg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppConstants.spacingLg,
      ),
      decoration: const BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXl),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Confirm Cash Payment',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              'Amount: ${AppConstants.formatCurrency(widget.amount)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppConstants.ownerPrimary,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Payment Date'),
              subtitle: Text(
                '${_paymentDate.day}/${_paymentDate.month}/${_paymentDate.year}',
              ),
              onTap: _selectDate,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add any notes about this payment',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppConstants.spacingLg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmPayment,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Confirm Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _paymentDate = pickedDate;
      });
    }
  }

  Future<void> _confirmPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(paymentProvider.notifier).createPayment(
            billId: widget.billId,
            amount: widget.amount,
            method: 'cash',
            paymentDate: _paymentDate,
            notes: _notesController.text.trim(),
          );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cash payment confirmed successfully'),
            backgroundColor: AppConstants.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

void showConfirmCashBottomSheet(
  BuildContext context, {
  required String billId,
  required double amount,
}) {
  showModalBottomSheet(
    context: context,
    builder: (context) => ConfirmCashBottomSheet(
      billId: billId,
      amount: amount,
    ),
    isScrollControlled: true,
  );
}
