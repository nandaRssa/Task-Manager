// ─────────────────────────────────────────────────────────────────────────────
// task_provider.dart
// State management untuk tasks: CRUD + search + filter + pagination.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../core/errors/exceptions.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

enum ViewState { initial, loading, success, error }

class TaskProvider extends ChangeNotifier {
  final _service = TaskService.instance;

  ViewState _state = ViewState.initial;
  List<TaskModel> _tasks           = [];
  String?         _errorMessage;
  String          _searchQuery     = '';
  String          _statusFilter    = 'all'; // 'all' | 'pending' | 'in_progress' | 'completed'
  bool            _isSubmitting    = false; // untuk create/update/delete loading

  // ── Getters ───────────────────────────────────────────────────────────────
  ViewState get state          => _state;
  String?   get errorMessage   => _errorMessage;
  String    get searchQuery    => _searchQuery;
  String    get statusFilter   => _statusFilter;
  bool      get isSubmitting   => _isSubmitting;
  bool      get isLoading      => _state == ViewState.loading;

  /// List yang sudah difilter search + status (digunakan oleh UI)
  List<TaskModel> get filteredTasks {
    return _tasks.where((task) {
      final matchesSearch = _searchQuery.isEmpty ||
          task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (task.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      final matchesStatus = _statusFilter == 'all' || task.status == _statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  int get totalCount     => _tasks.length;
  int get filteredCount  => filteredTasks.length;

  // ── Load Tasks (initial + pull-to-refresh) ────────────────────────────────
  Future<void> loadTasks({bool silent = false}) async {
    if (!silent) {
      _state = ViewState.loading;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _tasks = await _service.getTasks();
      _state = ViewState.success;
      _errorMessage = null;
    } on ApiException catch (e) {
      _state = ViewState.error;
      _errorMessage = e.message;
    } on NetworkException catch (e) {
      _state = ViewState.error;
      _errorMessage = e.message;
    } catch (_) {
      _state = ViewState.error;
      _errorMessage = 'Gagal memuat data. Coba lagi.';
    } finally {
      notifyListeners();
    }
  }

  // ── Create Task ───────────────────────────────────────────────────────────
  Future<bool> createTask({
    required String title,
    String? description,
    String status = 'pending',
  }) async {
    _setSubmitting(true);
    try {
      final newTask = await _service.createTask(
        title      : title,
        description: description,
        status     : status,
      );
      _tasks.insert(0, newTask); // tambah di paling atas
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  // ── Update Task ───────────────────────────────────────────────────────────
  Future<bool> updateTask(
    String id, {
    String? title,
    String? description,
    String? status,
  }) async {
    _setSubmitting(true);
    try {
      final updated = await _service.updateTask(
        id,
        title      : title,
        description: description,
        status     : status,
      );
      final idx = _tasks.indexWhere((t) => t.id == id);
      if (idx != -1) _tasks[idx] = updated;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  // ── Delete Task ───────────────────────────────────────────────────────────
  Future<bool> deleteTask(String id) async {
    _setSubmitting(true);
    // Optimistic: hapus dulu dari list lokal
    final removedIndex = _tasks.indexWhere((t) => t.id == id);
    final removedTask  = removedIndex != -1 ? _tasks[removedIndex] : null;
    if (removedIndex != -1) {
      _tasks.removeAt(removedIndex);
      notifyListeners();
    }

    try {
      await _service.deleteTask(id);
      return true;
    } on ApiException catch (e) {
      // Rollback jika API gagal
      if (removedTask != null) _tasks.insert(removedIndex, removedTask);
      _errorMessage = e.message;
      return false;
    } on NetworkException catch (e) {
      if (removedTask != null) _tasks.insert(removedIndex, removedTask);
      _errorMessage = e.message;
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  // ── Search ────────────────────────────────────────────────────────────────
  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // ── Filter ────────────────────────────────────────────────────────────────
  void setStatusFilter(String status) {
    _statusFilter = status;
    notifyListeners();
  }

  // ── Error management ──────────────────────────────────────────────────────
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Reset (saat logout) ───────────────────────────────────────────────────
  void reset() {
    _tasks        = [];
    _state        = ViewState.initial;
    _errorMessage = null;
    _searchQuery  = '';
    _statusFilter = 'all';
    notifyListeners();
  }

  void _setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }
}
