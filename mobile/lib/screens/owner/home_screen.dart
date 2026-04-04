import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../widgets/role_aware_scaffold.dart';
import '../../providers/account_provider.dart';
import '../../providers/building_provider.dart';
import '../../providers/billing_provider.dart';
import '../../providers/maintenance_provider.dart';
import '../../app/constants.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(buildingProvider.notifier).loadBuildings();
      ref.read(billingProvider.notifier).loadBills();
      ref.read(billingProvider.notifier).loadStats();
      ref.read(maintenanceProvider.notifier).loadRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final accountState = ref.watch(accountProvider);
    final buildingState = ref.watch(buildingProvider);
    final billingState = ref.watch(billingProvider);
    final maintenanceState = ref.watch(maintenanceProvider);

    return RoleAwareScaffold(
      title: 'Owner Dashboard',
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(buildingProvider.notifier).loadBuildings();
          await ref.read(billingProvider.notifier).loadBills();
          await ref.read(billingProvider.notifier).loadStats();
          await ref.read(maintenanceProvider.notifier).loadRequests();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(accountState.currentAccount?.name ?? 'Owner'),
              const SizedBox(height: AppConstants.spacingLg),
              _buildStatisticsCards(buildingState, billingState),
              const SizedBox(height: AppConstants.spacingLg),
              _buildQuickActions(context),
              const SizedBox(height: AppConstants.spacingLg),
              _buildRecentActivities(billingState, maintenanceState),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppConstants.ownerPrimary,
        unselectedItemColor: AppConstants.textSecondary,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _navigateToPage(context, index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment),
            label: 'Buildings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Bills',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Maintenance',
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(String name) {
    return Card(
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          gradient: LinearGradient(
            colors: [
              AppConstants.ownerPrimary,
              AppConstants.ownerSecondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingXs),
            Text(
              name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingXs),
            Text(
              DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(BuildingState buildingState, BillingState billingState) {
    final stats = billingState.stats ?? {};
    final monthlyRevenue = stats['monthlyRevenue'] ?? 0.0;
    final pendingPayments = stats['pendingPayments'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Statistics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppConstants.spacingMd,
          crossAxisSpacing: AppConstants.spacingMd,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              icon: Icons.apartment,
              label: 'Total Buildings',
              value: '${buildingState.totalBuildings}',
              color: AppConstants.infoColor,
            ),
            _buildStatCard(
              icon: Icons.meeting_room,
              label: 'Total Rooms',
              value: '${buildingState.totalRooms}',
              color: AppConstants.ownerPrimary,
            ),
            _buildStatCard(
              icon: Icons.check_circle,
              label: 'Occupied Rooms',
              value: '${buildingState.occupiedRooms}',
              color: AppConstants.successColor,
            ),
            _buildStatCard(
              icon: Icons.trending_up,
              label: 'Occupancy Rate',
              value: '${buildingState.averageOccupancy.toStringAsFixed(0)}%',
              color: AppConstants.warningColor,
            ),
            _buildStatCard(
              icon: Icons.attach_money,
              label: 'Monthly Revenue',
              value: AppConstants.formatCurrency(monthlyRevenue),
              color: AppConstants.successColor,
              isLarge: true,
            ),
            _buildStatCard(
              icon: Icons.pending_actions,
              label: 'Pending Payments',
              value: '$pendingPayments',
              color: AppConstants.errorColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isLarge = false,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppConstants.textSecondary,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppConstants.spacingXs),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.receipt_long,
                label: 'View Bills',
                onTap: () => context.push('/owner/billing'),
              ),
            ),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.monetization_on,
                label: 'Payments',
                onTap: () => context.push('/owner/confirm-cash'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.build,
                label: 'Maintenance',
                onTap: () => context.push('/owner/maintenance'),
              ),
            ),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.meeting_room,
                label: 'Rooms',
                onTap: () => context.push('/owner/rooms'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Column(
            children: [
              Icon(
                icon,
                size: 36,
                color: AppConstants.ownerPrimary,
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivities(BillingState billingState, MaintenanceState maintenanceState) {
    final recentBills = billingState.pendingBills.take(3).toList();
    final recentRequests = maintenanceState.pendingRequests.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activities',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        if (billingState.isLoading || maintenanceState.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (recentBills.isEmpty && recentRequests.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.spacingLg),
              child: Text('No recent activities'),
            ),
          )
        else
          Column(
            children: [
              if (recentBills.isNotEmpty) ...[
                _buildActivitySection(
                  title: 'Pending Bills',
                  icon: Icons.receipt_long,
                  color: AppConstants.warningColor,
                  children: recentBills.map((bill) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppConstants.ownerLight,
                        child: Icon(
                          Icons.receipt,
                          color: AppConstants.ownerPrimary,
                          size: 20,
                        ),
                      ),
                      title: Text('${bill.tenantName ?? "Unknown"} - Room ${bill.roomNumber ?? "N/A"}'),
                      subtitle: Text('Due: ${DateFormat(AppConstants.dateFormat).format(bill.dueDate)}'),
                      trailing: Text(
                        AppConstants.formatCurrency(bill.amount),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.ownerPrimary,
                        ),
                      ),
                      onTap: () => context.push('/owner/billing'),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppConstants.spacingMd),
              ],
              if (recentRequests.isNotEmpty)
                _buildActivitySection(
                  title: 'Pending Maintenance',
                  icon: Icons.build,
                  color: AppConstants.errorColor,
                  children: recentRequests.map((request) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppConstants.ownerLight,
                        child: Icon(
                          Icons.build,
                          color: AppConstants.ownerPrimary,
                          size: 20,
                        ),
                      ),
                      title: Text(request.title),
                      subtitle: Text('${request.tenantName ?? "Unknown"} - Room ${request.roomNumber ?? "N/A"}'),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppConstants.textSecondary,
                      ),
                      onTap: () => context.push('/owner/maintenance'),
                    );
                  }).toList(),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildActivitySection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: AppConstants.spacingSm),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  void _navigateToPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        context.push('/owner/rooms');
        break;
      case 2:
        context.push('/owner/billing');
        break;
      case 3:
        context.push('/owner/maintenance');
        break;
    }
  }
}
