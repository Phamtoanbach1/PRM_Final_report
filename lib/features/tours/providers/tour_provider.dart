import 'package:flutter/material.dart';
import '../domain/models/tour.dart';

class TourProvider extends ChangeNotifier {
  // Mock Data
  final List<Tour> _allTours = [
    Tour(
      id: '1',
      title: 'Tour Ngắm Hoàng Hôn Trên Sông Hàn',
      price: 550000,
      rating: 4.9,
      reviewCount: 56,
      imageUrl: 'assets/images/tour3.jpg',
      galleryImages: [
        'assets/images/tour3.jpg',
        'assets/images/tour1.jpg',
        'assets/images/tour2.jpg',
        'assets/images/han_river.jpg',
      ],
      duration: '2 giờ',
      capacity: 50,
      departurePoint: 'Bến Bạch Đằng, Đà Nẵng',
      highlightDescription: '- Xem trực tiếp màn trình diễn ánh sáng hoành tráng.\n- Thưởng thức bữa ăn nhẹ trên tàu.\n- Nhạc sóng live acoustic.',
      date: DateTime(2024, 10, 15),
      isFavorite: false,
    ),
    Tour(
      id: '2',
      title: 'Du Thuyền Ăn Tối Lãng Mạn',
      price: 1200000,
      rating: 4.8,
      reviewCount: 32,
      imageUrl: 'assets/images/tour1.jpg',
      galleryImages: [
        'assets/images/tour1.jpg',
        'assets/images/tour2.jpg',
        'assets/images/tour3.jpg',
      ],
      duration: '3 giờ',
      capacity: 20,
      departurePoint: 'Bến sông Hàn',
      highlightDescription: '- Bữa ăn tối cao cấp với set menu tự chọn.\n- Rượu vang và phục vụ riêng biệt.\n- Ngắm nhìn toàn cảnh thành phố về đêm.',
      date: DateTime(2024, 10, 15),
      isFavorite: true,
    ),
    Tour(
      id: '3',
      title: 'Tour Thuyền Rồng Sông Hàn',
      price: 500000,
      rating: 4.7,
      reviewCount: 120,
      imageUrl: 'assets/images/han_river.jpg',
      galleryImages: [
        'assets/images/han_river.jpg',
        'assets/images/tour2.jpg',
        'assets/images/tour1.jpg',
      ],
      duration: '2 giờ',
      capacity: 50,
      departurePoint: 'Bến Bạch Đằng, Đà Nẵng',
      highlightDescription: '- Ngắm các cây cầu nổi tiếng của Đà Nẵng trên sông Hàn.\n- Xem Cầu Rồng phun lửa (cuối tuần).\n- Nhạc sống live.',
      date: DateTime(2024, 10, 16),
      isFavorite: false,
    ),
  ];

  List<Tour> _filteredTours = [];

  // Filter state
  String _searchQuery = '';
  DateTime? _selectedDate;
  int _selectedPersonCount = 1;

  TourProvider() {
    _filteredTours = List.from(_allTours);
  }

  List<Tour> get tours => _filteredTours;
  String get searchQuery => _searchQuery;
  DateTime? get selectedDate => _selectedDate;
  int get selectedPersonCount => _selectedPersonCount;

  void toggleFavorite(String tourId) {
    final tourIndex = _allTours.indexWhere((t) => t.id == tourId);
    if (tourIndex != -1) {
      _allTours[tourIndex].isFavorite = !_allTours[tourIndex].isFavorite;
      _applyFilters();
      notifyListeners();
    }
  }

  Tour getTourById(String id) {
    return _allTours.firstWhere((t) => t.id == id);
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void setFilterDate(DateTime? date) {
    _selectedDate = date;
    _applyFilters();
    notifyListeners();
  }

  void setPersonCount(int count) {
    _selectedPersonCount = count;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredTours = _allTours.where((tour) {
      // Filter by search query
      final matchesQuery = _searchQuery.isEmpty || 
          tour.title.toLowerCase().contains(_searchQuery) ||
          tour.departurePoint.toLowerCase().contains(_searchQuery);

      // Filter by date (ignoring time)
      final matchesDate = _selectedDate == null || 
          (tour.date.year == _selectedDate!.year &&
           tour.date.month == _selectedDate!.month &&
           tour.date.day == _selectedDate!.day);
           
      // Filter by person count (must have enough capacity)
      final matchesCapacity = tour.capacity >= _selectedPersonCount;

      return matchesQuery && matchesDate && matchesCapacity;
    }).toList();
  }
}
