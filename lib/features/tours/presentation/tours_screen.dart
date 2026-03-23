import 'package:flutter/material.dart';

class ToursScreen extends StatefulWidget {
  const ToursScreen({super.key});

  @override
  State<ToursScreen> createState() => _ToursScreenState();
}

class _ToursScreenState extends State<ToursScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9), // Light grayish-blue background
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text('My Schedule', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
            ),
            
            // Custom TabBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTab(0, 'Sắp diễn ra'),
                    const SizedBox(width: 8),
                    _buildTab(1, 'Đã hoàn thành'),
                    const SizedBox(width: 8),
                    _buildTab(2, 'Đang diễn ra'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // List of schedules
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                children: [
                  _buildScheduleCard(
                    status: 'Sắp diễn ra',
                    statusColor: Colors.amber,
                    title: 'Tour khám phá Vịnh Hạ Long',
                    date: '15 tháng 10, 2024',
                    time: '08:00 AM - 05:00 PM',
                    mapImage: 'assets/images/map.jpg', 
                    bgImage: 'assets/images/han_river.jpg',
                  ),
                  const SizedBox(height: 24),
                  _buildScheduleCard(
                    status: 'Đang diễn ra',
                    statusColor: Colors.green,
                    title: 'Khám phá phố cổ Hội An',
                    date: '15 tháng 10, 2024',
                    time: '08:00 AM - 05:00 PM',
                    mapImage: 'assets/images/map.jpg',
                    bgImage: 'assets/images/tour1.jpg',
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String title) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: Colors.grey[300]!) : Border.all(color: Colors.transparent),
          boxShadow: isSelected 
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard({
    required String status,
    required Color statusColor,
    required String title,
    required String date,
    required String time,
    required String mapImage,
    required String bgImage,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          // Banner Image
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            child: SizedBox(
              height: 100,
              width: double.infinity,
              child: Stack(
                children: [
                  Image.asset(bgImage, fit: BoxFit.cover, width: double.infinity),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Text(status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(width: 4),
                          const CircleAvatar(backgroundColor: Colors.white, radius: 4),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildInfoRow(Icons.calendar_today_outlined, date),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.access_time, time),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.location_on_outlined, title), // Location is title in this case
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Map Mini View
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(mapImage, width: 80, height: 60, fit: BoxFit.cover),
                    )
                  ],
                ),
                
                const SizedBox(height: 24),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.blue[50], // Light blue
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Chi tiết', style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B6BF3), // Solid Blue
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('Đặt chỗ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 13), overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
