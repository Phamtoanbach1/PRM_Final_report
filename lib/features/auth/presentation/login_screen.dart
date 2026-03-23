import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dart:ui';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/dragon_bridge.jpg'), // Da Nang Dragon Bridge
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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2), // Glassmorphism
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo / App Name
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.landscape, size: 40, color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'HanCruise',
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 32),

                          // Email Input
                          _buildLabeledInput('Email', 'example@email.com', _emailController, false),
                          const SizedBox(height: 20),
                          
                          // Password Input
                          _buildLabeledInput('Mật khẩu', '••••••••••', _passwordController, true),

                          const SizedBox(height: 32),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                final auth = Provider.of<AuthProvider>(context, listen: false);
                                await auth.login(_emailController.text, _passwordController.text);
                                if (auth.isAuthenticated && context.mounted) {
                                  context.go('/home');
                                } else if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Đăng nhập thất bại')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFF1E57A7), Color(0xFF327AD4)]),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: const Text('Đăng nhập', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                          const Text('Quên mật khẩu?', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 24),
                          
                          // Divider
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.3))),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text('Hoặc', style: TextStyle(color: Colors.white70)),
                              ),
                              Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.3))),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Social Buttons
                          Row(
                            children: [
                              Expanded(child: _buildSocialButton('Google', Icons.g_mobiledata, Colors.redAccent)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildSocialButton('Facebook', Icons.facebook, Colors.blue)),
                            ],
                          ),

                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Chưa có tài khoản? ', style: TextStyle(color: Colors.white70)),
                              GestureDetector(
                                onTap: () => context.push('/register'),
                                child: const Text('Đăng ký ngay', style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold)),
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
        ],
      ),
    );
  }

  Widget _buildLabeledInput(String label, String hint, TextEditingController controller, bool isPassword) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword && _obscureText,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.cyanAccent, width: 1.5), // Glowing border
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.cyanAccent, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.cyanAccent, width: 2),
            ),
            suffixIcon: isPassword 
              ? IconButton(
                  icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                )
              : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(String text, IconData icon, Color iconColor) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: iconColor),
      label: Text(text, style: const TextStyle(color: Colors.white)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}
