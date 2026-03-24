import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../domain/models/tour.dart';
import '../providers/tour_provider.dart';

class BoatDetailScreen extends StatelessWidget {
  final String tourId;

  const BoatDetailScreen({super.key, required this.tourId});

  @override
  Widget build(BuildContext context) {
    return Consumer<TourProvider>(
      builder: (context, provider, child) {
        final tour = provider.getTourById(tourId);
        final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

        return Scaffold(
          backgroundColor: const Color(0xFFFBFBFE),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
              onPressed: () => context.pop(),
            ),
            title: const Text('Chi tiết Tour Thuyền', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Gallery
                _buildGallery(tour.galleryImages),
                
                // Info Section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Favorite toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              tour.title,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E2022)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => provider.toggleFavorite(tour.id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: tour.isFavorite ? Colors.red[50] : Colors.orange[50], // Toggles between a light orange and light red
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    tour.isFavorite ? Icons.favorite : Icons.favorite,
                                    color: tour.isFavorite ? Colors.redAccent : const Color(0xFFDEB075), // Goldish color as per design
                                    size: 24,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Favorite',
                                    style: TextStyle(
                                      color: tour.isFavorite ? Colors.redAccent : const Color(0xFFDEB075),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Details (Time, Capacity, Location)
                      _buildInfoRow(Icons.access_time, 'Thời gian: ', tour.duration),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.people_outline, 'Sức chứa: ', '${tour.capacity} khách'),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.location_on_outlined, 'Điểm khởi hành: ', tour.departurePoint),
                      
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                      const SizedBox(height: 24),
                      
                      // Highlights
                      const Text('Mô tả nổi bật', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(
                        tour.highlightDescription,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF555555), height: 1.5),
                      ),
                      
                      const SizedBox(height: 100), // Padding for bottom bar
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Bar
          bottomSheet: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontFamily: 'Roboto'),
                      children: [
                        TextSpan(
                          text: formatCurrency.format(tour.price),
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        TextSpan(
                          text: '/khách',
                          style: TextStyle(color: Colors.grey[800], fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => context.push('/payment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF07E2B), // Orange color
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Đặt ngay', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildGallery(List<String> images) {
    if (images.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Main image
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(images.first, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
                ),
              ),
            ),
            // Bottom thumbnail row
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(images.length > 4 ? 4 : images.length, (index) {
                  return Container(
                    width: 65,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: index == 0 ? Colors.white : Colors.transparent, width: 2),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 5)
                      ]
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(images[index], fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey),
                      ),
                    ),
                  );
                }),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFB0B0B0)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Color(0xFF555555), fontSize: 14)),
        Expanded(
          child: Text(value, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500)),
        )
      ],
    );
  }
}
