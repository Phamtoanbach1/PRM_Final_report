import 'package:flutter/material.dart';
import '../models/boat_model.dart';
import '../../booking/pages/boat_list_page.dart';

class BoatDetailPage extends StatelessWidget {
  final int boatId;

  const BoatDetailPage({super.key, required this.boatId});

  Boat get boat => boats.firstWhere((element) => element.id == boatId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Boat Detail')),
      body: ListView(
        children: [
          Image.asset(boat.image, fit: BoxFit.cover, height: 240, width: double.infinity),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(boat.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Capacity: ${boat.capacity} people', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Price per hour: ${boat.pricePerHour.toStringAsFixed(0)} đ', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                const Text('A premium experience cruising along the river with expert crew and comfort seating. Perfect for groups and evening events.', style: TextStyle(fontSize: 14, color: Colors.black87)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/boat/${boat.id}/book');
                    },
                    child: const Text('Book Now'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
