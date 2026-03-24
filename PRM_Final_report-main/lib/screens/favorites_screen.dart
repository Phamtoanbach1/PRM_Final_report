import 'package:flutter/material.dart';

import '../models/boats.dart';
import '../services/database_helper.dart';
import '../widgets/boat_card.dart';
import 'boat_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Boat> _boats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final boats = await DatabaseHelper.instance.searchBoats(onlyFavorites: true);
    setState(() {
      _boats = boats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thuyền yêu thích')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _boats.isEmpty
              ? const Center(
                  child: Text('Bạn chưa thêm thuyền nào vào yêu thích'),
                )
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: GridView.builder(
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
                            false,
                          );
                          _loadFavorites();
                        },
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BoatDetailScreen(boat: boat),
                            ),
                          ).then((_) => _loadFavorites());
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
