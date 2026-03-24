class Boat {
  const Boat({
    required this.id,
    required this.name,
    required this.description,
    required this.capacity,
    required this.hourlyPrice,
    required this.rating,
    required this.gallery,
    required this.ownerEmail,
    this.blockedDateYmd = const <String>{},
  });

  final String id;
  final String name;
  final String description;
  final int capacity;
  final double hourlyPrice;
  final double rating;
  final List<String> gallery;
  final String ownerEmail;
  final Set<String> blockedDateYmd;

  Boat copyWith({
    String? id,
    String? name,
    String? description,
    int? capacity,
    double? hourlyPrice,
    double? rating,
    List<String>? gallery,
    String? ownerEmail,
    Set<String>? blockedDateYmd,
  }) {
    return Boat(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      capacity: capacity ?? this.capacity,
      hourlyPrice: hourlyPrice ?? this.hourlyPrice,
      rating: rating ?? this.rating,
      gallery: gallery ?? this.gallery,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      blockedDateYmd: blockedDateYmd ?? this.blockedDateYmd,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'description': description,
        'capacity': capacity,
        'hourlyPrice': hourlyPrice,
        'rating': rating,
        'gallery': gallery,
        'ownerEmail': ownerEmail,
        'blockedDateYmd': blockedDateYmd.toList(),
      };

  factory Boat.fromJson(Map<String, dynamic> json) {
    return Boat(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      capacity: json['capacity'] as int,
      hourlyPrice: (json['hourlyPrice'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      gallery: List<String>.from(json['gallery'] as List<dynamic>),
      ownerEmail: (json['ownerEmail'] as String?) ?? 'owner@hancruise.local',
      blockedDateYmd: Set<String>.from(json['blockedDateYmd'] as List<dynamic>),
    );
  }
}
