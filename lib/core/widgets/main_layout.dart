import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import '../constants/app_colors.dart';
import 'glass_container.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onItemTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true, // Content flows behind the bottom nav bar
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: GlassContainer(
            borderRadius: 32,
            blur: 25,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: GNav(
              rippleColor: isDark ? Colors.white12 : Colors.grey[300]!,
              hoverColor: isDark ? Colors.white10 : Colors.grey[100]!,
              gap: 4,
              activeColor: Colors.white,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              duration: const Duration(milliseconds: 400),
              tabBackgroundGradient: AppColors.primaryGradient,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
              tabs: const [
                GButton(icon: LineIcons.home, text: 'Trang chủ'),
                GButton(icon: LineIcons.compass, text: 'Lịch trình'),
                GButton(icon: LineIcons.mapMarked, text: 'Bản đồ'),
                GButton(icon: LineIcons.user, text: 'Cá nhân'),
              ],
              selectedIndex: navigationShell.currentIndex,
              onTabChange: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}
