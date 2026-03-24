import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/owner_promo_code.dart';

class PromoRepository {
  static const _key = 'owner_promos_v1';

  Future<List<OwnerPromoCode>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return <OwnerPromoCode>[];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => OwnerPromoCode.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> saveAll(List<OwnerPromoCode> promos) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(promos.map((e) => e.toJson()).toList());
    await prefs.setString(_key, raw);
  }
}
