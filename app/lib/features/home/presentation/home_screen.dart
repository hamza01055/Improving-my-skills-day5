import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../auth/providers/auth_provider.dart';

class _Feature {
  const _Feature(this.icon, this.title, this.subtitle, this.route);
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
}

const _features = [
  _Feature(Icons.chat_bubble_outline, 'AI Chat',
      'Ask anything, get grounded answers', RouteNames.chat),
  _Feature(Icons.description_outlined, 'Documents',
      'Upload files, chat with them', RouteNames.documents),
  _Feature(Icons.edit_note_outlined, 'Notes',
      'Capture, rewrite, summarize', RouteNames.notes),
  _Feature(Icons.check_circle_outline, 'Tasks',
      'AI-prioritized to-dos', RouteNames.tasks),
  _Feature(Icons.mic_none_outlined, 'Voice',
      'Speak to your second brain', RouteNames.voice),
  _Feature(Icons.settings_outlined, 'Settings',
      'Theme, account, and more', RouteNames.settings),
];

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider.select((s) => s.user));
    final String firstName =
        (user?.name.split(' ').first ?? 'there').trim();

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: false,
                title: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.psychology_outlined,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text('Second Brain'),
                  ],
                ),
                actions: [
                  IconButton(
                    tooltip: 'Sign out',
                    icon: const Icon(Icons.logout),
                    onPressed: () =>
                        ref.read(authProvider.notifier).logout(),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, $firstName 👋',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'What would you like to do today?',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.65),
                            ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.05,
                  children: [
                    for (final (i, f) in _features.indexed)
                      GlassCard(
                        onTap: () => context.push(f.route),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: AppColors.brandGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(f.icon,
                                  color: Colors.white, size: 22),
                            ),
                            const Spacer(),
                            Text(
                              f.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              f.subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                            ),
                          ],
                        ),
                      )
                          .animate(delay: (60 * i).ms)
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.1),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
