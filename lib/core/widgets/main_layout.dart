import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:go_router/go_router.dart';
class MainLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Current design is: Solid white background bottom nav bar
    return Scaffold(
      backgroundColor: Colors.white,
      body: widget.navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withValues(alpha: 0.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.blueAccent,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.blueAccent.withValues(alpha: 0.1),
              color: Colors.grey,
              tabs: const [
                GButton(icon: Icons.home_filled, text: 'Trang chủ'),
                GButton(icon: Icons.calendar_today_rounded, text: 'Lịch trình'),
                GButton(icon: Icons.location_on_outlined, text: 'Bản đồ'),
                GButton(icon: Icons.person_outline, text: 'Cá nhân'),
              ],
              selectedIndex: widget.navigationShell.currentIndex,
              onTabChange: _goBranch,
            ),
          ),
        ),
      ),
    );
  }
}
