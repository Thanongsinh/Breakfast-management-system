import 'package:flutter/material.dart';
import '../app/constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isCompact;

  const StatusBadge({
    required this.status,
    this.isCompact = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppConstants.getStatusColor(status);
    final label = _formatStatus(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? AppConstants.spacingSm : AppConstants.spacingMd,
        vertical: isCompact ? AppConstants.spacingXs : AppConstants.spacingSm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: isCompact ? 11 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'paid':
        return 'Paid';
      case 'overdue':
        return 'Overdue';
      case 'cancelled':
        return 'Cancelled';
      case 'confirmed':
        return 'Confirmed';
      case 'rejected':
        return 'Rejected';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'active':
        return 'Active';
      case 'expired':
        return 'Expired';
      case 'terminated':
        return 'Terminated';
      default:
        return status.toUpperCase();
    }
  }
}
