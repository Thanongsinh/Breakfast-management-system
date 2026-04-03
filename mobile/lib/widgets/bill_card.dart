import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bill.dart';
import '../app/constants.dart';
import 'status_badge.dart';

class BillCard extends StatelessWidget {
  final Bill bill;
  final VoidCallback? onTap;

  const BillCard({
    required this.bill,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: InkWell(
        onTap: onTap,
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
                          'Room ${bill.roomNumber ?? "N/A"}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppConstants.spacingXs),
                        Text(
                          DateFormat(AppConstants.dateFormat).format(bill.billingPeriod),
                          style: Theme.of(context).textTheme.bodyMedium,
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
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        AppConstants.formatCurrency(bill.amount),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppConstants.getPrimaryColor('tenant'),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Due Date',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        DateFormat(AppConstants.dateFormat).format(bill.dueDate),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: bill.isOverdue
                                  ? AppConstants.errorColor
                                  : AppConstants.textPrimary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              if (bill.notes != null) ...[
                const SizedBox(height: AppConstants.spacingSm),
                Text(
                  bill.notes!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
