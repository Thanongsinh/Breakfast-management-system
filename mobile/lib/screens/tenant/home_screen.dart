import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/role_aware_scaffold.dart';
import '../../providers/account_provider.dart';
import '../../providers/billing_provider.dart';
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
      ref.read(billingProvider.notifier).loadBills();
    });
  }

  @override
  Widget build(BuildContext context) {
    final accountState = ref.watch(accountProvider);

    return RoleAwareScaffold(
      title: 'Tenant Dashboard',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(accountState.currentAccount?.name ?? 'Tenant'),
            const SizedBox(height: AppConstants.spacingLg),
            _buildQuickActions(context),
            const SizedBox(height: AppConstants.spacingLg),
            _buildRecentBills(context),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
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
            icon: Icon(Icons.receipt_long),
            label: 'Bills',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Maintenance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Contract',
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(String name) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              name,
              style: Theme.of(context).textTheme.headlineSmall,
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
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.receipt_long,
                label: 'View Bills',
                onTap: () => context.push('/tenant/billing'),
              ),
            ),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.build,
                label: 'Maintenance',
                onTap: () => context.push('/tenant/maintenance'),
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Column(
            children: [
              Icon(
                icon,
                size: 40,
                color: AppConstants.tenantPrimary,
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentBills(BuildContext context) {
    final billingState = ref.watch(billingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Bills',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppConstants.spacingMd),
        if (billingState.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (billingState.bills.isEmpty)
          const Center(child: Text('No bills available'))
        else
          ...billingState.bills.take(3).map((bill) => ListTile(
                title: Text('Bill for ${bill.billingPeriod}'),
                subtitle: Text(AppConstants.formatCurrency(bill.amount)),
                trailing: Text(bill.status),
                onTap: () => context.push('/tenant/bill/${bill.id}'),
              )),
      ],
    );
  }

  void _navigateToPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        context.push('/tenant/billing');
        break;
      case 2:
        context.push('/tenant/maintenance');
        break;
      case 3:
        context.push('/tenant/contract');
        break;
    }
  }
}
