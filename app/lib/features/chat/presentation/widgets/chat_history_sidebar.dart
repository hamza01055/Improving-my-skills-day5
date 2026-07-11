import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/chat_provider.dart';

class _NavItem {
  const _NavItem(this.icon, this.title, this.subtitle, this.route);
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
}

const _navItems = [
  _NavItem(Icons.description_outlined, 'Documents',
      'Upload files, chat with them', RouteNames.documents),
  _NavItem(Icons.edit_note_outlined, 'Notes',
      'Capture, rewrite, summarize', RouteNames.notes),
  _NavItem(Icons.check_circle_outline, 'Tasks',
      'AI-prioritized to-dos', RouteNames.tasks),
  _NavItem(Icons.mic_none_outlined, 'Voice',
      'Speak to your second brain', RouteNames.voice),
  _NavItem(Icons.settings_outlined, 'Settings',
      'Theme, account, and more', RouteNames.settings),
];

/// Chat-history + secondary navigation drawer shown from the chat home screen.
///
/// Recent chats are UI-only for now: there is no multi-conversation/session
/// concept in [chatProvider] or the backend yet, so this shows the current
/// conversation's opening line as a single stub entry.
// TODO(sessions): wire this to real per-conversation history once the
// backend supports multiple chat sessions per user.
class ChatHistorySidebar extends ConsumerStatefulWidget {
  const ChatHistorySidebar({super.key});

  @override
  ConsumerState<ChatHistorySidebar> createState() => _ChatHistorySidebarState();
}

class _ChatHistorySidebarState extends ConsumerState<ChatHistorySidebar> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider.select((s) => s.messages));
    final firstUserMessage = messages.isEmpty
        ? null
        : messages.firstWhere(
            (m) => m.isUser,
            orElse: () => messages.first,
          );

    final recentChats = <String>[
      if (firstUserMessage != null)
        _truncate(firstUserMessage.content)
      else
        'New conversation',
    ].where((title) => title.toLowerCase().contains(_query.toLowerCase())).toList();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: AppColors.brandGradient,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.psychology_outlined,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'IntelliVault',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Search chats',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recent Chats',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
              ),
            ),
            ...recentChats.map(
              (title) => ListTile(
                dense: true,
                leading: const Icon(Icons.chat_bubble_outline, size: 20),
                title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (final item in _navItems)
                    ListTile(
                      leading: Icon(item.icon),
                      title: Text(item.title),
                      subtitle: Text(item.subtitle),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push(item.route);
                      },
                    ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: () {
                Navigator.of(context).pop();
                ref.read(authProvider.notifier).logout();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _truncate(String text) {
    final singleLine = text.replaceAll('\n', ' ').trim();
    return singleLine.length <= 40 ? singleLine : '${singleLine.substring(0, 40)}...';
  }
}
