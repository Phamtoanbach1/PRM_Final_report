import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/boats.dart';
import '../services/database_helper.dart';
import '../widgets/boat_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'boat_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    showModalBottomSheet<void>(
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

  void _clearFilters() {
    setState(() {
      _selectedDate = null;
      _minCapacity = null;
    });
    _loadBoats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boat Booking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Tìm kiếm thuyền',
            onPressed: () {
              showSearch<void>(
                context: context,
                delegate: BoatSearchDelegate(onSearchComplete: _loadBoats),
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
          : RefreshIndicator(
              onRefresh: _loadBoats,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _HomeHeader(
                      selectedDate: _selectedDate,
                      minCapacity: _minCapacity,
                      onClearFilters: _clearFilters,
                    ),
                  ),
                  if (_boats.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text('Không tìm thấy thuyền phù hợp')),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      sliver: SliverGrid.builder(
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
                              _loadBoats();
                            },
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BoatDetailScreen(boat: boat),
                                ),
                              ).then((_) => _loadBoats());
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final DateTime? selectedDate;
  final int? minCapacity;
  final VoidCallback onClearFilters;

  const _HomeHeader({
    required this.selectedDate,
    required this.minCapacity,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilter = selectedDate != null || minCapacity != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [Color(0xFF355CDE), Color(0xFF4F7BFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Khám phá du thuyền',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Lọc theo ngày, số người và xem chi tiết thuyền.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          if (hasFilter) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (selectedDate != null)
                  Chip(
                    avatar: const Icon(Icons.calendar_today, size: 18),
                    label: Text(DateFormat('dd/MM/yyyy').format(selectedDate!)),
                  ),
                if (minCapacity != null)
                  Chip(
                    avatar: const Icon(Icons.people, size: 18),
                    label: Text('Tối thiểu $minCapacity người'),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.clear_all),
                  label: const Text('Xóa bộ lọc'),
                  onPressed: onClearFilters,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

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
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(child: Text('Nhập tên thuyền để tìm kiếm...'));
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
              },
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BoatDetailScreen(boat: boat)),
                ).then((_) => onSearchComplete?.call());
              },
            );
          },
        );
      },
    );
  }
}
