import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../providers/boat_provider.dart';

class BoatsScreen extends StatefulWidget {
  const BoatsScreen({super.key, this.favoritesOnly = false});

  final bool favoritesOnly;

  @override
  State<BoatsScreen> createState() => _BoatsScreenState();
}

class _BoatsScreenState extends State<BoatsScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final provider = context.read<BoatProvider>();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) provider.setDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return Consumer<BoatProvider>(
      builder: (context, provider, _) {
        final baseBoats = provider.filteredBoats;
        final boats = widget.favoritesOnly
            ? baseBoats.where((b) => provider.isFavorite(b.id)).toList()
            : baseBoats;
        final dateText = provider.selectedDate == null
            ? 'Chọn ngày'
            : DateFormat('dd/MM/yyyy').format(provider.selectedDate!);
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(widget.favoritesOnly ? 'Thuyền yêu thích' : 'Danh sách thuyền'),
            backgroundColor: Colors.transparent,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
            children: [
              TextField(
                controller: _search,
                onChanged: provider.setKeyword,
                decoration: InputDecoration(
                  hintText: 'Tìm tên thuyền hoặc mô tả',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bộ lọc', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickDate,
                            icon: const Icon(Icons.event_outlined),
                            label: Text(dateText),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            _search.clear();
                            provider.clearFilters();
                          },
                          child: const Text('Xóa lọc'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Số người tối thiểu:'),
                        const Spacer(),
                        IconButton(
                          onPressed: () => provider.setMinSeats(provider.minSeats - 1),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('${provider.minSeats}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        IconButton(
                          onPressed: () => provider.setMinSeats(provider.minSeats + 1),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (widget.favoritesOnly)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Đang hiển thị các thuyền bạn đã yêu thích.',
                    style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                  ),
                ),
              const SizedBox(height: 12),
              Text('Kết quả: ${boats.length} thuyền',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              if (boats.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Center(child: Text('Không có thuyền phù hợp bộ lọc')),
                ),
              ...boats.map((b) {
                final fav = provider.isFavorite(b.id);
                final image = b.gallery.isEmpty ? '' : b.gallery.first;
                final selectedDate = provider.selectedDate;
                final availableOnDate = provider.isAvailableOnDate(b, selectedDate);
                final availableLabel = selectedDate == null
                    ? null
                    : 'Còn trống ${DateFormat('dd/MM').format(selectedDate)}';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => context.push('/home/boats/${b.id}'),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: _boatImage(image),
                                ),
                              ),
                              if (availableLabel != null)
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: availableOnDate
                                          ? Colors.green.shade600
                                          : Colors.orange.shade700,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      availableOnDate ? availableLabel : 'Đã kín ngày đã chọn',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        b.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => provider.toggleFavorite(b.id),
                                      icon: Icon(
                                        fav ? Icons.favorite : Icons.favorite_border,
                                        color: fav ? Colors.red : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  b.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _meta(Icons.people_alt_outlined, '${b.capacity} khách'),
                                    const SizedBox(width: 10),
                                    _meta(Icons.star_rounded, b.rating.toStringAsFixed(1)),
                                    const Spacer(),
                                    Text(
                                      '${currency.format(b.hourlyPrice)}/giờ',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _meta(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: AppColors.textSecondary)),
      ],
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
        child: const Center(child: Icon(Icons.image_not_supported)),
      );
}
