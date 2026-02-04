import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final bool isEmailVerified;
  final bool notificationsEnabled;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.isEmailVerified = false,
    this.notificationsEnabled = true,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'isEmailVerified': isEmailVerified,
      'notificationsEnabled': notificationsEnabled,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    bool? isEmailVerified,
    bool? notificationsEnabled,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, email, name, isEmailVerified, notificationsEnabled, createdAt];
}
