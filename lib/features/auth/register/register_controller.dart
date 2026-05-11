import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class RegisterController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> register(BuildContext context) async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Validasi nama
    if (name.isEmpty) {
      _showErrorSnackbar('Nama tidak boleh kosong.');
      return;
    }

    // Validasi email
    if (email.isEmpty) {
      _showErrorSnackbar('Email tidak boleh kosong.');
      return;
    }
    if (!_isValidEmail(email)) {
      _showErrorSnackbar('Format email tidak valid.');
      return;
    }

    // Validasi password
    if (password.isEmpty) {
      _showErrorSnackbar('Kata sandi tidak boleh kosong.');
      return;
    }
    if (password.length < 6) {
      _showErrorSnackbar('Kata sandi minimal 6 karakter.');
      return;
    }

    isLoading.value = true;

    // Simulasi proses registrasi (tanpa backend)
    await Future.delayed(const Duration(seconds: 2));

    isLoading.value = false;

    _showSuccessSnackbar();

    // Kembali ke halaman login setelah berhasil
    if (context.mounted) {
      context.go('/login');
    }
  }

  void _showSuccessSnackbar() {
    Get.snackbar(
      'Registrasi Berhasil',
      'Akun kamu berhasil dibuat! Silakan masuk. 🌿',
      backgroundColor: const Color(0xFF4A7C3F),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Perhatian',
      message,
      backgroundColor: const Color(0xFFD32F2F),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.error_outline, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  void goToLogin(BuildContext context) {
    context.go('/login');
  }
}