import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/role_aware_scaffold.dart';
import '../../widgets/bill_card.dart';
import '../../widgets/empty_state.dart';
import '../../providers/billing_provider.dart';
import '../../app/constants.dart';

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  void _loadBills() {
    final status = _selectedStatus == 'all' ? null : _selectedStatus;
    ref.read(billingProvider.notifier).loadBills(status: status);
  }

  @override
  Widget build(BuildContext context) {
    final billingState = ref.watch(billingProvider);

    return RoleAwareScaffold(
      title: 'My Bills',
      body: Column(
        children: [
          _buildFilterChips(),
          const SizedBox(height: AppConstants.spacingSm),
          Expanded(
            child: _buildBillsList(billingState),
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
          _buildFilterChip('Paid', 'paid'),
          _buildFilterChip('Overdue', 'overdue'),
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
          _loadBills();
        },
      ),
    );
  }

  Widget _buildBillsList(BillingState state) {
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
              onPressed: _loadBills,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final bills = state.bills;
    if (bills.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long,
        title: 'No Bills',
        message: 'No bills found',
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadBills(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        itemCount: bills.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spacingMd),
        itemBuilder: (context, index) {
          final bill = bills[index];
          return BillCard(
            bill: bill,
            onTap: () => context.push('/tenant/bill/${bill.id}'),
          );
        },
      ),
    );
  }
}
