import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../widgets/role_aware_scaffold.dart';
import '../../widgets/status_badge.dart';
import '../../providers/maintenance_provider.dart';
import '../../app/constants.dart';

class MaintenanceDetailScreen extends ConsumerStatefulWidget {
  final String requestId;

  const MaintenanceDetailScreen({
    required this.requestId,
    super.key,
  });

  @override
  ConsumerState<MaintenanceDetailScreen> createState() => _MaintenanceDetailScreenState();
}

class _MaintenanceDetailScreenState extends ConsumerState<MaintenanceDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadRequestDetail();
  }

  void _loadRequestDetail() {
    ref.read(maintenanceProvider.notifier).loadRequestById(widget.requestId);
  }

  @override
  Widget build(BuildContext context) {
    final maintenanceState = ref.watch(maintenanceProvider);
    final request = maintenanceState.selectedRequest;

    return RoleAwareScaffold(
      title: 'Request Details',
      body: maintenanceState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : maintenanceState.error != null
              ? _buildErrorState(maintenanceState.error!)
              : request == null
                  ? _buildNotFoundState()
                  : _buildRequestDetails(request),
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
            onPressed: _loadRequestDetail,
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
          Icon(Icons.build, size: 48, color: AppConstants.textDisabled),
          SizedBox(height: AppConstants.spacingMd),
          Text('Request not found'),
        ],
      ),
    );
  }

  Widget _buildRequestDetails(request) {
    return RefreshIndicator(
      onRefresh: () async => _loadRequestDetail(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRequestHeader(request),
            const SizedBox(height: AppConstants.spacingLg),
            _buildRequestInfo(request),
            const SizedBox(height: AppConstants.spacingLg),
            _buildDescriptionSection(request),
            if (request.images.isNotEmpty) ...[
              const SizedBox(height: AppConstants.spacingLg),
              _buildImagesSection(request.images),
            ],
            if (request.scheduledDate != null) ...[
              const SizedBox(height: AppConstants.spacingLg),
              _buildScheduledSection(request),
            ],
            if (request.isCompleted && request.completionNotes != null) ...[
              const SizedBox(height: AppConstants.spacingLg),
              _buildCompletionSection(request),
            ],
            const SizedBox(height: AppConstants.spacingLg),
            _buildTimeline(request),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestHeader(request) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    request.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                StatusBadge(status: request.status),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Row(
              children: [
                _buildInfoChip(
                  _formatCategory(request.category),
                  Icons.category,
                  AppConstants.infoColor,
                ),
                const SizedBox(width: AppConstants.spacingSm),
                _buildInfoChip(
                  _formatPriority(request.priority),
                  Icons.priority_high,
                  _getPriorityColor(request.priority),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppConstants.spacingSm),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestInfo(request) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(height: AppConstants.spacingLg),
            _buildInfoRow('Request ID', request.id),
            _buildInfoRow('Room', request.roomNumber ?? 'N/A'),
            _buildInfoRow(
              'Submitted',
              DateFormat(AppConstants.dateTimeFormat).format(request.createdAt),
            ),
            if (request.assignedTo != null)
              _buildInfoRow('Assigned To', request.assignedTo!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(request) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description, size: 20, color: AppConstants.textSecondary),
                const SizedBox(width: AppConstants.spacingSm),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              request.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection(List<String> images) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.image, size: 20, color: AppConstants.textSecondary),
                const SizedBox(width: AppConstants.spacingSm),
                Text(
                  'Images (${images.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Wrap(
              spacing: AppConstants.spacingSm,
              runSpacing: AppConstants.spacingSm,
              children: images.map((image) {
                return Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppConstants.backgroundColor,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    border: Border.all(color: AppConstants.borderColor),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.image, color: AppConstants.textSecondary),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        image.split('/').last,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledSection(request) {
    return Card(
      color: AppConstants.infoColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Row(
          children: [
            const Icon(Icons.event, color: AppConstants.infoColor),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scheduled',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppConstants.infoColor,
                        ),
                  ),
                  Text(
                    DateFormat(AppConstants.dateTimeFormat).format(request.scheduledDate!),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionSection(request) {
    return Card(
      color: AppConstants.successColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: AppConstants.successColor),
                const SizedBox(width: AppConstants.spacingMd),
                Text(
                  'Completed',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppConstants.successColor,
                      ),
                ),
              ],
            ),
            if (request.completedAt != null) ...[
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                DateFormat(AppConstants.dateTimeFormat).format(request.completedAt!),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              'Completion Notes:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              request.completionNotes!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(request) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status Timeline',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.spacingLg),
            _buildTimelineItem(
              'Request Submitted',
              DateFormat(AppConstants.dateTimeFormat).format(request.createdAt),
              Icons.add_circle,
              AppConstants.infoColor,
              isFirst: true,
            ),
            if (request.scheduledDate != null)
              _buildTimelineItem(
                'Scheduled',
                DateFormat(AppConstants.dateTimeFormat).format(request.scheduledDate!),
                Icons.event,
                AppConstants.warningColor,
              ),
            if (request.completedAt != null)
              _buildTimelineItem(
                'Completed',
                DateFormat(AppConstants.dateTimeFormat).format(request.completedAt!),
                Icons.check_circle,
                AppConstants.successColor,
                isLast: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String timestamp,
    IconData icon,
    Color color, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 20,
                color: AppConstants.borderColor,
              ),
            Icon(icon, color: color, size: 20),
            if (!isLast)
              Container(
                width: 2,
                height: 20,
                color: AppConstants.borderColor,
              ),
          ],
        ),
        const SizedBox(width: AppConstants.spacingMd),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : AppConstants.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppConstants.spacingXs),
                Text(
                  timestamp,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConstants.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatCategory(String category) {
    switch (category.toLowerCase()) {
      case 'plumbing':
        return 'Plumbing';
      case 'electrical':
        return 'Electrical';
      case 'furniture':
        return 'Furniture';
      case 'other':
        return 'Other';
      default:
        return category;
    }
  }

  String _formatPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      case 'urgent':
        return 'Urgent';
      default:
        return priority;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return AppConstants.infoColor;
      case 'medium':
        return AppConstants.warningColor;
      case 'high':
        return Colors.deepOrange;
      case 'urgent':
        return AppConstants.errorColor;
      default:
        return AppConstants.textSecondary;
    }
  }
}
