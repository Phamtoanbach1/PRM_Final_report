import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../../data/local/shared_prefs_helper.dart';
import '../../auth/domain/user_role.dart';
import '../data/boat_catalog.dart';
import '../data/boat_repository.dart';
import '../domain/boat.dart';

class BoatProvider extends ChangeNotifier {
  BoatProvider({BoatRepository? repository}) : _repository = repository ?? BoatRepository() {
    _boats = List<Boat>.from(BoatCatalog.defaultBoats);
    _init();
    loadFavorites();
  }

  final BoatRepository _repository;
  String _keyword = '';
  int _minSeats = 1;
  DateTime? _selectedDate;
  Set<String> _favoriteIds = <String>{};
  late List<Boat> _boats;

  String get keyword => _keyword;
  int get minSeats => _minSeats;
  DateTime? get selectedDate => _selectedDate;

  List<Boat> get allBoats => List.unmodifiable(_boats);
  List<Boat> boatsForAdminScope(UserRole role, String? email) {
    if (role == UserRole.admin) return allBoats;
    if (role == UserRole.shopOwner && email != null) {
      return _boats.where((b) => b.ownerEmail.toLowerCase() == email.toLowerCase()).toList();
    }
    return const <Boat>[];
  }

  Future<void> _init() async {
    final stored = await _repository.loadAll();
    if (stored.isNotEmpty) {
      final defaultOwnerById = <String, String>{
        for (final b in BoatCatalog.defaultBoats) b.id: b.ownerEmail,
      };
      var changed = false;
      final migrated = stored.map((b) {
        final fallbackOwner = defaultOwnerById[b.id];
        if (fallbackOwner != null && b.ownerEmail == 'owner@hancruise.local' && fallbackOwner != b.ownerEmail) {
          changed = true;
          return b.copyWith(ownerEmail: fallbackOwner);
        }
        return b;
      }).toList();
      final merged = <Boat>[...migrated];
      final existingIds = merged.map((e) => e.id).toSet();
      for (final b in BoatCatalog.defaultBoats) {
        if (!existingIds.contains(b.id)) {
          merged.add(b);
          changed = true;
        }
      }
      _boats = merged;
      if (changed) {
        await _repository.saveAll(_boats);
      }
      notifyListeners();
    }
  }

  List<Boat> get filteredBoats {
    final query = _keyword.trim().toLowerCase();
    final dateYmd = _selectedDate == null ? null : DateFormat('yyyy-MM-dd').format(_selectedDate!);
    return _boats.where((b) {
      final matchKeyword = query.isEmpty ||
          b.name.toLowerCase().contains(query) ||
          b.description.toLowerCase().contains(query);
      final matchSeats = b.capacity >= _minSeats;
      final matchDate = dateYmd == null || !b.blockedDateYmd.contains(dateYmd);
      return matchKeyword && matchSeats && matchDate;
    }).toList();
  }

  bool isAvailableOnDate(Boat boat, DateTime? date) {
    if (date == null) return true;
    final ymd = DateFormat('yyyy-MM-dd').format(date);
    return !boat.blockedDateYmd.contains(ymd);
  }

  Boat? byId(String id) {
    for (final b in _boats) {
      if (b.id == id) return b;
    }
    return null;
  }

  bool isFavorite(String boatId) => _favoriteIds.contains(boatId);

  Future<void> loadFavorites() async {
    _favoriteIds = (await SharedPrefsHelper.getFavoriteBoatIds()).toSet();
    notifyListeners();
  }

  Future<void> toggleFavorite(String boatId) async {
    if (_favoriteIds.contains(boatId)) {
      _favoriteIds.remove(boatId);
    } else {
      _favoriteIds.add(boatId);
    }
    await SharedPrefsHelper.saveFavoriteBoatIds(_favoriteIds.toList());
    notifyListeners();
  }

  void setKeyword(String value) {
    _keyword = value;
    notifyListeners();
  }

  void setMinSeats(int seats) {
    _minSeats = seats.clamp(1, 50);
    notifyListeners();
  }

  void setDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  void clearFilters() {
    _keyword = '';
    _minSeats = 1;
    _selectedDate = null;
    notifyListeners();
  }

