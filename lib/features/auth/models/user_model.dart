import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  const UserModel({
    required this.username,
    required this.email,
    required this.isVerified,
    required this.createdAt,
    required this.lastVerificationEmailSentAt,
  });

  final String username;
  final String email;
  final bool isVerified;
  final Timestamp createdAt;
  final Timestamp lastVerificationEmailSentAt;

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'isVerified': isVerified,
      'createdAt': createdAt,
      'lastVerificationEmailSentAt': lastVerificationEmailSentAt,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] as String,
      email: json['email'] as String,
      isVerified: json['isVerified'] as bool,
      createdAt: json['createdAt'] as Timestamp,
      lastVerificationEmailSentAt:
          json['lastVerificationEmailSentAt'] as Timestamp,
    );
  }
}
