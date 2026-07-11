import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_client.dart';
import 'models/note_model.dart';

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository(ref.watch(apiClientProvider));
});

/// Single source of truth for note CRUD against the backend.
class NotesRepository {
  const NotesRepository(this._api);

  final ApiClient _api;

  Future<List<NoteModel>> list() async {
    final res = await _api.get(ApiEndpoints.notes);
    final data = res.data as List<dynamic>;
    return data
        .map((e) => NoteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<NoteModel> create({required String title, required String body}) async {
    final res = await _api.post(
      ApiEndpoints.notes,
      data: {'title': title, 'body': body},
    );
    return NoteModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<NoteModel> update(
    int id, {
    required String title,
    required String body,
  }) async {
    final res = await _api.put(
      ApiEndpoints.note(id),
      data: {'title': title, 'body': body},
    );
    return NoteModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> delete(int id) => _api.delete(ApiEndpoints.note(id));
}
