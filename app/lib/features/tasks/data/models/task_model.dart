class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isDone,
    required this.priority,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final String? description;
  final bool isDone;
  final String priority;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        isDone: json['is_done'] as bool? ?? false,
        priority: json['priority'] as String? ?? 'medium',
        dueDate: json['due_date'] == null
            ? null
            : DateTime.parse(json['due_date'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  TaskModel copyWith({bool? isDone}) => TaskModel(
        id: id,
        title: title,
        description: description,
        isDone: isDone ?? this.isDone,
        priority: priority,
        dueDate: dueDate,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
