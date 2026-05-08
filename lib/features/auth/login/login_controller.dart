import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';

class LoginController {
  void login(BuildContext context) {
    context.go(AppRoutes.home);
  }
}
