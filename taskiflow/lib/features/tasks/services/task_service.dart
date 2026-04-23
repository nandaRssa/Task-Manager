// ─────────────────────────────────────────────────────────────────────────────
// task_service.dart
// Service layer untuk semua operasi CRUD task.
// ─────────────────────────────────────────────────────────────────────────────

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/task_model.dart';

class TaskService {
  TaskService._();
  static final TaskService instance = TaskService._();

  final _client = ApiClient.instance;

  // ── Get All Tasks ─────────────────────────────────────────────────────────
  Future<List<TaskModel>> getTasks() async {
    final response = await _client.get(ApiConstants.tasks);
    final data     = response['data'] as Map<String, dynamic>;
    final taskList = data['tasks'] as List<dynamic>;

    return taskList
        .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ── Get Task By ID ────────────────────────────────────────────────────────
  Future<TaskModel> getTaskById(String id) async {
    final response = await _client.get(ApiConstants.taskById(id));
    return TaskModel.fromJson(
      response['data']['task'] as Map<String, dynamic>,
    );
  }

  // ── Create Task ───────────────────────────────────────────────────────────
  Future<TaskModel> createTask({
    required String title,
    String? description,
    String status = 'pending',
  }) async {
    final response = await _client.post(
      ApiConstants.tasks,
      body: {
        'title'      : title,
        if (description != null && description.isNotEmpty) 'description': description,
        'status'     : status,
      },
    );
    return TaskModel.fromJson(
      response['data']['task'] as Map<String, dynamic>,
    );
  }

  // ── Update Task ───────────────────────────────────────────────────────────
  Future<TaskModel> updateTask(
    String id, {
    String? title,
    String? description,
    String? status,
  }) async {
    final body = <String, dynamic>{};
    if (title != null)       body['title']       = title;
    if (description != null) body['description'] = description;
    if (status != null)      body['status']      = status;

    final response = await _client.put(
      ApiConstants.taskById(id),
      body: body,
    );
    return TaskModel.fromJson(
      response['data']['task'] as Map<String, dynamic>,
    );
  }

  // ── Delete Task ───────────────────────────────────────────────────────────
  Future<void> deleteTask(String id) async {
    await _client.delete(ApiConstants.taskById(id));
  }
}
