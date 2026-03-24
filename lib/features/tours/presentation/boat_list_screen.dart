import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import '../domain/models/tour.dart';
import '../providers/tour_provider.dart';

class BoatListScreen extends StatefulWidget {
  const BoatListScreen({super.key});

  @override
  State<BoatListScreen> createState() => _BoatListScreenState();
}

class _BoatListScreenState extends State<BoatListScreen> {
  final TextEditingController _searchController = TextEditingController();

  Future<void> _selectDate(BuildContext context, TourProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      provider.setFilterDate(picked);
    }
  }

  void _showPersonCountDialog(BuildContext context, TourProvider provider) {
    int tempCount = provider.selectedPersonCount;
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Số người'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      if (tempCount > 1) setState(() => tempCount--);
                    },
                  ),
                  Text('$tempCount', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      setState(() => tempCount++);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Hủy'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Xong'),
                  onPressed: () {
                    provider.setPersonCount(tempCount);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TourProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF3F5F9),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Details
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Text(
                    'Danh sách Tour Thuyền',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) => provider.setSearchQuery(value),
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm tour...',
                              hintStyle: const TextStyle(color: Colors.grey),
                              icon: Icon(LineIcons.search, color: Colors.grey[400]),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))
                          ],
                        ),
                        child: Icon(Icons.tune_rounded, color: Colors.grey[700]),
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),

                // Filters
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      // Date Filter
                      GestureDetector(
                        onTap: () => _selectDate(context, provider),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[700]),
                              const SizedBox(width: 8),
                              Text(
                                provider.selectedDate == null 
                                    ? 'Ngày' 
                                    : DateFormat('dd Thg MM').format(provider.selectedDate!),
                                style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Person Count Filter
                      GestureDetector(
                        onTap: () => _showPersonCountDialog(context, provider),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.person_outline, size: 18, color: Colors.grey[700]),
                              const SizedBox(width: 8),
                              Text(
                                '${provider.selectedPersonCount} người',
                                style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // List of Tours
                Expanded(
                  child: provider.tours.isEmpty 
                    ? const Center(child: Text('Không tìm thấy tour phù hợp'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        itemCount: provider.tours.length,
                        itemBuilder: (context, index) {
                          final tour = provider.tours[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: GestureDetector(
                              onTap: () => context.push('/boat-detail/${tour.id}'),
                              child: _buildTourItem(tour, provider),
                            ),
                          );
                        },
                      ),
                )
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildTourItem(Tour tour, TourProvider provider) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return Container(
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
          // Banner Image & Heart Icon
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                child: Image.asset(
                  tour.imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 160, 
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => provider.toggleFavorite(tour.id),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      tour.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: tour.isFavorite ? Colors.redAccent : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              )
            ],
          ),
          
          // Content Info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tour.title, 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < tour.rating.floor() ? Icons.star : Icons.star_border,
                          size: 16,
                          color: Colors.amber,
                        );
                      }),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${tour.rating}) - ${tour.reviewCount} đánh giá',
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontFamily: 'Roboto'),
                    children: [
                      TextSpan(
                        text: formatCurrency.format(tour.price),
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      TextSpan(
                        text: ' / người',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
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
