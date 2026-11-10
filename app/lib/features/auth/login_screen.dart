import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_service.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _busy = false;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final auth = ref.read(authServiceProvider)!;
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    try {
      if (_register) {
        final needsConfirmation = await auth.signUp(email: _email.text.trim(), password: _password.text);
        if (needsConfirmation && mounted) {
          setState(() => _info = 'Check your inbox to confirm your e-mail, then sign in.');
        }
      } else {
        await auth.signIn(email: _email.text.trim(), password: _password.text);
      }
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reset() async {
    final email = _email.text.trim();
    if (!email.contains('@')) {
      setState(() => _error = 'Enter your e-mail first.');
      return;
    }
    try {
      await ref.read(authServiceProvider)!.sendPasswordReset(email);
      if (mounted) setState(() => _info = 'If an account exists, a reset link has been sent.');
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SsSpace.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.anchor, color: SsColors.accent, size: 36),
                  const SizedBox(height: SsSpace.lg),
                  Text(
                    'SEA SPACE',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(letterSpacing: 4),
                  ),
                  const SizedBox(height: SsSpace.xs),
                  Text(
                    'Maritime Career Intelligence',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: SsSpace.xxl),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid e-mail' : null,
                  ),
                  const SizedBox(height: SsSpace.md),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (v) => (v == null || v.length < (_register ? 8 : 1))
                        ? (_register ? 'At least 8 characters' : 'Enter your password')
                        : null,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: SsSpace.md),
                    Text(_error!, style: const TextStyle(color: SsColors.danger)),
                  ],
                  if (_info != null) ...[
                    const SizedBox(height: SsSpace.md),
                    Text(_info!, style: const TextStyle(color: SsColors.success)),
                  ],
                  const SizedBox(height: SsSpace.xl),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_register ? 'Create account' : 'Sign in'),
                  ),
                  const SizedBox(height: SsSpace.sm),
                  TextButton(
                    onPressed: _busy ? null : () => setState(() => _register = !_register),
                    child: Text(
                      _register ? 'Already have an account? Sign in' : 'New to SEA SPACE? Create an account',
                    ),
                  ),
                  if (!_register)
                    TextButton(onPressed: _busy ? null : _reset, child: const Text('Forgot password?')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
