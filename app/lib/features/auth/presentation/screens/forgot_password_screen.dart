import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/pill_field.dart';
import '../../providers/auth_provider.dart';
import '../widgets/auth_scaffold.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      final ok = await ref
          .read(authProvider.notifier)
          .forgotPassword(_email.text.trim());
      if (ok && mounted) setState(() => _sent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    if (_sent) {
      return AuthScaffold(
        title: 'Check email',
        subtitle:
            'If an account exists for ${_email.text.trim()}, a reset link is on its way.',
        children: [
          PillButton(
            label: 'BACK TO SIGN IN',
            onPressed: () => context.pop(),
          ),
        ],
      );
    }

    return AuthScaffold(
      title: 'Reset password',
      subtitle: "Enter your email and we'll send you a reset link.",
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PillField(
                controller: _email,
                hint: 'Email',
                icon: Icons.alternate_email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                validator: Validators.email,
              ),
              const SizedBox(height: 32),
              PillButton(
                label: 'SEND RESET LINK',
                isLoading: auth.isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: const Text(
                    'Back to sign in',
                    style: TextStyle(color: AppColors.navy),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
