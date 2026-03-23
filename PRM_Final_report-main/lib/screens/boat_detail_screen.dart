import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/boats.dart';
import '../services/database_helper.dart';

class BoatDetailScreen extends StatefulWidget {
  final Boat boat;

  const BoatDetailScreen({super.key, required this.boat});

  @override
  State<BoatDetailScreen> createState() => _BoatDetailScreenState();
}

class _BoatDetailScreenState extends State<BoatDetailScreen> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.boat.isFavorite;
  }

  Future<void> _toggleFavorite() async {
    setState(() => _isFavorite = !_isFavorite);
    await DatabaseHelper.instance.toggleFavorite(
      widget.boat.id!,
      _isFavorite,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.boat.name),
              background: CachedNetworkImage(
                imageUrl: widget.boat.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                errorWidget: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : null,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.boat.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(
                        label: Text('${widget.boat.capacity} người'),
                        avatar: const Icon(Icons.people),
                      ),
                      const SizedBox(width: 12),
                      Chip(
                        label: Text('${(widget.boat.pricePerDay / 1000).round()}k / ngày'),
                        avatar: const Icon(Icons.attach_money),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Mô tả',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.boat.description),
                  const SizedBox(height: 24),
                  const Text(
                    'Thời gian sẵn có',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Từ: ${widget.boat.availableFrom.toString().substring(0, 10)}\n'
                        'Đến: ${widget.boat.availableTo.toString().substring(0, 10)}',
                  ),
                  const SizedBox(height: 32),
                  // Nút đặt thuê (có thể để placeholder trước)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Đặt thuê ngay'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tính năng đặt thuê đang phát triển...')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}