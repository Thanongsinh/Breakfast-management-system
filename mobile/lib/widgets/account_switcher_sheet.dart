import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/account.dart';
import '../providers/account_provider.dart';
import '../app/constants.dart';

class AccountSwitcherSheet extends ConsumerWidget {
  const AccountSwitcherSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountState = ref.watch(accountProvider);
    final accounts = accountState.accounts;
    final currentAccount = accountState.currentAccount;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: const BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Switch Account',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),
          ...accounts.map((account) => _buildAccountTile(
                context,
                ref,
                account,
                isSelected: currentAccount?.id == account.id,
              )),
          const SizedBox(height: AppConstants.spacingMd),
        ],
      ),
    );
  }

  Widget _buildAccountTile(
    BuildContext context,
    WidgetRef ref,
    Account account, {
    required bool isSelected,
  }) {
    final primaryColor = AppConstants.getPrimaryColor(account.role);

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSelected ? primaryColor : AppConstants.borderColor,
          child: Icon(
            account.isOwner ? Icons.business : Icons.person,
            color: isSelected ? Colors.white : AppConstants.textSecondary,
          ),
        ),
        title: Text(
          account.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        subtitle: Text(
          account.isOwner ? 'Owner' : 'Tenant - Room ${account.room ?? "N/A"}',
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: primaryColor)
            : null,
        onTap: isSelected
            ? null
            : () {
                ref.read(accountProvider.notifier).switchAccount(account);
                Navigator.pop(context);
              },
      ),
    );
  }
}

void showAccountSwitcherSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => const AccountSwitcherSheet(),
    isScrollControlled: true,
  );
}
