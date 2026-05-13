import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:leafy_app/core/routes/app_routes.dart';
import 'package:leafy_app/data/models/user_model.dart';
import 'package:leafy_app/data/services/session_service.dart';

class HomeController {
  final SessionService _sessionService = SessionService();
  final int healthyCount = 127;
  final int sickCount = 10;
  final String syncStatus = "Semua data aman";

  UserModel? get currentUser => _sessionService.currentUser;

  String get displayName {
    final name = currentUser?.name.trim();
    if (name == null || name.isEmpty) return 'Tim Leafy';
    return name;
  }

  String get avatarInitial {
    final name = displayName.trim();
    if (name.isEmpty) return 'L';
    return name.substring(0, 1).toUpperCase();
  }

  void onScanPressed(BuildContext context) {
    context.push(AppRoutes.scanner);
  }

  Future<void> logout(BuildContext context) async {
    await _sessionService.logout();
    if (context.mounted) {
      context.go('/login');
    }
  }
}
