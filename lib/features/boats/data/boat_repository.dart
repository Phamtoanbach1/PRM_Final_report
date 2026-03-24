import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/boat.dart';

class BoatRepository {
  static const _key = 'boats_v1';

  Future<List<Boat>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => Boat.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> saveAll(List<Boat> boats) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(boats.map((b) => b.toJson()).toList());
    await prefs.setString(_key, raw);
  }
}
