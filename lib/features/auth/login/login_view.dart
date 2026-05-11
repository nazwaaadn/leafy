import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 72),
                _buildLogo(),
                const SizedBox(height: 16),
                const Text(
                  'Leafy',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6B3A2A),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Asisten Cerdas Kebun Anda',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8A7A6A),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 52),
                _buildFieldLabel('Email'),
                const SizedBox(height: 8),
                _buildEmailField(controller),
                const SizedBox(height: 20),
                _buildFieldLabel('Kata Sandi'),
                const SizedBox(height: 8),
                _buildPasswordField(controller),
                const SizedBox(height: 8),
                Obx(() {
                  if (controller.errorMessage.value.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFFD32F2F),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              controller.errorMessage.value,
                              style: const TextStyle(
                                color: Color(0xFFD32F2F),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                const SizedBox(height: 28),
                _buildLoginButton(context, controller),
                const SizedBox(height: 24),
                _buildRegisterLink(context, controller),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: const Color(0xFF6B3A2A),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B3A2A).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Transform.rotate(
            angle: - 0.25,
            child: Image.asset(
            'assets/images/leaf_logo.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    ),
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

  Widget _buildEmailField(LoginController controller) {
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
          hintText: 'leafy@gmail.com',
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

  Widget _buildPasswordField(LoginController controller) {
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
              hintText: '••••••••',
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

  Widget _buildLoginButton(BuildContext context, LoginController controller) {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () => controller.login(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A7C3F),
              disabledBackgroundColor: const Color(0xFF4A7C3F).withOpacity(0.6),
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
                    'Masuk',
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

  Widget _buildRegisterLink(BuildContext context, LoginController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Belum punya akun?  ',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF8A7A6A),
            fontWeight: FontWeight.w400,
          ),
        ),
        GestureDetector(
          onTap: () => controller.goToRegister(context),
          child: const Text(
            'Daftar sekarang',
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