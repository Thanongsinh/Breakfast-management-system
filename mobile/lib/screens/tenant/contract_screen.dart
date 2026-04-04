import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../widgets/role_aware_scaffold.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';
import '../../providers/contract_provider.dart';
import '../../app/constants.dart';

class ContractScreen extends ConsumerStatefulWidget {
  const ContractScreen({super.key});

  @override
  ConsumerState<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends ConsumerState<ContractScreen> {
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _loadContracts();
  }

  void _loadContracts() {
    ref.read(contractProvider.notifier).loadContracts();
  }

  Future<void> _downloadContract(String contractId, String? pdfUrl) async {
    if (pdfUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF not available for this contract'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Contract PDF: $pdfUrl'),
          backgroundColor: AppConstants.successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download contract: $e'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final contractState = ref.watch(contractProvider);

    return RoleAwareScaffold(
      title: 'My Contract',
      body: contractState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : contractState.error != null
              ? _buildErrorState(contractState.error!)
              : _buildContractContent(contractState),
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
            onPressed: _loadContracts,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContractContent(ContractState state) {
    final activeContracts = state.activeContracts;

    if (activeContracts.isEmpty) {
      return const EmptyState(
        icon: Icons.description,
        title: 'No Active Contract',
        message: 'You do not have an active contract at the moment',
      );
    }

    final contract = activeContracts.first;

    return RefreshIndicator(
      onRefresh: () async => _loadContracts(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContractHeader(contract),
            const SizedBox(height: AppConstants.spacingLg),
            _buildContractDetails(contract),
            const SizedBox(height: AppConstants.spacingLg),
            _buildFinancialInfo(contract),
            const SizedBox(height: AppConstants.spacingLg),
            _buildContractPeriod(contract),
            if (contract.terms != null) ...[
              const SizedBox(height: AppConstants.spacingLg),
              _buildTermsSection(contract.terms!),
            ],
            const SizedBox(height: AppConstants.spacingLg),
            _buildDownloadSection(contract),
          ],
        ),
      ),
    );
  }

  Widget _buildContractHeader(contract) {
    return Card(
      color: AppConstants.tenantLight,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
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
                        'Rental Contract',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppConstants.tenantPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        'Room ${contract.roomNumber ?? "N/A"}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: contract.status),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMd),
            if (contract.daysUntilExpiry > 0 && contract.daysUntilExpiry <= 30)
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingSm),
                decoration: BoxDecoration(
                  color: AppConstants.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  border: Border.all(color: AppConstants.warningColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, size: 16, color: AppConstants.warningColor),
                    const SizedBox(width: AppConstants.spacingSm),
                    Expanded(
                      child: Text(
                        'Contract expires in ${contract.daysUntilExpiry} days',
                        style: const TextStyle(
                          color: AppConstants.warningColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContractDetails(contract) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contract Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(height: AppConstants.spacingLg),
            _buildDetailRow('Contract ID', contract.id),
            _buildDetailRow('Room', contract.roomNumber ?? 'N/A'),
            _buildDetailRow('Tenant', contract.tenantName ?? 'N/A'),
            _buildDetailRow(
              'Start Date',
              DateFormat(AppConstants.dateFormat).format(contract.startDate),
            ),
            _buildDetailRow(
              'End Date',
              DateFormat(AppConstants.dateFormat).format(contract.endDate),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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

  Widget _buildFinancialInfo(contract) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(height: AppConstants.spacingLg),
            _buildFinancialRow(
              'Monthly Rent',
              contract.monthlyRent,
              isHighlight: true,
            ),
            _buildFinancialRow('Security Deposit', contract.deposit),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRow(String label, double amount, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                ),
          ),
          Text(
            AppConstants.formatCurrency(amount),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isHighlight ? AppConstants.tenantPrimary : AppConstants.textPrimary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractPeriod(contract) {
    final now = DateTime.now();
    final totalDays = contract.endDate.difference(contract.startDate).inDays;
    final daysElapsed = now.difference(contract.startDate).inDays;
    final progress = (daysElapsed / totalDays).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contract Period',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.spacingLg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat(AppConstants.dateFormat).format(contract.startDate),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  DateFormat(AppConstants.dateFormat).format(contract.endDate),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingSm),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppConstants.borderColor,
              color: contract.daysUntilExpiry < 30
                  ? AppConstants.warningColor
                  : AppConstants.tenantPrimary,
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              contract.daysUntilExpiry > 0
                  ? '${contract.daysUntilExpiry} days remaining'
                  : 'Expired',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: contract.daysUntilExpiry < 30
                        ? AppConstants.warningColor
                        : AppConstants.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsSection(String terms) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.article, size: 20, color: AppConstants.textSecondary),
                const SizedBox(width: AppConstants.spacingSm),
                Text(
                  'Terms & Conditions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              terms,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadSection(contract) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.picture_as_pdf, size: 20, color: AppConstants.textSecondary),
                const SizedBox(width: AppConstants.spacingSm),
                Text(
                  'Contract Document',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMd),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isDownloading
                    ? null
                    : () => _downloadContract(contract.id, contract.pdfUrl),
                icon: _isDownloading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download),
                label: Text(_isDownloading ? 'Downloading...' : 'Download PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.tenantPrimary,
                  padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingMd),
                ),
              ),
            ),
            if (contract.pdfUrl == null)
              Padding(
                padding: const EdgeInsets.only(top: AppConstants.spacingSm),
                child: Text(
                  'PDF document is not available yet',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConstants.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
