// ─────────────────────────────────────────────────────────────────────────────
// task_model.dart
// Model untuk data task dari API.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final String status;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id         : json['id']          as String,
      title      : json['title']       as String,
      description: json['description'] as String?,
      status     : json['status']      as String,
      userId     : json['user_id']     as String,
      createdAt  : DateTime.parse(json['created_at'] as String),
      updatedAt  : DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id'         : id,
    'title'      : title,
    'description': description,
    'status'     : status,
    'user_id'    : userId,
    'created_at' : createdAt.toIso8601String(),
    'updated_at' : updatedAt.toIso8601String(),
  };

  // ── UI Helpers ────────────────────────────────────────────────────────────

  /// Label tampilan sesuai status backend value
  String get statusLabel {
    switch (status) {
      case AppConstants.statusPending:
        return 'Pending';
      case AppConstants.statusInProgress:
        return 'In Progress';
      case AppConstants.statusCompleted:
        return 'Completed';
      default:
        return status;
    }
  }

  /// Warna badge sesuai status
  Color get statusColor {
    switch (status) {
      case AppConstants.statusPending:
        return const Color(0xFFF59E0B); // amber
      case AppConstants.statusInProgress:
        return const Color(0xFF3B82F6); // blue
      case AppConstants.statusCompleted:
        return const Color(0xFF10B981); // emerald
      default:
        return Colors.grey;
    }
  }

  /// Warna aksen card (border-left)
  Color get accentColor => statusColor;

  /// Icon sesuai status
  IconData get statusIcon {
    switch (status) {
      case AppConstants.statusPending:
        return Icons.radio_button_unchecked;
      case AppConstants.statusInProgress:
        return Icons.timelapse;
      case AppConstants.statusCompleted:
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  /// CopyWith untuk update lokal
  TaskModel copyWith({
    String? title,
    String? description,
    String? status,
  }) {
    return TaskModel(
      id         : id,
      title      : title ?? this.title,
      description: description ?? this.description,
      status     : status ?? this.status,
      userId     : userId,
      createdAt  : createdAt,
      updatedAt  : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is TaskModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
