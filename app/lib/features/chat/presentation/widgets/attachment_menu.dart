import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../documents/providers/documents_provider.dart';
import 'quick_add_note_sheet.dart';
import 'quick_add_task_sheet.dart';
import 'voice_input_sheet.dart';

class _AttachmentOption {
  const _AttachmentOption(this.icon, this.title, this.subtitle);
  final IconData icon;
  final String title;
  final String subtitle;
}

const _options = [
  _AttachmentOption(Icons.edit_note_outlined, 'Note', 'Quickly capture a note'),
  _AttachmentOption(Icons.check_circle_outline, 'Task', 'Add a to-do with priority'),
  _AttachmentOption(Icons.description_outlined, 'Document', 'Upload a file from your device'),
  _AttachmentOption(Icons.mic_none_outlined, 'Voice', 'Speak and send as a message'),
];

/// "+" attachment menu shown near the chat input, offering quick access to
/// Notes/Tasks/Documents/Voice without leaving the conversation.
class AttachmentMenu extends ConsumerWidget {
  const AttachmentMenu({super.key});

  Future<void> _handleTap(BuildContext context, WidgetRef ref, int index) async {
    Navigator.of(context).pop();
    switch (index) {
      case 0:
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const QuickAddNoteSheet(),
        );
      case 1:
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const QuickAddTaskSheet(),
        );
      case 2:
        final result = await FilePicker.platform.pickFiles(withData: true);
        if (result == null || result.files.isEmpty) return;
        final file = result.files.first;
        final bytes = file.bytes;
        if (bytes == null) return;
        await ref.read(documentsProvider.notifier).upload(bytes: bytes, filename: file.name);
      case 3:
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const VoiceInputSheet(),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, option) in _options.indexed)
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(option.icon, color: Colors.white, size: 20),
              ),
              title: Text(option.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(option.subtitle),
              onTap: () => _handleTap(context, ref, i),
            ),
        ],
      ),
    );
  }
}
