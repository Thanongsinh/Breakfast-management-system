import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/account_provider.dart';
import '../providers/auth_provider.dart';
import '../app/constants.dart';
import 'account_switcher_sheet.dart';

class RoleAwareScaffold extends ConsumerWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final List<Widget>? actions;

  const RoleAwareScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountState = ref.watch(accountProvider);
    final currentAccount = accountState.currentAccount;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (actions != null) ...actions!,
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                currentAccount?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: TextStyle(
                  color: AppConstants.getPrimaryColor(
                    currentAccount?.role ?? 'tenant',
                  ),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onSelected: (value) {
              switch (value) {
                case 'switch_account':
                  _showAccountSwitcher(context);
                  break;
                case 'logout':
                  _logout(context, ref);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'switch_account',
                child: Row(
                  children: [
                    const Icon(Icons.swap_horiz),
                    const SizedBox(width: AppConstants.spacingSm),
                    Text('Switch Account'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: AppConstants.errorColor),
                    const SizedBox(width: AppConstants.spacingSm),
                    const Text(
                      'Logout',
                      style: TextStyle(color: AppConstants.errorColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  void _showAccountSwitcher(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AccountSwitcherSheet(),
    );
  }

  void _logout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
