import 'package:flutter/material.dart';
import '../models/boats.dart';
import '../services/database_helper.dart';
import '../widgets/boat_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../screens/boat_detail_screen.dart';

class BoatListScreen extends StatefulWidget {
  const BoatListScreen({super.key});

  @override
  State<BoatListScreen> createState() => _BoatListScreenState();
}

class _BoatListScreenState extends State<BoatListScreen> {
  List<Boat> _boats = [];
  bool _isLoading = true;

  DateTime? _selectedDate;
  int? _minCapacity;

  @override
  void initState() {
    super.initState();
    _loadBoats();
  }

  Future<void> _loadBoats() async {
    setState(() => _isLoading = true);
    final boats = await DatabaseHelper.instance.searchBoats(
      date: _selectedDate,
      minCapacity: _minCapacity,
    );
    setState(() {
      _boats = boats;
      _isLoading = false;
    });
  }

  void _showFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => FilterBottomSheet(
        initialDate: _selectedDate,
        initialCapacity: _minCapacity,
        onApply: (date, capacity) {
          setState(() {
            _selectedDate = date;
            _minCapacity = capacity;
          });
          _loadBoats();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách thuyền'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Tìm kiếm thuyền',
            onPressed: () {
              showSearch(
                context: context,
                delegate: BoatSearchDelegate(
                  onSearchComplete: _loadBoats,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Lọc nâng cao',
            onPressed: _showFilter,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _boats.isEmpty
          ? const Center(child: Text('Không tìm thấy thuyền phù hợp'))
          : GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _boats.length,
        itemBuilder: (context, index) {
          final boat = _boats[index];
          return BoatCard(
            boat: boat,
            onFavoriteToggle: () async {
              await DatabaseHelper.instance.toggleFavorite(
                boat.id!,
                !boat.isFavorite,
              );
              _loadBoats(); // reload để cập nhật icon
            },
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BoatDetailScreen(boat: boat),
                ),
              ).then((_) => _loadBoats()); // quay lại thì reload
            },
          );
        },
      ),
    );
  }
}

// Đặt class BoatSearchDelegate ở đây - ngoài class state
class BoatSearchDelegate extends SearchDelegate<String> {
  final VoidCallback? onSearchComplete;

  BoatSearchDelegate({this.onSearchComplete});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(
        child: Text('Nhập tên thuyền để tìm kiếm...'),
      );
    }

    return FutureBuilder<List<Boat>>(
      future: DatabaseHelper.instance.searchBoatsByName(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }
        final results = snapshot.data ?? [];
        if (results.isEmpty) {
          return const Center(child: Text('Không tìm thấy thuyền phù hợp'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.68,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final boat = results[index];
            return BoatCard(
              boat: boat,
              onFavoriteToggle: () async {
                await DatabaseHelper.instance.toggleFavorite(
                  boat.id!,
                  !boat.isFavorite,
                );
                // Nếu muốn reload search results realtime → có thể rebuild delegate, nhưng phức tạp hơn
              },
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BoatDetailScreen(boat: boat),
                  ),
                ).then((_) {
                  onSearchComplete?.call();
                });
              },
            );
          },
        );
      },
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
      ),
      inputDecorationTheme: searchFieldDecorationTheme ??
          InputDecorationTheme(
            hintStyle: TextStyle(color: theme.colorScheme.onPrimary.withOpacity(0.7)),
            border: InputBorder.none,
          ),
    );
  }
}