import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/note_model.dart';
import '../data/notes_repository.dart';

class NotesState {
  const NotesState({
    this.notes = const [],
    this.isLoading = false,
    this.error,
  });

  final List<NoteModel> notes;
  final bool isLoading;
  final String? error;

  NotesState copyWith({
    List<NoteModel>? notes,
    bool? isLoading,
    String? error,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final notesProvider = NotifierProvider<NotesNotifier, NotesState>(
  NotesNotifier.new,
);

class NotesNotifier extends Notifier<NotesState> {
  NotesRepository get _repo => ref.read(notesRepositoryProvider);

  @override
  NotesState build() => const NotesState();

  Future<void> load() => _run(() async {
        final notes = await _repo.list();
        state = state.copyWith(notes: notes, isLoading: false);
      });

  Future<void> create(String title, String body) => _run(() async {
        final note = await _repo.create(title: title, body: body);
        state = state.copyWith(notes: [note, ...state.notes], isLoading: false);
      });

  Future<void> update(int id, String title, String body) => _run(() async {
        final updated = await _repo.update(id, title: title, body: body);
        state = state.copyWith(
          notes: [
            for (final n in state.notes)
              if (n.id == id) updated else n,
          ],
          isLoading: false,
        );
      });

  Future<void> delete(int id) => _run(() async {
        await _repo.delete(id);
        state = state.copyWith(
          notes: state.notes.where((n) => n.id != id).toList(),
          isLoading: false,
        );
      });

  Future<void> _run(Future<void> Function() action) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await action();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
