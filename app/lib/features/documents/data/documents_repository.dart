import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_client.dart';
import 'models/document_model.dart';

final documentsRepositoryProvider = Provider<DocumentsRepository>((ref) {
  return DocumentsRepository(ref.watch(apiClientProvider));
});

/// Single source of truth for document upload/list/delete against the backend.
class DocumentsRepository {
  const DocumentsRepository(this._api);

  final ApiClient _api;

  Future<List<DocumentModel>> list() async {
    final res = await _api.get(ApiEndpoints.documents);
    final data = res.data as List<dynamic>;
    return data
        .map((e) => DocumentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DocumentModel> upload({
    required List<int> bytes,
    required String filename,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final res = await _api.postForm(ApiEndpoints.upload, formData);
    return DocumentModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> delete(int id) => _api.delete(ApiEndpoints.document(id));
}
