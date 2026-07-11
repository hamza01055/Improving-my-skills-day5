import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/task_model.dart';
import '../data/tasks_repository.dart';

class TasksState {
  const TasksState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
  });

  final List<TaskModel> tasks;
  final bool isLoading;
  final String? error;

  List<TaskModel> get pending => tasks.where((t) => !t.isDone).toList();
  List<TaskModel> get done => tasks.where((t) => t.isDone).toList();

  TasksState copyWith({
    List<TaskModel>? tasks,
    bool? isLoading,
    String? error,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final tasksProvider = NotifierProvider<TasksNotifier, TasksState>(
  TasksNotifier.new,
);

class TasksNotifier extends Notifier<TasksState> {
  TasksRepository get _repo => ref.read(tasksRepositoryProvider);

  @override
  TasksState build() => const TasksState();

  Future<void> load() => _run(() async {
        final tasks = await _repo.list();
        state = state.copyWith(tasks: tasks, isLoading: false);
      });

  Future<void> create({
    required String title,
    String? description,
    required String priority,
    DateTime? dueDate,
  }) =>
      _run(() async {
        final task = await _repo.create(
          title: title,
          description: description,
          priority: priority,
          dueDate: dueDate,
        );
        state = state.copyWith(tasks: [task, ...state.tasks], isLoading: false);
      });

  Future<void> toggle(int id) => _run(() async {
        final updated = await _repo.toggle(id);
        state = state.copyWith(
          tasks: [
            for (final t in state.tasks)
              if (t.id == id) updated else t,
          ],
          isLoading: false,
        );
      });

  Future<void> delete(int id) => _run(() async {
        await _repo.delete(id);
        state = state.copyWith(
          tasks: state.tasks.where((t) => t.id != id).toList(),
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
