import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menumia_flutter_partner_app/app/providers/providers.dart';
import 'package:menumia_flutter_partner_app/utils/app_logger.dart';

/// Login page with Google authentication
///
/// This page provides a UI for users to login with their Google account.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  static final _logger = AppLogger('LoginPage');
  bool _loading = false;
  String? _error;

  /// Handle Google Login
  Future<void> _signInWithGoogle() async {
    final logCtx = _logger.createContext();
    _logger.info('Attempting Google Sign-In', logCtx);
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithGoogle();
      _logger.success('Google Sign-In service call completed', logCtx);
      // Navigation is handled automatically by AuthGate
    } catch (e, stack) {
      _logger.error('Google Sign-In failed', e, stack, logCtx);
      setState(() => _error = e.toString());
    } finally {

      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo or title
              Icon(
                Icons.restaurant_menu,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Menumia Partner',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                     ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your restaurant with ease',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Error message
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Sign-in button
              FilledButton.icon(
                onPressed: _loading ? null : _signInWithGoogle,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.login),
                label: Text(_loading ? 'Logging in...' : 'Login with Google'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
