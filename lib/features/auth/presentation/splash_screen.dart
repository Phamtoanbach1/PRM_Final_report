import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    
    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.checkAuthStatus();
      if (!mounted) return;
      if (auth.isAuthenticated) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F4C81), Color(0xFF5E8BBA), Color(0xFFB5DBEB)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Boat Icon
            const Icon(Icons.directions_boat_outlined, size: 100, color: Colors.white),
            const SizedBox(height: 10),
            // Water waves
            Icon(Icons.water, size: 40, color: Colors.white.withValues(alpha: 0.8)),
            
            const SizedBox(height: 60),
            
            // Progress bar
            Container(
              width: 200,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Stack(
                children: [
                   AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        widthFactor: _controller.value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(color: Colors.white.withValues(alpha: 0.5), blurRadius: 10)
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            const Text(
              'Chương trình du lịch Sông Hàn',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 4),
            Text(
              'đang sẵn sàng...',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
