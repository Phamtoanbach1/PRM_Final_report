import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:animate_do/animate_do.dart';
import '../../auth/providers/auth_provider.dart';
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
              child: const Text('Thành viên VIP', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: const Text('user@danangcruise.com', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            ),
            const SizedBox(height: 48),
            
            // Grid Menu
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildGridItem(LineIcons.wallet, 'Ví của tôi', '0đ'),
                  _buildGridItem(LineIcons.history, 'Lịch sử', '12 chuyến'),
                  _buildGridItem(LineIcons.heart, 'Yêu thích', '5 tour'),
                  _buildGridItem(LineIcons.gift, 'Voucher', '3 mã'),
                ],
              ),
            ),

            const SizedBox(height: 48),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Provider.of<AuthProvider>(context, listen: false).logout();
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
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/operator/bookings'),
                      icon: const Icon(LineIcons.checkCircle),
                      label: const Text('Operator: Manage Bookings'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(IconData icon, String title, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
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
    );
  }
}
