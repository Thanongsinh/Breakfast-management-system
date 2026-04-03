import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/account_provider.dart';
import '../app/constants.dart';

class RoleAwareScaffold extends ConsumerWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final bool showAccountSwitcher;

  const RoleAwareScaffold({
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.actions,
    this.bottomNavigationBar,
    this.showAccountSwitcher = true,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountState = ref.watch(accountProvider);
    final currentRole = accountState.currentRole ?? 'tenant';
    final primaryColor = AppConstants.getPrimaryColor(currentRole);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (showAccountSwitcher && accountState.hasMultipleAccounts)
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              onPressed: () {
                _showAccountSwitcher(context, ref);
              },
            ),
          if (actions != null) ...actions!,
        ],
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  void _showAccountSwitcher(BuildContext context, WidgetRef ref) {
    // TODO: implement account switcher
  }
}
