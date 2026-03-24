class Tour {
  final String id;
  final String title;
  final double price; // Per person
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final List<String> galleryImages;
  final String duration;
  final int capacity;
  final String departurePoint;
  final String highlightDescription;
  final DateTime date;
  bool isFavorite;

  Tour({
    required this.id,
    required this.title,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.galleryImages,
    required this.duration,
    required this.capacity,
    required this.departurePoint,
    required this.highlightDescription,
    required this.date,
    this.isFavorite = false,
  });

  Tour copyWith({
    String? id,
    String? title,
    double? price,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    List<String>? galleryImages,
    String? duration,
    int? capacity,
    String? departurePoint,
    String? highlightDescription,
    DateTime? date,
    bool? isFavorite,
  }) {
    return Tour(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
      galleryImages: galleryImages ?? this.galleryImages,
      duration: duration ?? this.duration,
      capacity: capacity ?? this.capacity,
      departurePoint: departurePoint ?? this.departurePoint,
      highlightDescription: highlightDescription ?? this.highlightDescription,
      date: date ?? this.date,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
