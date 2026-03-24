import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../boats/providers/boat_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return Consumer<BoatProvider>(
      builder: (context, boatProvider, _) {
        final boats = boatProvider.allBoats;
        return Scaffold(
          backgroundColor: Colors.white,
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 30, 16, 90),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E5B9A), Color(0xFF4D8FD3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'HanCruise',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Khám phá danh sách thuyền, lọc theo ngày và số người.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: () => context.push('/home/boats'),
                      icon: const Icon(Icons.sailing_rounded),
                      label: const Text('Xem danh sách thuyền'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2E5B9A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Gallery thuyền nổi bật',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 270,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: boats.length,
                  itemBuilder: (context, index) {
                    final b = boats[index];
                    final fav = boatProvider.isFavorite(b.id);
                    return Container(
                      width: 230,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => context.push('/home/boats/${b.id}'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                              child: _boatImage(b.gallery.first, height: 150, width: double.infinity),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          b.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => boatProvider.toggleFavorite(b.id),
                                        icon: Icon(
                                          fav ? Icons.favorite : Icons.favorite_border,
                                          color: fav ? Colors.red : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${currency.format(b.hourlyPrice)}/giờ',
                                    style: const TextStyle(color: Color(0xFF2E5B9A), fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${b.capacity} khách • ⭐ ${b.rating.toStringAsFixed(1)}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _boatImage(String src, {double? height, double? width}) {
    if (src.startsWith('http://') || src.startsWith('https://')) {
      return Image.network(
        src,
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(height: height, width: width),
      );
    }
    return Image.file(
      File(src),
      height: height,
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallback(height: height, width: width),
    );
  }

  Widget _fallback({double? height, double? width}) => Container(
        height: height,
        width: width,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image_not_supported),
      );
}
