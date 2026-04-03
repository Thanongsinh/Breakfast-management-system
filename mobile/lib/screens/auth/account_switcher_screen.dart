import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/account_provider.dart';
import '../../models/account.dart';
import '../../app/constants.dart';

class AccountSwitcherScreen extends ConsumerWidget {
  const AccountSwitcherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountState = ref.watch(accountProvider);
    final accounts = accountState.accounts;
    final currentAccount = accountState.currentAccount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Switch Account'),
        backgroundColor: AppConstants.tenantPrimary,
      ),
      body: accounts.isEmpty
          ? const Center(
              child: Text('No accounts available'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                final isSelected = currentAccount?.id == account.id;

                return _buildAccountCard(
                  context,
                  ref,
                  account,
                  isSelected: isSelected,
                );
              },
            ),
    );
  }

  Widget _buildAccountCard(
    BuildContext context,
    WidgetRef ref,
    Account account, {
    required bool isSelected,
  }) {
    final primaryColor = AppConstants.getPrimaryColor(account.role);

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: InkWell(
        onTap: isSelected
            ? null
            : () => _switchAccount(context, ref, account),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: isSelected ? primaryColor : AppConstants.borderColor,
                child: Icon(
                  account.isOwner ? Icons.business : Icons.person,
                  color: isSelected ? Colors.white : AppConstants.textSecondary,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                    ),
                    const SizedBox(height: AppConstants.spacingXs),
                    Text(
                      account.isOwner
                          ? 'Property Owner'
                          : 'Tenant - Room ${account.room ?? "N/A"}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (account.building != null) ...[
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        'Building: ${account.building}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: primaryColor,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _switchAccount(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) async {
    await ref.read(accountProvider.notifier).switchAccount(account);

    if (context.mounted) {
      final route = account.isOwner ? '/owner/home' : '/tenant/home';
      context.go(route);
    }
  }
}
