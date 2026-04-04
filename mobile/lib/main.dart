import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'providers/account_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: RentalApp(),
    ),
  );
}

class RentalApp extends ConsumerWidget {
  const RentalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final accountState = ref.watch(accountProvider);
    final currentRole = accountState.currentRole ?? 'tenant';

    return MaterialApp.router(
      title: 'Rental Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(currentRole),
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
