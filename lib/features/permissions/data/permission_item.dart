import 'package:flutter/material.dart';

enum PermissionStatus { notGranted, granted }

class HealthPermissionItem {
  final String id;
  final String title;
  final String description;
  final String rationale;
  final IconData icon;
  final PermissionStatus status;

  const HealthPermissionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.rationale,
    required this.icon,
    this.status = PermissionStatus.notGranted,
  });

  HealthPermissionItem copyWith({PermissionStatus? status}) {
    return HealthPermissionItem(
      id: id,
      title: title,
      description: description,
      rationale: rationale,
      icon: icon,
      status: status ?? this.status,
    );
  }
}

