import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:animate_do/animate_do.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/domain/user_role.dart';
import '../../boats/providers/boat_provider.dart';
import '../../booking/providers/booking_provider.dart';
import '../../../core/constants/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        actions: [
          IconButton(
            icon: const Icon(LineIcons.cog),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + kToolbarHeight + 20, left: 24, right: 24, bottom: 100),
        child: Column(
          children: [
            Center(
              child: FadeInDown(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).cardColor,
                          boxShadow: [
                            BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 20, spreadRadius: 5),
                          ],
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 3),
                          image: _imageFile != null
                              ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: _imageFile == null
                            ? const Icon(LineIcons.user, size: 60, color: AppColors.primary)
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 3),
                        ),
                        child: const Icon(LineIcons.camera, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  final label = auth.displayName ?? auth.displayEmail?.split('@').first ?? 'Thành viên';
                  return Text(
                    label,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return Text(
                    auth.displayEmail ?? '—',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  );
                },
              ),
            ),
            const SizedBox(height: 48),
            
            // Grid Menu
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Consumer3<BookingProvider, AuthProvider, BoatProvider>(
                builder: (context, bookingProvider, auth, boatProvider, _) {
                  final ownerBoatIds = boatProvider
                      .boatsForAdminScope(auth.role, auth.displayEmail)
                      .map((e) => e.id)
                      .toSet();
                  final tripCount = bookingProvider
                      .visibleBookingsForRole(
                        role: auth.role,
                        email: auth.displayEmail,
                        ownerBoatIds: ownerBoatIds,
                      )
                      .length;
                  final isAdmin = auth.role == UserRole.admin;
                  final isOwnerOrAdmin =
                      auth.role == UserRole.shopOwner || isAdmin;
                  final tiles = <Widget>[
                    if (!isAdmin)
                      _buildGridItem(
                        context,
                        LineIcons.history,
                        'Lịch sử',
                        '$tripCount chuyến',
                        onTap: () => context.go('/bookings'),
                      ),
                    if (!isAdmin)
                      _buildGridItem(
                        context,
                        LineIcons.heart,
                        'Yêu thích',
                        'Thuyền đã lưu',
                        onTap: () => context.push('/home/favorites'),
                      ),
                    if (isOwnerOrAdmin)
                      _buildGridItem(
                        context,
                        LineIcons.gift,
                        'Quản trị',
                        isAdmin ? 'Admin Dashboard' : 'Owner Dashboard',
                        onTap: () => context.push('/admin'),
                      ),
                  ];
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: tiles,
                  );
                },
              ),
            ),

            const SizedBox(height: 48),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Provider.of<AuthProvider>(context, listen: false).logout();
                    if (!context.mounted) return;
                    context.read<BookingProvider>().clearLocal();
                    context.go('/login');
                  },
                  icon: const Icon(LineIcons.alternateSignOut, color: Colors.red),
                  label: const Text('Đăng Xuất', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle, {
    required VoidCallback onTap,
  }) {
    return Material(
      elevation: 1,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(24),
      color: Theme.of(context).cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: AppColors.primary),
              const Spacer(),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
