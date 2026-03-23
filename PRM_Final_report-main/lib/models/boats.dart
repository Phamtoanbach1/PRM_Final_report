class Boat {
  final int? id;
  final String name;
  final String description;
  final String imageUrl;        // hoặc asset path: 'assets/boats/boat1.jpg'
  final int capacity;           // số người tối đa
  final double pricePerDay;
  final DateTime availableFrom; // ngày sẵn sàng từ
  final DateTime availableTo;   // đến
  bool isFavorite;

  Boat({
    this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.capacity,
    required this.pricePerDay,
    required this.availableFrom,
    required this.availableTo,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'capacity': capacity,
      'pricePerDay': pricePerDay,
      'availableFrom': availableFrom.toIso8601String(),
      'availableTo': availableTo.toIso8601String(),
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory Boat.fromMap(Map<String, dynamic> map) {
    return Boat(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      capacity: map['capacity'],
      pricePerDay: map['pricePerDay'],
      availableFrom: DateTime.parse(map['availableFrom']),
      availableTo: DateTime.parse(map['availableTo']),
      isFavorite: map['isFavorite'] == 1,
    );
  }
}