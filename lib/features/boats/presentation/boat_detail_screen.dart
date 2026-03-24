import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/boat_provider.dart';

class BoatDetailScreen extends StatelessWidget {
  const BoatDetailScreen({super.key, required this.boatId});

  final String boatId;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return Consumer2<BoatProvider, AuthProvider>(
      builder: (context, provider, auth, _) {
        final boat = provider.byId(boatId);
        if (boat == null) {
          return const Scaffold(body: Center(child: Text('Không tìm thấy thuyền')));
        }
        final fav = provider.isFavorite(boat.id);
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Chi tiết thuyền'),
            actions: [
              IconButton(
                onPressed: () => provider.toggleFavorite(boat.id),
                icon: Icon(fav ? Icons.favorite : Icons.favorite_border,
                    color: fav ? Colors.red : Colors.grey),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              SizedBox(
                height: 240,
                child: PageView.builder(
                  itemCount: boat.gallery.length,
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: _boatImage(boat.gallery[i]),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              Text(boat.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              const SizedBox(height: 8),
              Text(boat.description, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip(Icons.people_alt_outlined, 'Tối đa ${boat.capacity} khách'),
                  _chip(Icons.star_rounded, 'Đánh giá ${boat.rating.toStringAsFixed(1)}'),
                  _chip(Icons.sell_outlined, '${currency.format(boat.hourlyPrice)}/giờ'),
                ],
              ),
              const SizedBox(height: 18),
              const Text('Gallery thuyền',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: boat.gallery.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _boatImage(boat.gallery[i]),
                ),
              ),
              const SizedBox(height: 20),
              if (!auth.isAdmin &&
                  !(auth.isShopOwner &&
                      boat.ownerEmail.toLowerCase() == (auth.displayEmail ?? '').toLowerCase()))
                FilledButton.icon(
                  onPressed: () =>
                      context.push('/bookings/create', extra: <String, dynamic>{'boatId': boat.id}),
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text('Đặt thuyền này'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              if (auth.isAdmin)
                const Text(
                  'Tài khoản admin không thực hiện đặt thuyền.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              if (auth.isShopOwner &&
                  boat.ownerEmail.toLowerCase() == (auth.displayEmail ?? '').toLowerCase())
                const Text(
                  'Shop owner không thể đặt thuyền của chính mình.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _boatImage(String src) {
    if (src.startsWith('http://') || src.startsWith('https://')) {
      return Image.network(
        src,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    return Image.file(
      File(src),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }

  Widget _fallback() => Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.image_not_supported),
      );
}
