import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _agreedToTerms = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image (Dragon Bridge Night)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/dragon_bridge.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Dark Overlay
          Container(
            color: Colors.black.withValues(alpha: 0.3),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3), // Darker glass
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          const Text(
                            'Đăng ký với Hiệu ứng Glassmorphism',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // Inputs
                          _buildInput('Họ và tên', _nameController, false),
                          const SizedBox(height: 16),
                          _buildInput('Email', _emailController, false),
                          const SizedBox(height: 16),
                          _buildInput('Số điện thoại', _phoneController, false),
                          const SizedBox(height: 16),
                          _buildInput('Mật khẩu', _passwordController, true, isPasswordField: true, isObscure: _obscurePassword, onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword)),
                          const SizedBox(height: 16),
                          _buildInput('Xác nhận mật khẩu', _confirmPasswordController, true, isPasswordField: true, isObscure: _obscureConfirm, onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm)),

                          const SizedBox(height: 16),

                          // Terms and Conditions Checkbox
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _agreedToTerms ? Colors.transparent : Colors.transparent,
                                    border: Border.all(color: Colors.cyanAccent, width: 2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: _agreedToTerms 
                                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                                    : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text('Tôi đồng ý với điều khoản và điều kiện', style: TextStyle(color: Colors.white, fontSize: 13)),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                if (!_agreedToTerms) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng đồng ý với điều khoản')));
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng ký thành công!')));
                                context.pop(); // Go back to login
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFFF5722)]), // Orange gradient
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: const Text('Đăng ký', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Đã có tài khoản? ', style: TextStyle(color: Colors.white70)),
                              GestureDetector(
                                onTap: () => context.pop(),
                                child: const Text('Đăng nhập', style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold)),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Back arrow top left
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () => context.pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String hint, TextEditingController controller, bool isPassword, {bool isPasswordField = false, bool isObscure = true, VoidCallback? onToggleObscure}) {
    // For exact match with mockup, some fields glow cyan. We'll make them all responsive instead.
    // Unfocused border is white, focused is cyan.
    return TextField(
      controller: controller,
      obscureText: isPasswordField && isObscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.cyanAccent, width: 2),
        ),
      ),
    );
  }
}
