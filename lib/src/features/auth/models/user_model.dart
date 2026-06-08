import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? ageRange;
  final List<String>? goals;
  final Map<String, dynamic>? preferences;
  final Timestamp createdAt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.ageRange,
    this.goals,
    this.preferences,
    required this.createdAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      photoUrl: map['photoUrl'] as String?,
      ageRange: map['ageRange'] as String?,
      goals: map['goals'] != null ? List<String>.from(map['goals']) : null,
      preferences: map['preferences'] != null ? Map<String, dynamic>.from(map['preferences']) : null,
      createdAt: map['createdAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'ageRange': ageRange,
      'goals': goals,
      'preferences': preferences,
      'createdAt': createdAt,
    };
  }
}
