import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/pill_field.dart';
import '../../providers/auth_provider.dart';
import '../widgets/auth_scaffold.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String _passwordStrength = '';

  @override
  void initState() {
    super.initState();
    _password.addListener(_updateStrength);
  }

  @override
  void dispose() {
    _password.removeListener(_updateStrength);
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _updateStrength() {
    final text = _password.text;
    String strength = '';
    if (text.isNotEmpty) {
      final hasLetters = RegExp(r'[A-Za-z]').hasMatch(text);
      final hasDigits = RegExp(r'\d').hasMatch(text);
      final hasSymbols = RegExp(r'[^A-Za-z0-9]').hasMatch(text);
      final classes = [hasLetters, hasDigits, hasSymbols].where((c) => c).length;
      if (text.length < 8) {
        strength = 'Weak password';
      } else if (classes >= 2) {
        strength = 'Strong password';
      } else {
        strength = 'Good password';
      }
    }
    setState(() => _passwordStrength = strength);
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Google sign-in coming soon.')));
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authProvider.notifier).register(
            _name.text.trim(),
            _email.text.trim(),
            _password.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    ref.listen(authProvider.select((s) => s.error), (_, error) {
      if (error != null && mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error)));
      }
    });

    return AuthScaffold(
      title: 'Sign up',
      subtitle: 'Your second brain starts here.',
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PillField(
                controller: _name,
                hint: 'Full name',
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                validator: Validators.name,
              ),
              const SizedBox(height: 20),
              PillField(
                controller: _email,
                hint: 'Email',
                icon: Icons.alternate_email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: Validators.email,
              ),
              const SizedBox(height: 20),
              PillField(
                controller: _password,
                hint: 'Password',
                icon: Icons.lock_outline,
                obscure: _obscurePassword,
                textInputAction: TextInputAction.next,
                validator: Validators.password,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.black38,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              if (_passwordStrength.isNotEmpty) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    _passwordStrength,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _passwordStrength == 'Weak password'
                          ? AppColors.error
                          : AppColors.success,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              PillField(
                controller: _confirm,
                hint: 'Confirm password',
                icon: Icons.lock_outline,
                obscure: _obscureConfirm,
                textInputAction: TextInputAction.done,
                validator: (v) =>
                    Validators.confirmPassword(v, _password.text),
                suffix: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.black38,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              const SizedBox(height: 32),
              PillButton(
                label: 'SIGN UP',
                isLoading: auth.isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  side: const BorderSide(color: AppColors.navy),
                  foregroundColor: AppColors.navy,
                ),
                onPressed: _showComingSoon,
                child: const Text(
                  'CONTINUE WITH GOOGLE',
                  style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black54, fontSize: 13),
              children: [
                const TextSpan(text: 'already have an account? '),
                TextSpan(
                  text: 'SIGN IN',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => context.go(RouteNames.login),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
