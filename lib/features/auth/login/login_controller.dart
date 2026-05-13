import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:leafy_app/data/repositories/auth_repository.dart';
import 'package:leafy_app/data/services/session_service.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxString errorMessage = ''.obs;
  final AuthRepository _authRepository = AuthRepository();
  final SessionService _sessionService = SessionService();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login(BuildContext context) async {
    errorMessage.value = '';

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Email dan kata sandi tidak boleh kosong.';
      return;
    }

    isLoading.value = true;

    try {
      final user = await _authRepository.login(email: email, password: password);
      await _sessionService.saveUser(user);
      isLoading.value = false;
      _showSuccessSnackbar();

      if (context.mounted) {
        context.go('/splash');
      }
    } on AuthException catch (e) {
      isLoading.value = false;
      errorMessage.value = e.message;
      _showErrorSnackbar();
    } catch (_) {
      isLoading.value = false;
      errorMessage.value = 'Tidak bisa terhubung ke MongoDB.';
      _showErrorSnackbar();
    }
  }

  void _showSuccessSnackbar() {
    Get.snackbar(
      'Berhasil Masuk',
      'Selamat datang di Leafy!',
      backgroundColor: const Color(0xFF4A7C3F),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  void _showErrorSnackbar() {
    Get.snackbar(
      'Gagal Masuk',
      errorMessage.value,
      backgroundColor: const Color(0xFFD32F2F),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.error_outline, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  void goToRegister(BuildContext context) {
    context.push('/register');
  }
}
