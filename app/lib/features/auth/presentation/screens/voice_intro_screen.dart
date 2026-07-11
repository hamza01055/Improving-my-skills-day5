import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/navy_blob_background.dart';
import '../../../../core/widgets/pill_field.dart';

/// First screen shown to new users: voice-first hero + auth entry points.
class VoiceIntroScreen extends StatelessWidget {
  const VoiceIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NavyBlobBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        gradient: AppColors.brandGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mic_none_outlined,
                          size: 44, color: Colors.white),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Leave Your Voice Instantly',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Chat, capture notes, and manage tasks by talking to '
                      'your own AI-powered second brain.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 40),
                    PillButton(
                      label: 'CONTINUE WITH GOOGLE',
                      onPressed: () => _showComingSoon(context),
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
                      onPressed: () => context.push(RouteNames.register),
                      child: const Text(
                        'SIGN UP WITH EMAIL',
                        style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.push(RouteNames.login),
                      child: const Text(
                        'Login to existing account',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.push(RouteNames.onboardingAbout),
                      child: const Text(
                        'What is IntelliVault?',
                        style: TextStyle(color: AppColors.navy),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Google sign-in coming soon.')));
  }
}
