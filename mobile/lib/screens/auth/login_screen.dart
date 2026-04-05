import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/account_provider.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import '../../app/constants.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.apartment,
                    size: 80,
                    color: AppConstants.tenantPrimary,
                  ),
                  const SizedBox(height: AppConstants.spacingLg),
                  Text(
                    'Rental Management',
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  Text(
                    'Sign in to continue',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacingXl),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingXl),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Call auth service to get login result (accounts + user)
      print('DEBUG: Calling auth service login');
      final authService = ref.read(authServiceProvider);
      final loginResult = await authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      print('DEBUG: Login successful');

      // Step 2: Load accounts into accountProvider
      print('DEBUG: Loading accounts into accountProvider');
      await ref.read(accountProvider.notifier).loadAccounts();

      final accountState = ref.read(accountProvider);
      print('DEBUG: Accounts loaded - count: ${accountState.accounts.length}');
      print('DEBUG: Current account: ${accountState.currentAccount?.email}, role: ${accountState.currentAccount?.role}');

      // Step 3: Set user FIRST so isAuthenticated becomes true
      print('DEBUG: Setting user in authProvider');
      final user = loginResult['user'] as User;
      ref.read(authProvider.notifier).setUser(user);
      print('DEBUG: User set, isAuthenticated = ${ref.read(authProvider).isAuthenticated}');

      // Step 4: Navigate after auth state is set
      if (mounted && accountState.currentAccount != null) {
        final role = accountState.currentAccount!.role;
        print('DEBUG: Navigating to home for role: $role');

        // Use pushReplacement to prevent back navigation to login
        if (role == 'owner' || role == 'admin') {
          print('DEBUG: Going to /owner/home');
          context.go('/owner/home');
        } else if (role == 'tenant') {
          print('DEBUG: Going to /tenant/home');
          context.go('/tenant/home');
        }
      } else {
        print('DEBUG: ERROR - Cannot navigate: mounted=$mounted, account=${accountState.currentAccount}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
