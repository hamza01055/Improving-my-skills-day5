import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/documents_repository.dart';
import '../data/models/document_model.dart';

class DocumentsState {
  const DocumentsState({
    this.documents = const [],
    this.isLoading = false,
    this.isUploading = false,
    this.error,
  });

  final List<DocumentModel> documents;
  final bool isLoading;
  final bool isUploading;
  final String? error;

  DocumentsState copyWith({
    List<DocumentModel>? documents,
    bool? isLoading,
    bool? isUploading,
    String? error,
  }) {
    return DocumentsState(
      documents: documents ?? this.documents,
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      error: error,
    );
  }
}

final documentsProvider = NotifierProvider<DocumentsNotifier, DocumentsState>(
  DocumentsNotifier.new,
);

class DocumentsNotifier extends Notifier<DocumentsState> {
  DocumentsRepository get _repo => ref.read(documentsRepositoryProvider);

  @override
  DocumentsState build() => const DocumentsState();

  Future<void> load() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final documents = await _repo.list();
      state = state.copyWith(documents: documents, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> upload({required List<int> bytes, required String filename}) async {
    try {
      state = state.copyWith(isUploading: true, error: null);
      final document = await _repo.upload(bytes: bytes, filename: filename);
      state = state.copyWith(
        documents: [document, ...state.documents],
        isUploading: false,
      );
    } catch (e) {
      state = state.copyWith(isUploading: false, error: e.toString());
    }
  }

  Future<void> delete(int id) async {
    try {
      await _repo.delete(id);
      state = state.copyWith(
        documents: state.documents.where((d) => d.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
