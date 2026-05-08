import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import 'login_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = LoginController();

    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => controller.login(context),
          child: const Text('Login'),
        ),
      ),
    );
  }
}
