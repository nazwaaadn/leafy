import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'register_controller.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisterController controller = Get.put(RegisterController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 72),
                _buildHeader(),
                const SizedBox(height: 40),
                _buildFieldLabel('Nama Lengkap'),
                const SizedBox(height: 8),
                _buildNameField(controller),
                const SizedBox(height: 20),
                _buildFieldLabel('Email'),
                const SizedBox(height: 8),
                _buildEmailField(controller),
                const SizedBox(height: 20),
                _buildFieldLabel('Kata Sandi'),
                const SizedBox(height: 8),
                _buildPasswordField(controller),
                const SizedBox(height: 32),
                _buildRegisterButton(context, controller),
                const SizedBox(height: 24),
                _buildLoginLink(context, controller),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Buat Akun',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Color(0xFF6B3A2A),
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Mulai pantau kesehatan tanamanmu',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF8A7A6A),
            fontWeight: FontWeight.w400,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4A3728),
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  Widget _buildNameField(RegisterController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller.nameController,
        keyboardType: TextInputType.name,
        textCapitalization: TextCapitalization.words,
        autocorrect: false,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF3A2A1E),
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: 'Nama Anda',
          hintStyle: const TextStyle(
            color: Color(0xFFBBAA99),
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.person_outline_rounded,
            color: Color(0xFFBBAA99),
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF4A7C3F),
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildEmailField(RegisterController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller.emailController,
        keyboardType: TextInputType.emailAddress,
        autocorrect: false,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF3A2A1E),
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: 'email@contoh.com',
          hintStyle: const TextStyle(
            color: Color(0xFFBBAA99),
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.mail_outline_rounded,
            color: Color(0xFFBBAA99),
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF4A7C3F),
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPasswordField(RegisterController controller) {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller.passwordController,
            obscureText: !controller.isPasswordVisible.value,
            autocorrect: false,
            enableSuggestions: false,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF3A2A1E),
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: 'Buat kata sandi',
              hintStyle: const TextStyle(
                color: Color(0xFFBBAA99),
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFFBBAA99),
                size: 20,
              ),
              suffixIcon: GestureDetector(
                onTap: controller.togglePasswordVisibility,
                child: Icon(
                  controller.isPasswordVisible.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFFBBAA99),
                  size: 20,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF4A7C3F),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ));
  }

  Widget _buildRegisterButton(
      BuildContext context, RegisterController controller) {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () => controller.register(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A7C3F),
              disabledBackgroundColor:
                  const Color(0xFF4A7C3F).withOpacity(0.6),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              shadowColor: const Color(0xFF4A7C3F).withOpacity(0.4),
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'Daftar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ));
  }

  Widget _buildLoginLink(BuildContext context, RegisterController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Sudah punya akun?  ',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF8A7A6A),
            fontWeight: FontWeight.w400,
          ),
        ),
        GestureDetector(
          onTap: () => controller.goToLogin(context),
          child: const Text(
            'Masuk',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF4A7C3F),
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}