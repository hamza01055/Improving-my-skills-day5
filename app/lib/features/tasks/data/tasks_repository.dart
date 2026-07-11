import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_client.dart';
import 'models/task_model.dart';

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepository(ref.watch(apiClientProvider));
});

/// Single source of truth for task CRUD against the backend.
class TasksRepository {
  const TasksRepository(this._api);

  final ApiClient _api;

  Future<List<TaskModel>> list() async {
    final res = await _api.get(ApiEndpoints.tasks);
    final data = res.data as List<dynamic>;
    return data
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TaskModel> create({
    required String title,
    String? description,
    required String priority,
    DateTime? dueDate,
  }) async {
    final res = await _api.post(
      ApiEndpoints.tasks,
      data: {
        'title': title,
        'description': description,
        'priority': priority,
        'due_date': dueDate?.toIso8601String(),
      },
    );
    return TaskModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<TaskModel> toggle(int id) async {
    final res = await _api.post(ApiEndpoints.taskToggle(id));
    return TaskModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> delete(int id) => _api.delete(ApiEndpoints.task(id));
}
