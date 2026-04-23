// ─────────────────────────────────────────────────────────────────────────────
// user_model.dart
// Model untuk data user dari API response.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String email;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  /// Parse dari JSON object (data.user dari backend)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id    : json['id']    as String,
      name  : json['name']  as String,
      email : json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id'   : id,
    'name' : name,
    'email': email,
  };

  /// Serialize ke string untuk disimpan di secure storage
  String toJsonString() => jsonEncode(toJson());

  /// Deserialize dari string yang tersimpan di secure storage
  factory UserModel.fromJsonString(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  /// Initial avatar dari huruf pertama nama
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  String toString() => 'UserModel(id: $id, name: $name, email: $email)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is UserModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
