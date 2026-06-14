import 'package:flutter/material.dart';

enum UserDept { system, sales, admission, external }
enum UserType { admin, sales, admission, student }

class AppUser {
  final String id;
  final String name;
  final String role;
  final UserDept dept;
  final int level;
  final UserType type;
  final String initials;
  final Color color;
  final bool online;
  final String? appId;

  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    required this.dept,
    required this.level,
    required this.type,
    required this.initials,
    required this.color,
    this.online = false,
    this.appId,
  });
}
