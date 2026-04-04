import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      title: 'Bills Management',
      body: Column(
        children: [
          _buildFilterChips(),
          const SizedBox(height: AppConstants.spacingSm),
          Expanded(
            child: _buildBillsList(billingState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showGenerateBillsDialog,
        backgroundColor: AppConstants.ownerPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Generate Bills'),
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
        selectedColor: AppConstants.ownerLight,
        checkmarkColor: AppConstants.ownerPrimary,
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
              onPressed: _loadBills,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final bills = state.bills;
    if (bills.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long,
        title: 'No Bills Found',
        message: _selectedStatus == 'all'
            ? 'No bills have been generated yet'
            : 'No $_selectedStatus bills found',
        actionLabel: 'Generate Bills',
        onAction: _showGenerateBillsDialog,
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
            onTap: () => _showBillDetails(bill.id),
          );
        },
      ),
    );
  }

  void _showBillDetails(String billId) {
    // Navigate to bill details or show bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLg)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
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
                Text(
                  'Bill Details',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppConstants.spacingLg),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: const Center(
                      child: Text('Bill details will be displayed here'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showGenerateBillsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Bills'),
        content: const Text(
          'Generate bills for all occupied rooms for the current month?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _generateBills();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.ownerPrimary,
            ),
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _generateBills() {
    // Implement bill generation logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bills generated successfully'),
        backgroundColor: AppConstants.successColor,
      ),
    );
    _loadBills();
  }
}
