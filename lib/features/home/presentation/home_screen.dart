import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:line_icons/line_icons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header specific to Figma design
            SizedBox(
              height: 380, // Accommodate the Han river image
              child: Stack(
                children: [
                  // Background Image
                  Container(
                    width: double.infinity,
                    height: 350,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/han_river.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Dark Top Gradient Overlay
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF0F1B3E).withValues(alpha: 0.9),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  
                  // Content Info
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Current Location', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
                                  const SizedBox(height: 4),
                                  const Text('Đà Nẵng: 28°C, Ít Mây', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.cloud_queue, color: Colors.yellowAccent, size: 28),
                              )
                            ],
                          ),
                          // Search Bar over the image
                          GestureDetector(
                            onTap: () => context.push('/boat-list'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))
                                ],
                              ),
                              child: TextField(
                                enabled: false, // Make it readonly to trigger onTap of GestureDetector
                                decoration: InputDecoration(
                                  hintText: 'Tìm kiếm tour, địa điểm...',
                                  hintStyle: const TextStyle(color: Colors.grey),
                                  icon: Icon(LineIcons.search, color: Colors.grey[400]),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Floating White Container bottom masking
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            
            // Featured Tours Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text('Featured Tours', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
            ),
            const SizedBox(height: 16),
            
            // Horizontal Scroll List
            SizedBox(
              height: 320,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
<<<<<<< HEAD
                  _buildTourCard(context, 'Tour Đêm Sông Hàn', '350.000đ', '4.8', 'assets/images/tour1.jpg'),
                  _buildTourCard(context, 'Tour Linh Sông Hàn', '350.000đ', '4.8', 'assets/images/tour2.jpg'),
                  _buildTourCard(context, 'Tour Hoàng Hôn', '300.000đ', '4.9', 'assets/images/tour3.jpg'),
=======
                  _buildTourCard(context, 'Tour Đêm Sông Hàn', '350.000đ', '4.8', 'assets/images/tour1.jpg', boatId: 'boat_han_01'),
                  _buildTourCard(context, 'Tour Linh Sông Hàn', '350.000đ', '4.8', 'assets/images/tour2.jpg', boatId: 'boat_han_02'),
                  _buildTourCard(context, 'Tour Hoàng Hôn', '300.000đ', '4.9', 'assets/images/tour3.jpg', boatId: 'boat_sunset'),
>>>>>>> e02dd441d067738dce77013df773bb51c73afe4c
                ],
              ),
            ),
            const SizedBox(height: 80), // Padding for nav bar
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildTourCard(BuildContext context, String title, String price, String rating, String imageUrl) {
=======
  Widget _buildTourCard(
    BuildContext context,
    String title,
    String price,
    String rating,
    String imageUrl, {
    String? boatId,
  }) {
>>>>>>> e02dd441d067738dce77013df773bb51c73afe4c
    return Container(
      width: 220,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            child: Image.asset(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(price, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text(rating, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
<<<<<<< HEAD
                    onPressed: () => context.push('/payment'),
=======
                    onPressed: () {
                      if (boatId != null) {
                        context.push('/bookings/create', extra: <String, dynamic>{'boatId': boatId});
                      } else {
                        context.push('/bookings/create');
                      }
                    },
>>>>>>> e02dd441d067738dce77013df773bb51c73afe4c
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A74D1), // Purple-blue flat button
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Đặt ngay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
