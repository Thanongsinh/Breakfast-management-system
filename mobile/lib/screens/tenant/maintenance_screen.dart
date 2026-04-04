import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../widgets/role_aware_scaffold.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';
import '../../providers/maintenance_provider.dart';
import '../../app/constants.dart';

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
      title: 'Maintenance',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tenant/maintenance/new'),
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
        backgroundColor: AppConstants.tenantPrimary,
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
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
            const Icon(Icons.error_outline, size: 48, color: AppConstants.errorColor),
            const SizedBox(height: AppConstants.spacingMd),
            Text(state.error!),
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
        icon: Icons.build,
        title: 'No Maintenance Requests',
        message: 'You have no maintenance requests yet',
        actionLabel: 'Create Request',
        onAction: () => context.push('/tenant/maintenance/new'),
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

  Widget _buildRequestCard(request) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/tenant/maintenance/${request.id}'),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  StatusBadge(status: request.status, isCompact: true),
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
                  _buildChip(
                    _formatCategory(request.category),
                    Icons.category,
                    AppConstants.infoColor,
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  _buildChip(
                    _formatPriority(request.priority),
                    Icons.priority_high,
                    _getPriorityColor(request.priority),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMd),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppConstants.textSecondary,
                  ),
                  const SizedBox(width: AppConstants.spacingXs),
                  Text(
                    DateFormat(AppConstants.dateFormat).format(request.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppConstants.textSecondary,
                        ),
                  ),
                  if (request.images.isNotEmpty) ...[
                    const Spacer(),
                    const Icon(
                      Icons.image,
                      size: 14,
                      color: AppConstants.textSecondary,
                    ),
                    const SizedBox(width: AppConstants.spacingXs),
                    Text(
                      '${request.images.length} ${request.images.length == 1 ? 'image' : 'images'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppConstants.textSecondary,
                          ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSm,
        vertical: AppConstants.spacingXs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: AppConstants.spacingXs),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
