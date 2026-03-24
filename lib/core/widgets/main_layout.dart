import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/booking/providers/booking_provider.dart';

class MainLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  List<({int branch, GButton tab})> _tabConfig(bool isAdmin) {
    if (isAdmin) {
      return <({int branch, GButton tab})>[
        (branch: 0, tab: const GButton(icon: Icons.home_filled, text: 'Trang chủ')),
        (branch: 2, tab: const GButton(icon: Icons.person_outline, text: 'Cá nhân')),
      ];
    }
    return <({int branch, GButton tab})>[
      (branch: 0, tab: const GButton(icon: Icons.home_filled, text: 'Trang chủ')),
      (branch: 1, tab: const GButton(icon: Icons.sailing_rounded, text: 'Đặt thuyền')),
      (branch: 2, tab: const GButton(icon: Icons.person_outline, text: 'Cá nhân')),
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BookingProvider>().load();
    });
  }

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final config = _tabConfig(auth.isAdmin);
    final selectedDisplayIndex = config.indexWhere(
      (e) => e.branch == widget.navigationShell.currentIndex,
    );
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
              tabs: config.map((e) => e.tab).toList(),
              selectedIndex: selectedDisplayIndex < 0 ? 0 : selectedDisplayIndex,
              onTabChange: (i) => _goBranch(config[i].branch),
            ),
          ),
        ),
      ),
    );
  }
}
