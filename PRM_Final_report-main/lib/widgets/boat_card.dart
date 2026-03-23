import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/boats.dart';

class BoatCard extends StatelessWidget {
  final Boat boat;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;

  const BoatCard({
    super.key,
    required this.boat,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: boat.imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => const SizedBox(
                  height: 140,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported, size: 80),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    boat.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text('${boat.capacity} người • ${boat.pricePerDay ~/ 1000}k/ngày'),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        boat.availableFrom.toString().substring(0, 10),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      IconButton(
                        icon: Icon(
                          boat.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: boat.isFavorite ? Colors.red : null,
                        ),
                        onPressed: onFavoriteToggle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}