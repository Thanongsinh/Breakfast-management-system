import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../widgets/role_aware_scaffold.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';
import '../../providers/maintenance_provider.dart';
import '../../app/constants.dart';
import '../../models/maintenance_request.dart';

class MaintenanceScreen extends ConsumerStatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  ConsumerState<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends ConsumerState<MaintenanceScreen> {
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  void _loadRequests() {
    final status = _selectedStatus == 'all' ? null : _selectedStatus;
    ref.read(maintenanceProvider.notifier).loadRequests(status: status);
  }

  @override
  Widget build(BuildContext context) {
    final maintenanceState = ref.watch(maintenanceProvider);

    return RoleAwareScaffold(
      title: 'Maintenance Requests',
      body: Column(
        children: [
          _buildFilterChips(),
          const SizedBox(height: AppConstants.spacingSm),
          Expanded(
            child: _buildRequestsList(maintenanceState),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      child: Row(
        children: [
          _buildFilterChip('All', 'all'),
          _buildFilterChip('Pending', 'pending'),
          _buildFilterChip('In Progress', 'in_progress'),
          _buildFilterChip('Completed', 'completed'),
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
        selectedColor: AppConstants.ownerLight,
        checkmarkColor: AppConstants.ownerPrimary,
        onSelected: (selected) {
          setState(() {
            _selectedStatus = value;
          });
          _loadRequests();
        },
      ),
    );
  }

  Widget _buildRequestsList(MaintenanceState state) {
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
              onPressed: _loadRequests,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final requests = state.requests;
    if (requests.isEmpty) {
      return EmptyState(
        icon: Icons.build_circle_outlined,
        title: 'No Maintenance Requests',
        message: _selectedStatus == 'all'
            ? 'No maintenance requests found'
            : 'No $_selectedStatus maintenance requests',
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadRequests(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        itemCount: requests.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spacingMd),
        itemBuilder: (context, index) {
          final request = requests[index];
          return _buildRequestCard(request);
        },
      ),
    );
  }

  Widget _buildRequestCard(MaintenanceRequest request) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showRequestDetails(request),
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
                    child: Text(
                      request.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  StatusBadge(status: request.status, isCompact: true),
                ],
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: AppConstants.textSecondary,
                  ),
                  const SizedBox(width: AppConstants.spacingXs),
                  Text(
                    request.tenantName ?? 'Unknown',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppConstants.textSecondary,
                        ),
                  ),
                  const SizedBox(width: AppConstants.spacingMd),
                  Icon(
                    Icons.meeting_room,
                    size: 16,
                    color: AppConstants.textSecondary,
                  ),
                  const SizedBox(width: AppConstants.spacingXs),
                  Text(
                    'Room ${request.roomNumber ?? "N/A"}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppConstants.textSecondary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                request.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppConstants.spacingMd),
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.category,
                    label: request.category.toUpperCase(),
                    color: AppConstants.infoColor,
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  _buildInfoChip(
                    icon: Icons.priority_high,
                    label: request.priority.toUpperCase(),
                    color: _getPriorityColor(request.priority),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat(AppConstants.dateFormat).format(request.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppConstants.textSecondary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSm,
        vertical: AppConstants.spacingXs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: AppConstants.spacingXs),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return AppConstants.errorColor;
      case 'high':
        return AppConstants.warningColor;
      case 'medium':
        return AppConstants.infoColor;
      case 'low':
        return AppConstants.successColor;
      default:
        return AppConstants.textSecondary;
    }
  }

  void _showRequestDetails(MaintenanceRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLg)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
                    decoration: BoxDecoration(
                      color: AppConstants.borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
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
                const SizedBox(height: AppConstants.spacingLg),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Tenant', request.tenantName ?? 'Unknown'),
                        _buildDetailRow('Room', request.roomNumber ?? 'N/A'),
                        _buildDetailRow('Category', request.category.toUpperCase()),
                        _buildDetailRow('Priority', request.priority.toUpperCase()),
                        _buildDetailRow(
                          'Submitted',
                          DateFormat(AppConstants.dateTimeFormat).format(request.createdAt),
                        ),
                        const SizedBox(height: AppConstants.spacingMd),
                        const Divider(),
                        const SizedBox(height: AppConstants.spacingMd),
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppConstants.spacingSm),
                        Text(
                          request.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (request.completionNotes != null) ...[
                          const SizedBox(height: AppConstants.spacingMd),
                          const Divider(),
                          const SizedBox(height: AppConstants.spacingMd),
                          Text(
                            'Owner Notes',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: AppConstants.spacingSm),
                          Text(
                            request.completionNotes!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMd),
                if (request.status != 'completed')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _updateStatus(request);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.ownerPrimary,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.spacingMd,
                        ),
                      ),
                      child: Text(_getNextStatusLabel(request.status)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppConstants.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _getNextStatusLabel(String currentStatus) {
    switch (currentStatus) {
      case 'pending':
        return 'Start Working';
      case 'in_progress':
        return 'Mark as Resolved';
      default:
        return 'Update Status';
    }
  }

  Future<void> _updateStatus(MaintenanceRequest request) async {
    String nextStatus;
    switch (request.status) {
      case 'pending':
        nextStatus = 'in_progress';
        break;
      case 'in_progress':
        nextStatus = 'completed';
        break;
      default:
        return;
    }

    try {
      await ref.read(maintenanceProvider.notifier).updateRequest(
            requestId: request.id,
            status: nextStatus,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to ${nextStatus.replaceAll('_', ' ')}'),
          backgroundColor: AppConstants.successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: ${e.toString()}'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }
}
