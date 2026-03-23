import 'package:flutter/material.dart';
import '../../booking/models/boat_model.dart';

final boats = <Boat>[
  Boat(id: 1, name: 'Dragon Cruiser', capacity: 30, pricePerHour: 100.0, image: 'assets/images/dragon_bridge.jpg'),
  Boat(id: 2, name: 'Han River Explorer', capacity: 20, pricePerHour: 80.0, image: 'assets/images/han_river.jpg'),
  Boat(id: 3, name: 'Sunset Delight', capacity: 16, pricePerHour: 120.0, image: 'assets/images/tour1.jpg'),
];

class BoatListPage extends StatelessWidget {
  const BoatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Boat List')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: boats.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final boat = boats[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).pushNamed('/boat/${boat.id}');
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.asset(boat.image, height: 170, width: double.infinity, fit: BoxFit.cover),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(boat.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('${boat.pricePerHour.toStringAsFixed(0)}đ/h', style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.group, size: 18, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${boat.capacity} people'),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/boat/${boat.id}/book');
                          },
                          child: const Text('Book Now'),
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
    );
  }
}