  Future<void> addBoat({
    required String name,
    required String description,
    required int capacity,
    required double hourlyPrice,
    required List<String> gallery,
    required String ownerEmail,
  }) async {
    _validateBoatInput(
      name: name,
      description: description,
      capacity: capacity,
      hourlyPrice: hourlyPrice,
      gallery: gallery,
    );
    final boat = Boat(
      id: 'boat_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      description: description,
      capacity: capacity,
      hourlyPrice: hourlyPrice,
      rating: 4.5,
      gallery: gallery,
      ownerEmail: ownerEmail,
    );
    _boats = [boat, ..._boats];
    await _repository.saveAll(_boats);
    notifyListeners();
  }

  Future<void> updateBoat(Boat updated) async {
    _validateBoatInput(
      name: updated.name,
      description: updated.description,
      capacity: updated.capacity,
      hourlyPrice: updated.hourlyPrice,
      gallery: updated.gallery,
    );
    final idx = _boats.indexWhere((e) => e.id == updated.id);
    if (idx < 0) return;
    _boats[idx] = updated;
    await _repository.saveAll(_boats);
    notifyListeners();
  }

  Future<bool> updateBoatScoped(
    Boat updated, {
    required UserRole role,
    required String? actorEmail,
  }) async {
    final existing = byId(updated.id);
    if (existing == null) return false;
    final normalized = (actorEmail ?? '').trim().toLowerCase();
    final canEdit = role == UserRole.admin ||
        (role == UserRole.shopOwner &&
            normalized.isNotEmpty &&
            existing.ownerEmail.toLowerCase() == normalized);
    if (!canEdit) return false;
    await updateBoat(updated);
    return true;
  }

  Future<void> deleteBoat(String id) async {
    _boats.removeWhere((e) => e.id == id);
    _favoriteIds.remove(id);
    await _repository.saveAll(_boats);
    await SharedPrefsHelper.saveFavoriteBoatIds(_favoriteIds.toList());
    notifyListeners();
  }

  Future<bool> deleteBoatScoped(
    String id, {
    required UserRole role,
    required String? actorEmail,
  }) async {
    final existing = byId(id);
    if (existing == null) return false;
    final normalized = (actorEmail ?? '').trim().toLowerCase();
    final canDelete = role == UserRole.admin ||
        (role == UserRole.shopOwner &&
            normalized.isNotEmpty &&
            existing.ownerEmail.toLowerCase() == normalized);
    if (!canDelete) return false;
    await deleteBoat(id);
    return true;
  }

  Future<void> setBlockedDates(String boatId, Set<String> blockedYmd) async {
    final boat = byId(boatId);
    if (boat == null) return;
    await updateBoat(boat.copyWith(blockedDateYmd: blockedYmd));
  }

  Future<bool> setBlockedDatesScoped(
    String boatId,
    Set<String> blockedYmd, {
    required UserRole role,
    required String? actorEmail,
  }) async {
    final boat = byId(boatId);
    if (boat == null) return false;
    final normalized = (actorEmail ?? '').trim().toLowerCase();
    final canEdit = role == UserRole.admin ||
        (role == UserRole.shopOwner &&
            normalized.isNotEmpty &&
            boat.ownerEmail.toLowerCase() == normalized);
    if (!canEdit) return false;
    await setBlockedDates(boatId, blockedYmd);
    return true;
  }

  void _validateBoatInput({
    required String name,
    required String description,
    required int capacity,
    required double hourlyPrice,
    required List<String> gallery,
  }) {
    if (name.trim().isEmpty) throw Exception('Tên thuyền không được để trống');
    if (description.trim().isEmpty) throw Exception('Mô tả không được để trống');
    if (capacity < 1 || capacity > 500) throw Exception('Sức chứa phải trong khoảng 1-500');
    if (hourlyPrice < 100000 || hourlyPrice > 100000000) {
      throw Exception('Giá theo giờ không hợp lệ');
    }
    final imageRefRegex = RegExp(r'^(https?://|file://|/|[A-Za-z]:\\)', caseSensitive: false);
    for (final g in gallery) {
      if (!imageRefRegex.hasMatch(g.trim())) {
        throw Exception('Đường dẫn ảnh không hợp lệ: $g');
      }
    }
  }
}
